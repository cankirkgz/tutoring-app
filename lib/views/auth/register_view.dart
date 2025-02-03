import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/widgets/custom_button.dart';
import 'package:tutoring/views/widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // AuthController üzerinden kayıt işlemini başlat
        await Get.find<AuthController>().register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          "+90${_phoneController.text.trim()}", // +90 ekleniyor
        );

        // Kayıt başarılıysa direkt olarak Rol Seçme Sayfasına yönlendir
        Get.offAllNamed(Routes.roleSelection);
      } on FirebaseAuthException catch (e) {
        // Hata durumunda kullanıcıyı bilgilendir
        Get.snackbar(
          'Hata',
          e.message ?? 'Kayıt işlemi başarısız oldu.',
          backgroundColor: Colors.red[100],
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hesap Oluştur",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Eğitim yolculuğuna başlamak için kayıt ol",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 40),
                    CustomTextField(
                      controller: _emailController,
                      hintText: "E-posta Adresiniz",
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (!GetUtils.isEmail(value!)) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: "Şifre (min 6 karakter)",
                      isPassword: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value!.length < 6) {
                          return 'Şifre en az 6 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: "Şifreyi Tekrar Girin",
                      isPassword: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_reset,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Şifreler eşleşmiyor';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: "Telefon Numarası (5XX XXX XX XX)",
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.length < 10) {
                          return 'Geçerli bir telefon numarası girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    CustomButton(
                      text: "Kayıt Ol",
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      onPressed: _register,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Get.offAllNamed(Routes.login),
                        child: RichText(
                          text: TextSpan(
                            text: "Zaten hesabın var mı? ",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                            children: [
                              TextSpan(
                                text: "Giriş Yap",
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
