import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherAdModel {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final String subject;
  final double hourlyRate;
  final String city;
  final String district;
  final DateTime createdAt;
  final List<String>? images; // Opsiyonel fotoğraflar listesi

  TeacherAdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.subject,
    required this.hourlyRate,
    required this.city,
    required this.district,
    required this.createdAt,
    this.images,
  });

  // Firestore'dan veri çekerken kullanılan factory fonksiyon
  factory TeacherAdModel.fromJson(Map<String, dynamic> json, String id) {
    return TeacherAdModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      teacherId: json['teacherId'] ?? '',
      subject: json['subject'] ?? '',
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  // Firestore’a veri kaydetmek için kullanılan toJson metodu
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'subject': subject,
      'hourlyRate': hourlyRate,
      'city': city,
      'district': district,
      'createdAt': createdAt,
      'images': images ?? [],
    };
  }
}
