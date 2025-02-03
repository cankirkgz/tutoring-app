import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/widgets/ad_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final adsController = Get.put(AdsController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            authController.user != null
                ? "Hoş Geldin, ${authController.user!.firstName}!"
                : "Hoş Geldin!",
            style: const TextStyle(color: Colors.white),
          );
        }),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "logout") {
                authController.logout();
              }
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Çıkış Yap"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(
        () {
          if (adsController.adsList.isEmpty) {
            return const Center(child: Text("Henüz bir ilan bulunmuyor"));
          }

          return ListView.builder(
            itemCount: adsController.adsList.length,
            itemBuilder: (context, index) {
              final ad = adsController.adsList[index];

              return AdCard(
                ad: ad,
                authController: authController,
              );
            },
          );
        },
      ),
    );
  }
}
