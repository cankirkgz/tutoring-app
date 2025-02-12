import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/controllers/messages_controller.dart';
import 'package:tutoring/views/auth/auth_wrapper.dart';
import 'package:tutoring/views/auth/forgot_password_view.dart';
import 'package:tutoring/views/auth/login_view.dart';
import 'package:tutoring/views/auth/onboarding_view.dart';
import 'package:tutoring/views/auth/register_view.dart';
import 'package:tutoring/views/auth/role_selection_view.dart';
import 'package:tutoring/views/home/chat_screen.dart';
import 'package:tutoring/views/home/home_screen.dart';
import 'package:tutoring/views/home/messages_list_view.dart';
import 'package:tutoring/views/home/post_ad_view.dart';
import 'package:tutoring/views/profile/profile_completion_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  Get.put(AdsController());
  Get.put(MessagesController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Private Tutoring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
      getPages: [
        GetPage(name: Routes.onboarding, page: () => OnboardingView()),
        GetPage(name: Routes.login, page: () => LoginScreen()),
        GetPage(name: Routes.register, page: () => RegisterView()),
        GetPage(name: Routes.home, page: () => HomeScreen()),
        GetPage(name: Routes.forgotPassword, page: () => ForgotPasswordView()),
        GetPage(name: Routes.roleSelection, page: () => RoleSelectionView()),
        GetPage(
            name: Routes.profileCompletion,
            page: () => ProfileCompletionView()),
        GetPage(name: Routes.postAd, page: () => PostAdView()),
        GetPage(name: Routes.messages, page: () => MessagesListView()),
        GetPage(
            name: Routes.chat,
            page: () => ChatScreen(chatId: '', receiverId: '')),
      ],
    );
  }
}
