import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/controllers/ads_controller.dart';
import 'package:tutoring/controllers/messages_controller.dart';
import 'package:tutoring/data/models/student_request_model.dart';
import 'package:tutoring/data/models/teacher_ad_model.dart';
import 'package:tutoring/data/models/user_model.dart';
import 'package:tutoring/views/home/ad_detail_view.dart';
import 'package:tutoring/views/home/chat_screen.dart';
import 'package:tutoring/views/widgets/ad_card.dart';

class ProfileView extends StatefulWidget {
  final String userId;

  const ProfileView({super.key, required this.userId});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController authController = Get.find<AuthController>();
  final AdsController adsController = Get.find<AdsController>();
  bool _isButtonLoading = false;
  late Future<UserModel?> _futureUser;

  @override
  void initState() {
    super.initState();
    // Future'ı initState'te alıyoruz, böylece sadece bir defa çekiliyor.
    _futureUser = authController.getUserById(widget.userId);
  }

  int? _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    return now.year -
        birthDate.year -
        ((now.month < birthDate.month ||
                (now.month == birthDate.month && now.day < birthDate.day))
            ? 1
            : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text('Kullanıcı bulunamadı'));
          }

          final user = snapshot.data!;
          final isCurrentUser = authController.user?.uid == widget.userId;
          final age = _calculateAge(user.birthDate);
          final rating = user.rating ?? 0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (!isCurrentUser)
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.white),
                      onPressed: () async {
                        final messagesController =
                            Get.find<MessagesController>();
                        final chatId = await messagesController
                            .getExistingChatId(widget.userId);
                        if (chatId != null) {
                          Get.to(() => ChatScreen(
                                chatId: chatId,
                                receiverId: widget.userId,
                              ));
                        }
                      },
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileHeader(user, age, rating.toDouble()),
                      const SizedBox(height: 24),
                      _buildActionButtons(user),
                      const SizedBox(height: 24),
                      _buildStatistics(user),
                      const SizedBox(height: 24),
                      _buildUserAds(user),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, int? age, double rating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade100, width: 2),
          ),
          child: ClipOval(
            child: Icon(
              Icons.person,
              size: 60,
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
                '${user.firstName ?? ''} ${user.lastName ?? ''}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (age != null)
                Text(
                  '$age yaş',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              Chip(
                backgroundColor: Colors.green.shade100,
                label: Text(
                  user.role == 'teacher' ? 'Öğretmen' : 'Öğrenci',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/10',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserModel user) {
    final isCurrentUser = authController.user?.uid == user.uid;
    final isTeacher = user.role == 'teacher';
    final currentUser = authController.user;
    final isStudent = currentUser?.role == 'student';

    // Eğer currentUser öğrenci ise, teachers listesinde görüntülenen öğretmenin id'si var mı kontrol ediyoruz.
    final bool isAlreadyStudent = isStudent && currentUser?.teachers != null
        ? currentUser!.teachers!.contains(user.uid)
        : false;

    return Row(
      children: [
        if (isTeacher && !isCurrentUser && isStudent)
          Expanded(
            child: ElevatedButton.icon(
              icon: _isButtonLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isAlreadyStudent ? Icons.person_remove : Icons.group_add,
                    ),
              label: Text(
                  isAlreadyStudent ? 'Öğrencisi Olmaktan Çık' : 'Öğrencisi Ol'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAlreadyStudent
                    ? Colors.red.shade600
                    : Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isButtonLoading
                  ? null
                  : () async {
                      setState(() {
                        _isButtonLoading = true;
                      });
                      try {
                        if (isAlreadyStudent) {
                          await authController.removeStudent(user.uid);
                        } else {
                          await authController.becomeStudent(user.uid);
                        }
                        setState(() {
                          _isButtonLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          _isButtonLoading = false;
                        });
                        Get.snackbar(
                          'Hata',
                          'Bir hata oluştu: $e',
                          backgroundColor: Colors.red[100],
                        );
                      }
                    },
            ),
          ),
        if (isCurrentUser)
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.toNamed(Routes.profileCompletion),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Profili Düzenle'),
            ),
          ),
      ],
    );
  }

  Widget _buildStatistics(UserModel user) {
    // Eğer profil öğretmen ise, aktif öğrenci sayısını dinamik göstermek için StreamBuilder kullanıyoruz.
    if (user.role == 'teacher') {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final teacher = UserModel.fromJson(data, user.uid);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Aktif Öğrenci', '${teacher.currentStudents?.length ?? 0}'),
                _buildStatItem('Tamamlanan Ders', '32'),
                _buildStatItem('Deneyim', '2 Yıl'),
              ],
            ),
          );
        },
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                'Aktif Öğrenci', '${user.currentStudents?.length ?? 0}'),
            _buildStatItem('Tamamlanan Ders', '32'),
            _buildStatItem('Deneyim', '2 Yıl'),
          ],
        ),
      );
    }
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAds(UserModel user) {
    final userAds = adsController.adsList.where((ad) {
      if (ad is TeacherAdModel) return ad.teacherId == user.uid;
      if (ad is StudentRequestModel) return ad.studentId == user.uid;
      return false;
    }).toList();

    if (userAds.isEmpty) {
      return Column(
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Henüz ilan bulunmuyor',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yayınlanan İlanlar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: userAds.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => AdCard(
            ad: userAds[index],
            authController: authController,
            onTap: () => Get.to(() => AdDetailView(ad: userAds[index])),
          ),
        ),
      ],
    );
  }
}
