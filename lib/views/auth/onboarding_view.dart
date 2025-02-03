import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutoring/views/widgets/custom_button_bar.dart';
import 'package:tutoring/views/widgets/custom_image_widget.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Ekranın tamamını kapla
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // 📌 **Buzlu Cam Efekti (Glassmorphism)**
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // 📌 **Ana İçerik**
            SingleChildScrollView(
              child: Column(
                children: [
                  // Resim Alanı
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Hero(
                      tag: 'onboarding-image',
                      child: CustomImageWidget(
                        imagePath: 'assets/illustrations/onboarding.png',
                        backgroundColor: Colors.deepPurple.shade100,
                        borderRadius: 24,
                        padding: 24,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),

                  // Metin İçerik
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Eğitimde Yeni Nesil\nDeneyim",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.deepPurple.shade900,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Alanında uzman eğitmenlerle buluş veya bilgini paylaşarak ek kazanç sağla. "
                          "Haydi sen de aramıza katıl!",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 100),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CustomButtonBar(
                  onRegister: () => Navigator.pushNamed(context, '/register'),
                  onSignIn: () => Navigator.pushNamed(context, '/login'),
                  isLoginSelected: false,
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.15,
              right: -50,
              child: _buildDecorCircle(60, Colors.deepPurple.withOpacity(0.1)),
            ),
            Positioned(
              bottom: size.height * 0.2,
              left: -30,
              child: _buildDecorCircle(80, Colors.blue.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
