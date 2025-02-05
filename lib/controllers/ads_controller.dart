import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/data/models/student_request_model.dart';
import 'package:tutoring/data/models/teacher_ad_model.dart';
import 'package:tutoring/data/models/filter_model.dart';

class AdsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  var adsList = <dynamic>[].obs; // Tüm ilanlar burada saklanacak
  var filteredAdsList = <dynamic>[].obs; // Filtrelenmiş ilan listesi
  var currentFilter = FilterModel().obs; // Mevcut filtreleme durumu
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    print("📌 AdsController başlatıldı!");

    // Kullanıcı giriş yapmışsa ilanları yükle
    if (_authController.user != null) {
      print("📌 Kullanıcı bulundu, ilanları çekiyorum...");
      fetchAdsBasedOnRole();
    }

    // Kullanıcı değişikliklerini dinle ve ilanları güncelle
    ever(_authController.rxUser, (user) async {
      if (user != null) {
        print("📌 Kullanıcı değişti, ilanları tekrar çekiyorum...");
        await fetchAdsBasedOnRole();
      } else {
        adsList.clear();
        filteredAdsList.clear();
        _subscription?.cancel();
      }
    });
  }

  /// **İlanları yüklemek için kullanılacak public metod**
  Future<void> fetchAdsBasedOnRole() async {
    await _fetchAdsBasedOnRole();
  }

  /// **Firestore'dan ilanları çeker ve adsList'i günceller**
  Future<void> _fetchAdsBasedOnRole() async {
    _subscription?.cancel(); // Önceki bağlantıyı temizle

    String collectionName =
        _authController.isTeacher ? "student_requests" : "teacher_ads";

    print("📢 Firestore koleksiyon adı: $collectionName");

    try {
      _subscription = _firestore.collection(collectionName).snapshots().listen(
        (snapshot) {
          print(
              "🔍 Firestore'dan veri çekildi: ${snapshot.docs.length} döküman");

          adsList.value = snapshot.docs.map((doc) {
            print("📌 Çekilen veri: ${doc.data()}");
            return _authController.isTeacher
                ? StudentRequestModel.fromJson(doc.data(), doc.id)
                : TeacherAdModel.fromJson(doc.data(), doc.id);
          }).toList();

          applyFilters(); // ✅ İlanları çektikten sonra filtre uygula
          print("✅ adsList uzunluğu: ${adsList.length}");
        },
        onError: (error) {
          print("❌ Firestore hata: $error");
        },
      );
    } catch (e) {
      print("❌ İlanları çekerken hata oluştu: $e");
    }
  }

  /// **Filtreleme fonksiyonu**
  void applyFilters() {
    List<dynamic> filtered = adsList.where((ad) {
      final filter = currentFilter.value;

      // Şehir filtresi
      if (filter.city != null &&
          filter.city!.isNotEmpty &&
          filter.city != ad.city) return false;
      if (filter.district != null &&
          filter.district!.isNotEmpty &&
          filter.district != ad.district) return false;

      // Ders filtresi
      if (filter.subject != null &&
          filter.subject!.isNotEmpty &&
          filter.subject != ad.subject) return false;

      // Fiyat aralığı filtresi
      if (filter.minPrice != null && ad.hourlyRate < filter.minPrice!)
        return false;
      if (filter.maxPrice != null && ad.hourlyRate > filter.maxPrice!)
        return false;

      // Cinsiyet filtresi
      if (filter.gender != null &&
          filter.gender!.isNotEmpty &&
          filter.gender != ad.gender) return false;

      // Puan filtresi
      if (filter.minRating != null && ad.teacherRating < filter.minRating!)
        return false;

      return true;
    }).toList();

    filteredAdsList.value = filtered;
    print("✅ Filtre sonrası liste uzunluğu: ${filteredAdsList.length}");
  }

  /// **Filtreleri Güncelle**
  void updateFilter(FilterModel newFilter) {
    currentFilter.value = newFilter;
    applyFilters();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
