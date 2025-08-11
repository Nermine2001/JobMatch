import 'package:cloud_firestore/cloud_firestore.dart';

class Interview {
  final String id;
  final String jobId;
  final String userId;
  final String recruiterId;
  final String candidateName;
  final String jobTitle;
  final DateTime scheduledAt;
  final String status;

  Interview({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.recruiterId,
    required this.candidateName,
    required this.jobTitle,
    required this.scheduledAt,
    required this.status,
  });

  factory Interview.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Interview(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      userId: data['userId'] ?? '',
      recruiterId: data['recruiterId'] ?? '',
      candidateName: data['candidateName'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'recruiterId': recruiterId,
      'candidateName': candidateName,
      'jobTitle': jobTitle,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status,
    };
  }
}
