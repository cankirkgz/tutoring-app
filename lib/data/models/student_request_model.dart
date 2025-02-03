import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRequestModel {
  final String id;
  final String title;
  final String description;
  final String studentId;
  final String subject;
  final String city;
  final String district;
  final DateTime createdAt;
  final List<String>? images; // Opsiyonel fotoğraflar listesi
  final int budget;

  StudentRequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.studentId,
    required this.subject,
    required this.city,
    required this.district,
    required this.createdAt,
    this.images,
    required this.budget,
  });

  factory StudentRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return StudentRequestModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      studentId: json['studentId'] ?? '',
      subject: json['subject'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      budget: json['budget'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'studentId': studentId,
      'subject': subject,
      'city': city,
      'district': district,
      'createdAt': createdAt,
      'images': images ?? [],
      'budget': budget,
    };
  }
}
