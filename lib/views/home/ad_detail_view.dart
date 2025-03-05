import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/controllers/messages_controller.dart';
import 'package:tutoring/data/models/student_request_model.dart';
import 'package:tutoring/data/models/teacher_ad_model.dart';
import 'package:tutoring/data/models/user_model.dart';
import 'package:tutoring/views/home/chat_screen.dart';
import 'package:tutoring/views/profile/profile_view.dart';
import 'package:tutoring/views/widgets/custom_button.dart';

class AdDetailView extends StatelessWidget {
  final dynamic ad;

  const AdDetailView({super.key, required this.ad})
      : assert(ad is TeacherAdModel || ad is StudentRequestModel,
            'Only TeacherAdModel or StudentRequestModel accepted');

  @override
  Widget build(BuildContext context) {
    final isTeacherAd = ad is TeacherAdModel;
    final authController = Get.find<AuthController>();
    final messagesController = Get.put(MessagesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ad.title,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: authController.getUserById(isTeacherAd
            ? (ad as TeacherAdModel).teacherId
            : (ad as StudentRequestModel).studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('User not found'));
          }

          final user = snapshot.data!;
          final rating = user.rating ?? 0.0;
          final createdAt = ad.createdAt;
          final timeAgo = _formatTimeAgo(createdAt);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context, isTeacherAd, timeAgo),
                const SizedBox(height: 24),
                _buildUserInfoSection(user, rating.toDouble(), ad),
                const SizedBox(height: 24),
                _buildDetailsSection(context, isTeacherAd),
                const SizedBox(height: 24),
                if (ad.description != null && ad.description.isNotEmpty)
                  _buildDescriptionSection(),
                const SizedBox(height: 24),
                if (ad.images != null && ad.images!.isNotEmpty)
                  _buildImageGallery(),
                const SizedBox(height: 24),
                _buildActionButton(messagesController, user.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      MessagesController messagesController, String receiverId) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Mesaj Gönder',
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
        onPressed: () async {
          final existingChatId =
              await messagesController.getExistingChatId(receiverId);
          if (existingChatId != null) {
            Get.to(() =>
                ChatScreen(chatId: existingChatId, receiverId: receiverId));
          } else {
            final chatId = await messagesController.startNewChat(receiverId);
            if (chatId != null) {
              Get.to(() => ChatScreen(chatId: chatId, receiverId: receiverId));
            } else {
              Get.snackbar('Hata', 'Sohbet başlatılamadı.');
            }
          }
        },
      ),
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, bool isTeacherAd, String timeAgo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ad.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isTeacherAd
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isTeacherAd ? 'Öğretmen İlanı' : 'Öğrenci Talebi',
                style: TextStyle(
                  color: isTeacherAd
                      ? Colors.blue.shade700
                      : Colors.purple.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.circle, size: 4, color: Colors.grey.shade400),
            Text(
              timeAgo,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfoSection(UserModel user, double rating, dynamic ad) {
    return InkWell(
      onTap: () {
        // Profil sayfasına yönlendirme
        Get.to(() => ProfileView(userId: user.uid));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade100, width: 2),
              ),
              child: ClipOval(
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.green.shade600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${ad.city} - ${ad.district}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, bool isTeacherAd) {
    return Column(
      children: [
        DetailItem(
          icon: Icons.school,
          title: 'Ders Konusu',
          value: ad.subject ?? 'Belirtilmemiş',
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        DetailItem(
          icon: isTeacherAd ? Icons.attach_money : Icons.account_balance_wallet,
          title: isTeacherAd ? 'Ücret' : 'Bütçe',
          value: isTeacherAd
              ? '${(ad as TeacherAdModel).hourlyRate}₺/saat'
              : '${(ad as StudentRequestModel).budget}₺',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Açıklama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            ad.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotoğraflar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ad.images!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.network(
                  ad.images![index],
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.cumulativeBytesLoaded /
                              (progress.expectedTotalBytes ?? 1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}

class DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const DetailItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
