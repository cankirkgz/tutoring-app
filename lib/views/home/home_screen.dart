// HomeScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/controllers/messages_controller.dart';
import 'package:tutoring/views/home/ad_detail_view.dart';
import 'package:tutoring/views/home/filter_screen.dart';
import 'package:tutoring/views/home/messages_list_view.dart';
import 'package:tutoring/views/home/post_ad_view.dart';
import 'package:tutoring/views/widgets/ad_card.dart';
import 'package:tutoring/data/models/chat_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    // İlk yüklemede 3 saniye shimmer göster
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final adsController = Get.find<AdsController>();
    // Verileri getir
    adsController.fetchAdsBasedOnRole();

    // 3 saniye bekle
    await Future.delayed(const Duration(seconds: 6));

    // İlk yükleme bitti
    setState(() {
      _isInitialLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final adsController = Get.find<AdsController>();
    final messagesController = Get.find<MessagesController>();

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
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => Get.to(() => const FilterScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Get.to(() => PostAdView()),
          ),
          // Mesaj ikonuna badge ekliyoruz:
          // HomeScreen.dart - AppBar içindeki mesaj ikonu kısmı
          StreamBuilder<List<ChatModel>>(
            stream: messagesController.getChats(),
            builder: (context, snapshot) {
              int totalUnread = 0;
              if (snapshot.hasData) {
                totalUnread = snapshot.data!.fold(0, (sum, chat) {
                  if (chat.lastMessageSenderId != authController.user!.uid) {
                    return sum + chat.unreadMessagesCount;
                  }
                  return sum;
                });
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.white),
                    onPressed: () => Get.to(() => MessagesListView()),
                  ),
                  if (totalUnread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          totalUnread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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
      body: _isInitialLoading
          ? _buildShimmerEffect() // İlk 3 saniye shimmer göster
          : Obx(() {
              // 3 saniye sonra normal akış
              if (adsController.isLoading.value) {
                return _buildShimmerEffect();
              } else if (adsController.filteredAdsList.isEmpty) {
                return Center(child: Text("Hiçbir ilan bulunamadı"));
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    adsController.isLoading.value = true;
                    await Future.delayed(const Duration(seconds: 2));
                    await adsController.fetchAdsBasedOnRole();
                  },
                  child: ListView.builder(
                    itemCount: adsController.filteredAdsList.length,
                    itemBuilder: (context, index) {
                      final ad = adsController.filteredAdsList[index];
                      return AdCard(
                        ad: ad,
                        authController: authController,
                        onTap: () => Get.to(() => AdDetailView(ad: ad)),
                      );
                    },
                  ),
                );
              }
            }),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 10,
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
