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
      } else {
        // Kullanıcı oturumu kapalıysa null yap
        _user.value = null;
      }
    });
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
