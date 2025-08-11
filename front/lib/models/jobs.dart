import 'package:cloud_firestore/cloud_firestore.dart';

class Job {

  final String id;
  final String recruiterId;
  final String company;
  final String description;
  final String category;
  final List<String> skills;
  final int experience;
  final Map<String, dynamic> salary;
  final String location;
  final String type;
  final bool remote;
  final DateTime postedAt;
  final String period;
  final Map<String, dynamic> age;
  final int requiredPosts;
  final int proposals;
  final String status;
  final int views;

  Job({
    required this.id,
    required this.recruiterId,
    required this.company,
    required this.description,
    required this.category,
    required this.skills,
    required this.experience,
    required this.salary,
    required this.location,
    required this.type,
    required this.remote,
    required this.postedAt,
    required this.period,
    required this.age,
    required this.requiredPosts,
    required this.proposals,
    required this.status,
    required this.views


  });

  factory Job.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      recruiterId: data['recruiterId'],
      company: data['company'],
      description: data['description'],
      category: data['category'],
      skills: List<String>.from(data['skills'] ?? []),
      experience: data['experience'],
      salary: Map<String, dynamic>.from(data['salary'] ?? {}),
      location: data['location'],
      type: data['type'],
      remote: data['remote'],
      postedAt: (data['postedAt'] as Timestamp).toDate(),
      period: data['period'],
      age: Map<String, dynamic>.from(data['age'] ?? {}),
      requiredPosts: data['requiredPosts'],
      proposals: data['proposals'],
      status: data['status'],
      views: data['views']
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'recruiterId': recruiterId,
      'company': company,
      'description': description,
      'category': category,
      'skills': skills,
      'experience': experience,
      'salary': salary,
      'location': location,
      'type': type,
      'remote': remote,
      'postedAt': postedAt,
      'period': period,
      'age': age,
      'requiredPosts': requiredPosts,
      'proposals': proposals,
      'status': status,
      'views': views
    };
  }
}