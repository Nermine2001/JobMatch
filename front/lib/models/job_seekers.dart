import 'package:cloud_firestore/cloud_firestore.dart';

class JobSeeker {
  final String uid;
  final Map<String, dynamic> preferences;
  final List<String> favorites;
  final List<Map<String, dynamic>> viewHistory;
  final String userId;

  JobSeeker({
    required this.uid,
    required this.preferences,
    required this.favorites,
    required this.viewHistory,
    required this.userId,
  });

  factory JobSeeker.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobSeeker(
        uid: doc.id,
        preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
        favorites: List<String>.from(data['favorites'] ?? []),
        viewHistory: List<Map<String, dynamic>>.from(data['viewHistory'] ?? []),
        userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preferences': preferences,
      'favorites': favorites,
      'viewHistory': viewHistory,
      'userId': userId,
    };
  }
}