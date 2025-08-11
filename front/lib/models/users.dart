
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String fullName;
  final String email;
  final DateTime birthDate;
  final String status;
  final List<String> skills;
  final int experience;
  final String phoneNumber;
  final String location;
  final String profileImageUrl;

  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.birthDate,
    required this.status,
    required this.skills,
    required this.experience,
    required this.phoneNumber,
    required this.location,
    required this.profileImageUrl,
  });

  User copyWith({
    String? fullName,
    String? email,
    DateTime? birthDate,
    String? status,
    List<String>? skills,
    int? experience,
    String? phoneNumber,
    String? location,
    String? profileImageUrl,
  }) {
    return User(
      uid: this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      status: status ?? this.status,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }


  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      fullName: data['fullName'],
      email: data['email'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      status: data['status'],
      skills: List<String>.from(data['skills'] ?? []),
      experience: data['experience'],
      phoneNumber: data['phoneNumber'],
      location: data['location'],
      profileImageUrl: data['profileImageUrl']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'birthDate': birthDate,
      'status': status,
      'skills': skills,
      'experience': experience,
      'phoneNumber': phoneNumber,
      'location': location,
      'profileImageUrl': profileImageUrl,
    };
  }
}