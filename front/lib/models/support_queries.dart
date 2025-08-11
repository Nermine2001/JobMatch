import 'package:cloud_firestore/cloud_firestore.dart';

class SupportQuery {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String userEmail;
  final String status;
  final DateTime createdAt;
  final bool confirmationSent;
  final List<Map<String, dynamic>> responses;
  final String platform;

  SupportQuery({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userEmail,
    required this.status,
    required this.createdAt,
    required this.confirmationSent,
    required this.responses,
    required this.platform,
  });

  factory SupportQuery.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportQuery(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      confirmationSent: data['confirmationSent'] ?? false,
      responses: List<Map<String, dynamic>>.from(data['responses'] ?? []),
      platform: data['platform'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'userEmail': userEmail,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmationSent': confirmationSent,
      'responses': responses,
      'platform': platform,
    };
  }
}
