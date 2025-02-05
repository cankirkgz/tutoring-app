import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/views/home/filter_screen.dart';
import 'package:tutoring/views/home/post_ad_view.dart';
import 'package:tutoring/views/widgets/ad_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // **Controller'ları GetX üzerinden al**
    final authController = Get.find<AuthController>();
    final adsController = Get.put(AdsController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          // **Kullanıcı adı veya hoş geldin mesajı**
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
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => Get.to(() => const FilterScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Get.to(() => PostAdView()),
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
      // Body kısmını güncelleyin
      body: Obx(
        () {
          return RefreshIndicator(
            onRefresh: () async {
              adsController.isLoading.value = true; // Yükleme başladı
              await Future.delayed(const Duration(seconds: 2));
              await adsController.fetchAdsBasedOnRole();
            },
            child: adsController.isLoading.value
                ? _buildShimmerEffect()
                : adsController.filteredAdsList.isEmpty
                    ? Center(child: _buildShimmerEffect())
                    : ListView.builder(
                        itemCount: adsController.filteredAdsList.length,
                        itemBuilder: (context, index) {
                          final ad = adsController.filteredAdsList[index];
                          return AdCard(
                            ad: ad,
                            authController: authController,
                          );
                        },
                      ),
          );
        },
      ),
    );
  }

  // Shimmer efekti widget'ı
  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 10, // Örnek olarak 10 shimmer efekti göster
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 100.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: double.infinity,
                  height: 20.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: 150.0,
                  height: 20.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
