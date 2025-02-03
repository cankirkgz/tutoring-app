import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/widgets/custom_button.dart';
import 'package:tutoring/views/widgets/custom_text_field.dart';

class ForgotPasswordView extends StatelessWidget {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ForgotPasswordView({super.key});

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Şifremi Unuttum",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Şifrenizi sıfırlamak için kayıtlı e-posta adresinizi girin",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  hintText: "Kayıtlı E-posta Adresiniz",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (!GetUtils.isEmail(value!)) {
                      return 'Geçerli bir e-posta girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                CustomButton(
                  text: "Gönder",
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Get.find<AuthController>()
                          .resetPassword(_emailController.text.trim());
                    }
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Get.offAllNamed(Routes.login),
                    child: Text(
                      "Giriş Yap Sayfasına Dön",
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
