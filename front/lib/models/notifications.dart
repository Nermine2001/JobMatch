import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationMod {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String title;
  final String description;
  final DateTime date;
  final String image;
  final String type;
  final String status;

  NotificationMod({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.title,
    required this.description,
    required this.date,
    required this.image,
    required this.type,
    required this.status
  });

  factory NotificationMod.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationMod(
      id: doc.id,
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      title: data['title'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      image: data['image'],
      type: data['type'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return ({
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'title': title,
      'description': description,
      'date': date,
      'image': image,
      'type': type,
      'status': status,
    });
  }
}