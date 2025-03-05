import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String phone;
  final String? role; // "teacher" veya "student"
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final String? city;
  final DateTime? birthDate;
  final String? bio;
  final num? rating;
  final String? gender;
  final String? fcmToken;
  final List<String>? allStudents; // Öğretmenin tüm zamanlardaki öğrencileri
  final List<String>? currentStudents; // Öğretmenin güncel öğrencileri
  final List<String>? teachers; // Öğrencinin güncel çalıştığı öğretmenler

  UserModel({
    required this.uid,
    required this.email,
    required this.phone,
    this.role,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.city,
    this.birthDate,
    this.bio,
    this.rating,
    this.gender,
    this.fcmToken,
    this.allStudents,
    this.currentStudents,
    this.teachers,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      firstName: json['firstName'],
      lastName: json['lastName'],
      city: json['city'],
      birthDate: json['birthDate'] != null
          ? (json['birthDate'] as Timestamp).toDate()
          : null,
      bio: json['bio'],
      rating: json['rating'],
      gender: json['gender'],
      fcmToken: json['fcmToken'],
      allStudents: json['allStudents'] != null
          ? List<String>.from(json['allStudents'])
          : [],
      currentStudents: json['currentStudents'] != null
          ? List<String>.from(json['currentStudents'])
          : [],
      teachers:
          json['teachers'] != null ? List<String>.from(json['teachers']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'birthDate': birthDate,
      'bio': bio,
      'rating': rating,
      'gender': gender,
      'fcmToken': fcmToken,
      'allStudents': allStudents ?? [],
      'currentStudents': currentStudents ?? [],
      'teachers': teachers ?? [],
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? firstName,
    String? lastName,
    String? city,
    DateTime? birthDate,
    String? bio,
    num? rating,
    String? gender,
    String? fcmToken,
    List<String>? allStudents,
    List<String>? currentStudents,
    List<String>? teachers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      city: city ?? this.city,
      birthDate: birthDate ?? this.birthDate,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      gender: gender ?? this.gender,
      fcmToken: fcmToken ?? this.fcmToken,
      allStudents: allStudents ?? this.allStudents,
      currentStudents: currentStudents ?? this.currentStudents,
      teachers: teachers ?? this.teachers,
    );
  }
}
