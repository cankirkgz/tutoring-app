import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Doğrulama Hatası: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        // Kullanıcı doğrulama kodunu girmeli
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
