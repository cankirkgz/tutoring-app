import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String phone;
  final String? role;
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final String? city;
  final DateTime? birthDate;
  final String? bio;
  final num? rating;

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
    );
  }
}
