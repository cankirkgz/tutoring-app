import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/widgets/custom_button.dart';
import 'package:tutoring/views/widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hoş Geldiniz!",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Devam etmek için lütfen giriş yapın",
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
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                hintText: "Şifreniz",
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.forgotPassword),
                  child: Text(
                    "Şifremi Unuttum?",
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              CustomButton(
                text: "Giriş Yap",
                backgroundColor: Colors.green,
                textColor: Colors.white,
                onPressed: () => Get.find<AuthController>().login(
                  _emailController.text,
                  _passwordController.text,
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.register),
                  child: RichText(
                    text: TextSpan(
                      text: "Hesabınız yok mu? ",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                      children: [
                        TextSpan(
                          text: "Kayıt Ol",
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
    );
  }
}
