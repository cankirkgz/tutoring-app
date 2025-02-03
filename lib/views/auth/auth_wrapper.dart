import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/auth/onboarding_view.dart';
import 'package:tutoring/views/home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (authController.user != null) {
        return HomeScreen(); // Kullanıcı giriş yaptıysa HomeScreen'e git
      } else {
        return OnboardingView(); // Kullanıcı giriş yapmadıysa Onboarding'e git
      }
    });
  }
}
