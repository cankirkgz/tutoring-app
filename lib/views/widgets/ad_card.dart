import 'package:flutter/material.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/data/models/teacher_ad_model.dart';
import 'package:tutoring/data/models/student_request_model.dart';
import 'package:tutoring/data/models/user_model.dart';

class AdCard extends StatelessWidget {
  final dynamic ad;
  final AuthController authController;

  const AdCard({
    super.key,
    required this.ad,
    required this.authController,
  }) : assert(ad is TeacherAdModel || ad is StudentRequestModel,
            'Only TeacherAdModel or StudentRequestModel accepted');

  @override
  Widget build(BuildContext context) {
    final isTeacherAd = ad is TeacherAdModel;
    final userId = _getUserId();
    final subject = _getSubject();
    final priceInfo = _getPriceInfo();
    final description = _getDescription();
    final images = _getImages();

    return FutureBuilder<UserModel?>(
      future: authController.getUserById(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final rating = user?.rating ?? 0.0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve Tip Etiketi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildTypeChip(isTeacherAd),
                  ],
                ),
                const SizedBox(height: 8),

                // Puan ve Lokasyon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      backgroundColor: Colors.amber.shade100,
                      label: Text(
                        '${rating.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
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
                  ],
                ),
                const SizedBox(height: 12),

                // Ders/Ücret Bilgisi
                if (subject != null || priceInfo != null)
                  Row(
                    children: [
                      Icon(
                        isTeacherAd ? Icons.school : Icons.request_page,
                        color: Colors.blue.shade800,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      if (subject != null)
                        Text(
                          subject,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      if (priceInfo != null)
                        Text(
                          ' • $priceInfo',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),

                // Açıklama
                if (description != null && description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),

                // Fotoğraflar
                if (images != null && images.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[index],
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                // İlan Sahibi ve Tarih
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${user?.firstName ?? 'Bilinmeyen'} ${user?.lastName ?? ''}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (ad.createdAt != null)
                        Text(
                          _formatDate(ad.createdAt!),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeChip(bool isTeacherAd) {
    return Chip(
      backgroundColor:
          isTeacherAd ? Colors.blue.shade100 : Colors.purple.shade100,
      label: Text(
        isTeacherAd ? 'Öğretmen' : 'Öğrenci',
        style: TextStyle(
          color: isTeacherAd ? Colors.blue.shade800 : Colors.purple.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper Methods
  String _getUserId() {
    if (ad is TeacherAdModel) {
      return (ad as TeacherAdModel).teacherId;
    } else {
      return (ad as StudentRequestModel).studentId;
    }
  }

  String? _getSubject() {
    if (ad is TeacherAdModel) {
      return (ad as TeacherAdModel).subject;
    } else {
      return (ad as StudentRequestModel).subject;
    }
  }

  String? _getPriceInfo() {
    if (ad is TeacherAdModel) {
      return '${(ad as TeacherAdModel).hourlyRate}₺/saat';
    } else if ((ad as StudentRequestModel).budget != null) {
      return 'Bütçe: ${(ad as StudentRequestModel).budget}₺';
    }
    return null;
  }

  String? _getDescription() {
    if (ad is TeacherAdModel) {
      return (ad as TeacherAdModel).description;
    } else {
      return (ad as StudentRequestModel).description;
    }
  }

  List<String>? _getImages() {
    if (ad is TeacherAdModel) {
      return (ad as TeacherAdModel).images;
    } else {
      return (ad as StudentRequestModel).images;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
