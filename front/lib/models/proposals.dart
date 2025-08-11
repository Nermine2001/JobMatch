import 'package:cloud_firestore/cloud_firestore.dart';

class Proposal {
  final String id;
  final String jobTitle;
  final String candidateName;
  final String companyName;
  final String candidateEmail;
  final String candidatePhoneNumber;
  final String candidateProfileUrl;
  final String resumeUrl;
  final String userId;
  final String jobId;
  final String status;
  final DateTime appliedAt;
  final DateTime submittedAt;

  Proposal({
    required this.id,
    required this.jobTitle,
    required this.candidateName,
    required this.companyName,
    required this.candidateEmail,
    required this.candidatePhoneNumber,
    required this.candidateProfileUrl,
    required this.resumeUrl,
    required this.userId,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    required this.submittedAt,
  });

  factory Proposal.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Proposal(
      id: doc.id,
      jobTitle: data['jobTitle'] ?? '',
      candidateName: data['candidateName'] ?? '',
      companyName: data['companyName'] ?? '',
      candidateEmail: data['candidateEmail'] ?? '',
      candidatePhoneNumber: data['candidatePhoneNumber'] ?? '',
      candidateProfileUrl: data['candidateProfileUrl'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      userId: data['userId'] ?? '',
      jobId: data['jobId'] ?? '',
      status: data['status'] ?? '',
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobTitle': jobTitle,
      'candidateName': candidateName,
      'companyName': companyName,
      'candidateEmail': candidateEmail,
      'candidatePhoneNumber': candidatePhoneNumber,
      'candidateProfileUrl': candidateProfileUrl,
      'resumeUrl': resumeUrl,
      'userId': userId,
      'jobId': jobId,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}
