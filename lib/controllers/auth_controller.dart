import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  UserModel? get user => _user.value;
  Rx<UserModel?> get rxUser => _user; // Yeni eklenen getter
  set user(UserModel? value) => _user.value = value;

  @override
  void onInit() {
    super.onInit();
    // Kullanıcı oturum durumunu dinle
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Firebase kullanıcısı varsa, Firestore'dan kullanıcı verilerini çek
        await _fetchUserData(firebaseUser.uid);
        // Token kontrolü yap ve güncelle
        await checkAndUpdateFCMToken();
      } else {
        // Kullanıcı oturumu kapalıysa null yap
        _user.value = null;
      }
    });

    // Token değişikliklerini dinle
    _setupTokenRefreshListener();
  }

  // Firestore'dan kullanıcı verilerini çek
  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user.value = UserModel.fromJson(doc.data()!, uid);

        // Kullanıcı verileri çekildiğinde ilanları da çek
        Get.find<AdsController>().fetchAdsBasedOnRole();
      }
    } catch (e) {
      Get.snackbar('Hata', 'Kullanıcı verileri alınamadı: ${e.toString()}');
    }
  }

  bool get isTeacher => user?.role == "teacher";

  // Giriş Yap
  Future<void> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fetchUserData(userCredential.user!.uid);
      await checkAndUpdateFCMToken(); // Token kontrolü yap ve güncelle
      Get.offAllNamed(Routes.home);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Hata',
        e.message ?? 'Giriş yapılamadı',
        backgroundColor: Colors.red[100],
      );
    }
  }

  // AuthController'a ekle
  UserModel? getUserByIdSync(String userId) {
    return _user.value?.uid == userId
        ? _user.value
        : null; // Basit bir örnek, gerçek uygulamada cache mekanizması gerekir
  }

  // Kayıt Ol
  Future<void> register(String email, String password, String phone) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toJson());

      // Kayıt sonrası kullanıcıyı rol seçme ekranına yönlendir
      Get.offAllNamed(Routes.roleSelection);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Hata',
        e.message ?? 'Kayıt işlemi başarısız oldu',
        backgroundColor: Colors.red[100],
      );
    }
  }

  // Şifre Sıfırlama
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Başarılı',
        'Şifre sıfırlama bağlantısı gönderildi',
        backgroundColor: Colors.green[100],
      );
      Get.offAllNamed(Routes.login);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Hata',
        e.message ?? 'Şifre sıfırlama işlemi başarısız',
        backgroundColor: Colors.red[100],
      );
    }
  }

  // Kullanıcı Rolünü Kaydet
  Future<void> saveUserRole(String role) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'role': role,
        });

        // Kullanıcı verilerini güncelle
        await _fetchUserData(currentUser.uid);

        // Profil tamamlanmış mı kontrol et
        if (_user.value?.firstName == null || _user.value?.firstName == '') {
          Get.offAllNamed(Routes.profileCompletion);
        } else {
          Get.offAllNamed(Routes.home);
        }
      }
    } catch (e) {
      Get.snackbar('Hata', 'Rol kaydedilemedi: ${e.toString()}');
    }
  }

  // Profil Güncelleme
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.uid).update(
            updatedUser.toJson(),
          );
      await _fetchUserData(updatedUser.uid); // Kullanıcı verilerini yenile
      Get.snackbar(
        'Başarılı',
        'Profil güncellendi',
        backgroundColor: Colors.green[100],
      );
    } catch (e) {
      Get.snackbar('Hata', 'Profil güncellenemedi: ${e.toString()}');
    }
  }

  // Token'ı kontrol et ve güncelle
  Future<void> checkAndUpdateFCMToken() async {
    print("🔵 FCM token kontrol ediliyor ve güncelleniyor...");
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      var token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("🟢 Yeni FCM token alındı: $token");
        await saveFCMToken(token); // Yeni token'ı kaydet
        print("🟢 FCM token Firestore'a kaydedildi.");
      } else {
        print("❌ FCM token alınamadı.");
      }
    } else {
      print("❌ Kullanıcı oturumu açık değil, token güncellenemedi.");
    }
  }

  // FCM Token Kaydet
  Future<String?> saveFCMToken(String token) async {
    print("🔵 FCM token Firestore'a kaydediliyor...");
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'fcmToken': token,
        });
        print("🟢 FCM token Firestore'a başarıyla kaydedildi.");
        return token;
      }
    } catch (e) {
      print("❌ FCM Token kaydedilirken hata oluştu: $e");
    }
    return null;
  }

  Future<String?> getFcmTokenByUserId(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('fcmToken')) {
          return data['fcmToken'] as String?;
        }
      }
    } catch (e) {
      print("FCM Token verisi alınırken hata oluştu: $e");
    }
    return null;
  }

  // Token değişikliklerini dinle
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await saveFCMToken(newToken); // Yeni token'ı kaydet
    });
  }

  // 🔹 **Öğrenciyi Öğretmene Ekleme**
  Future<void> becomeStudent(String teacherId) async {
    final user = _user.value;
    if (user == null || user.role != "student") {
      Get.snackbar("Hata", "Bu işlemi sadece öğrenciler yapabilir!");
      return;
    }

    final studentId = user.uid;
    final teacherRef = _firestore.collection('users').doc(teacherId);
    final studentRef = _firestore.collection('users').doc(studentId);

    try {
      await _firestore.runTransaction((transaction) async {
        final teacherDoc = await transaction.get(teacherRef);
        final studentDoc = await transaction.get(studentRef);

        if (!teacherDoc.exists || !studentDoc.exists) {
          throw Exception("Kullanıcı bulunamadı.");
        }

        final List<String> allStudents =
            List<String>.from(teacherDoc['allStudents'] ?? []);
        final List<String> currentStudents =
            List<String>.from(teacherDoc['currentStudents'] ?? []);
        final List<String> teachers =
            List<String>.from(studentDoc['teachers'] ?? []);

        if (!allStudents.contains(studentId)) allStudents.add(studentId);
        if (!currentStudents.contains(studentId))
          currentStudents.add(studentId);
        if (!teachers.contains(teacherId)) teachers.add(teacherId);

        transaction.update(teacherRef, {
          'allStudents': allStudents,
          'currentStudents': currentStudents,
        });

        transaction.update(studentRef, {
          'teachers': teachers,
        });
      });

      // Kullanıcı verilerini güncelle: removeStudent metodunda olduğu gibi.
      await _fetchUserData(user.uid);

      Get.snackbar(
        "Başarılı",
        "Artık bu öğretmenin öğrencisisiniz.",
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Bir hata oluştu: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // �� **Öğrenciyi Öğretmenden Çıkarma**
  Future<void> removeStudent(String teacherId) async {
    final user = _user.value;
    if (user == null || user.role != "student") {
      Get.snackbar("Hata", "Bu işlemi sadece öğrenciler yapabilir!");
      return;
    }

    final studentId = user.uid;
    final teacherRef = _firestore.collection('users').doc(teacherId);
    final studentRef = _firestore.collection('users').doc(studentId);

    try {
      await _firestore.runTransaction((transaction) async {
        final teacherDoc = await transaction.get(teacherRef);
        final studentDoc = await transaction.get(studentRef);

        if (!teacherDoc.exists || !studentDoc.exists) {
          throw Exception("Kullanıcı bulunamadı.");
        }

        // Listeleri güncelle
        final List<String> currentStudents =
            List<String>.from(teacherDoc['currentStudents'] ?? []);
        final List<String> teachers =
            List<String>.from(studentDoc['teachers'] ?? []);

        // Listelerden çıkar
        currentStudents.remove(studentId);
        teachers.remove(teacherId);

        // Firestore'u güncelle
        transaction.update(teacherRef, {
          'currentStudents': currentStudents,
        });

        transaction.update(studentRef, {
          'teachers': teachers,
        });
      });

      // Kullanıcı verilerini yenile
      await _fetchUserData(user.uid);

      Get.snackbar("Başarılı", "Artık bu öğretmenin öğrencisi değilsiniz.",
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
    } catch (e) {
      Get.snackbar("Hata", "Bir hata oluştu: $e",
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
    }
  }

  // Çıkış Yap
  Future<void> logout() async {
    await _auth.signOut();
    _user.value = null;
    Get.find<AdsController>().adsList.clear(); // Yeni eklenen satır
    Get.offAllNamed(Routes.login);
  }

  void checkProfileCompletion() {
    if (_user.value?.firstName == null) {
      Get.offAllNamed(Routes.profileCompletion);
    }
  }

  // Firestore'dan belirli bir kullanıcıyı ID'ye göre getir
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, userId);
      }
    } catch (e) {
      print("Kullanıcı bilgisi alınamadı: $e");
    }
    return null;
  }
}
