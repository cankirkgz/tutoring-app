import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/data/models/student_request_model.dart';
import 'package:tutoring/data/models/teacher_ad_model.dart';
import 'package:tutoring/data/models/filter_model.dart';
import 'package:tutoring/data/models/user_model.dart';

class AdsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  // Tüm ilanlar (öğretmen ve öğrenci ilanları dinamik olarak tutuluyor)
  var adsList = <dynamic>[].obs;
  // Uygulanan filtreye göre güncellenen ilan listesi
  var filteredAdsList = <dynamic>[].obs;
  // Mevcut filtreleme durumu
  var currentFilter = FilterModel().obs;

  // Öğretmen ilanları için: ilanı paylaşan öğretmenin bilgilerini cache'le
  final Map<String, UserModel> teacherCache = {};
  // Öğrenci talepleri için: ilanı paylaşan öğrencinin bilgilerini cache'le
  final Map<String, UserModel> studentCache = {};

  StreamSubscription? _subscription;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    print("📌 AdsController başlatıldı!");

    if (_authController.user != null) {
      print("📌 Kullanıcı bulundu, ilanları çekiyorum...");
      fetchAdsBasedOnRole();
    }

    // Kullanıcı değişikliklerinde ilanları yeniden yükle
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

  /// İlanları kullanıcı rolüne göre çekmek için public metod
  Future<void> fetchAdsBasedOnRole() async {
    isLoading.value = true; // Yükleme başladı
    try {
      await _fetchAdsBasedOnRole();
    } catch (e) {
      print("Hata: $e");
    } finally {
      isLoading.value = false; // Yükleme bitti
    }
  }

  /// Firestore'dan ilanları çekip adsList'i günceller
  Future<void> _fetchAdsBasedOnRole() async {
    _subscription?.cancel();
    String collectionName =
        _authController.isTeacher ? "student_requests" : "teacher_ads";

    print("📢 Firestore koleksiyon adı: $collectionName");

    try {
      _subscription = _firestore
          .collection(collectionName)
          .orderBy('createdAt',
              descending: true) // En güncelden en eskiye sırala
          .snapshots()
          .listen(
        (snapshot) async {
          print(
              "🔍 Firestore'dan veri çekildi: ${snapshot.docs.length} döküman");

          adsList.value = snapshot.docs.map((doc) {
            print("📌 Çekilen veri: ${doc.data()}");
            return _authController.isTeacher
                ? StudentRequestModel.fromJson(doc.data(), doc.id)
                : TeacherAdModel.fromJson(doc.data(), doc.id);
          }).toList();

          // Kullanıcı rolüne göre ilgili cache'i dolduruyoruz.
          if (_authController.isTeacher) {
            // Öğretmen girişinde: öğrenci talepleri listeleniyor.
            await _populateStudentCache();
          } else {
            // Öğrenci girişinde: öğretmen ilanları listeleniyor.
            await _populateTeacherCache();
          }

          applyFilters();
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

  /// TeacherAdModel'lerde yer alan teacherId'lere göre cache'i doldurur.
  Future<void> _populateTeacherCache() async {
    final teacherIds = adsList
        .where((ad) => ad is TeacherAdModel)
        .map((ad) => (ad as TeacherAdModel).teacherId)
        .toSet();

    for (var teacherId in teacherIds) {
      if (!teacherCache.containsKey(teacherId)) {
        try {
          final doc = await _firestore.collection('users').doc(teacherId).get();
          if (doc.exists) {
            teacherCache[teacherId] =
                UserModel.fromJson(doc.data()!, teacherId);
          }
        } catch (e) {
          print("❌ Öğretmen ($teacherId) bilgileri çekilemedi: $e");
        }
      }
    }
  }

  /// StudentRequestModel'lerde yer alan studentId'lere göre cache'i doldurur.
  Future<void> _populateStudentCache() async {
    final studentIds = adsList
        .where((ad) => ad is StudentRequestModel)
        .map((ad) => (ad as StudentRequestModel).studentId)
        .toSet();

    for (var studentId in studentIds) {
      if (!studentCache.containsKey(studentId)) {
        try {
          final doc = await _firestore.collection('users').doc(studentId).get();
          if (doc.exists) {
            studentCache[studentId] =
                UserModel.fromJson(doc.data()!, studentId);
          }
        } catch (e) {
          print("❌ Öğrenci ($studentId) bilgileri çekilemedi: $e");
        }
      }
    }
  }

  /// Mevcut filtreye göre ilanları filtreler ve filteredAdsList'i günceller.
  void applyFilters() {
    List<dynamic> filtered = adsList.where((ad) {
      final filter = currentFilter.value;

      // Şehir, ilçe ve ders filtreleri (her iki model için de ortak)
      if (filter.city != null &&
          filter.city!.isNotEmpty &&
          filter.city != ad.city) return false;
      if (filter.district != null &&
          filter.district!.isNotEmpty &&
          filter.district != ad.district) return false;
      if (filter.subject != null &&
          filter.subject!.isNotEmpty &&
          filter.subject != ad.subject) return false;

      // Fiyat/Bütçe filtresi:
      if (_authController.isTeacher) {
        // Öğretmen girişinde: liste öğrenci taleplerinden oluşuyor, budget kullanılıyor.
        if (filter.minPrice != null &&
            (ad as StudentRequestModel).budget < filter.minPrice!) return false;
        if (filter.maxPrice != null &&
            (ad as StudentRequestModel).budget > filter.maxPrice!) return false;
      } else {
        // Öğrenci girişinde: liste öğretmen ilanlarından oluşuyor, hourlyRate kullanılıyor.
        if (filter.minPrice != null &&
            (ad as TeacherAdModel).hourlyRate < filter.minPrice!) return false;
        if (filter.maxPrice != null &&
            (ad as TeacherAdModel).hourlyRate > filter.maxPrice!) return false;
      }

      // Cinsiyet ve puan filtreleri:
      if (_authController.isTeacher && ad is StudentRequestModel) {
        // Öğretmen girişinde: ilanı paylaşan öğrenci bilgileri üzerinden kontrol.
        final student = studentCache[ad.studentId];
        if (student == null) return false;

        // Cinsiyet filtresi: UI'dan gelen değer "Kadın" veya "Erkek" olarak gelebilir,
        // önce "female"/"male" formatına dönüştürelim.
        if (filter.gender != null && filter.gender!.isNotEmpty) {
          String selectedGender = filter.gender!.toLowerCase();
          if (selectedGender == "kadın") {
            selectedGender = "female";
          } else if (selectedGender == "erkek") {
            selectedGender = "male";
          }
          if ((student.gender ?? "").toLowerCase() != selectedGender)
            return false;
        }

        // Puan filtresi: Öğrencinin rating değeri
        if (filter.minRating != null) {
          final studentRating = student.rating?.toInt() ?? 0;
          if (studentRating < filter.minRating!) return false;
        }
      } else if (!_authController.isTeacher && ad is TeacherAdModel) {
        // Öğrenci girişinde: ilanı paylaşan öğretmen bilgileri üzerinden kontrol.
        final teacher = teacherCache[ad.teacherId];
        if (teacher == null) return false;

        // Cinsiyet filtresi
        if (filter.gender != null && filter.gender!.isNotEmpty) {
          String selectedGender = filter.gender!.toLowerCase();
          if (selectedGender == "kadın") {
            selectedGender = "female";
          } else if (selectedGender == "erkek") {
            selectedGender = "male";
          }
          if ((teacher.gender ?? "").toLowerCase() != selectedGender)
            return false;
        }

        // Puan filtresi: Öğretmenin rating değeri
        if (filter.minRating != null) {
          final teacherRating = teacher.rating?.toInt() ?? 0;
          if (teacherRating < filter.minRating!) return false;
        }
      }

      return true;
    }).toList();

    filteredAdsList.value = filtered;
    print("✅ Filtre sonrası liste uzunluğu: ${filteredAdsList.length}");
  }

  /// İlanı Firestore'a ekler (öğretmen veya öğrenci rolüne göre)
  Future<void> addAd(Map<String, dynamic> adData) async {
    try {
      // Kullanıcının rolüne göre koleksiyon belirle
      final String collectionName =
          _authController.isTeacher ? "teacher_ads" : "student_requests";

      // İlan verisine kullanıcı ID'sini ve oluşturulma tarihini ekle
      adData['createdAt'] = Timestamp.now();

      // Firestore'a ilanı ekle
      await _firestore.collection(collectionName).add(adData);

      // Başarılı mesajı göster
      Get.snackbar(
        'Başarılı',
        'İlan başarıyla eklendi!',
        backgroundColor: Colors.green[100],
      );

      // İlan eklendikten sonra ana sayfaya yönlendir
      Get.offAllNamed(Routes.home); // Yönlendirme burada yapılıyor
    } catch (e) {
      // Hata mesajı göster
      Get.snackbar(
        'Hata',
        'İlan eklenirken bir hata oluştu: $e',
        backgroundColor: Colors.red[100],
      );
      print("❌ İlan eklenirken hata: $e");
    }
  }

  /// Filtreleri güncelle ve yeniden uygula
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
