import 'package:cloud_firestore/cloud_firestore.dart';

class Recommendation {
  final String id;
  final String userId;
  final String jobId;
  final String title;
  final String company;
  final String location;
  final double probability;
  final String confidence;
  final List<String> matchReasons;
  final DateTime timestamp;

  Recommendation({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.title,
    required this.company,
    required this.location,
    required this.probability,
    required this.confidence,
    required this.matchReasons,
    required this.timestamp,
  });

  factory Recommendation.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recommendation(
      id: doc.id,
      userId: data['userId'] ?? '',
      jobId: data['jobId'] ?? '',
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      probability: (data['probability'] as num?)?.toDouble() ?? 0.0,
      confidence: data['confidence'] ?? '',
      matchReasons: List<String>.from(data['matchReasons'] ?? []),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'jobId': jobId,
      'title': title,
      'company': company,
      'location': location,
      'probability': probability,
      'confidence': confidence,
      'matchReasons': matchReasons,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
