import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackMod {
  final String id;
  final String userId;
  final DateTime createdAt;
  final String feedback;
  final int rate;

  FeedbackMod({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.feedback,
    required this.rate,
  });

  factory FeedbackMod.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackMod(
      id: doc.id,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      feedback: data['feedback'] ?? '',
      rate: (data['rate'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'feedback': feedback,
      'rate': rate,
    };
  }
}
