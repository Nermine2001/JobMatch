import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../notifications_screen.dart';

class YourApplicationsScreen extends StatefulWidget {
  const YourApplicationsScreen({super.key});

  @override
  State<YourApplicationsScreen> createState() => _YourApplicationsScreenState();
}

class _YourApplicationsScreenState extends State<YourApplicationsScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<Map<String, dynamic>>> _combinedDataFuture;

  @override
  void initState() {
    super.initState();
    _combinedDataFuture = _fetchApplicationsAndInterviews();
  }

  Future<List<Map<String, dynamic>>> _fetchApplicationsAndInterviews() async {
    final proposalsSnapshot =
        await FirebaseFirestore.instance
            .collection('proposals')
            .where('userId', isEqualTo: currentUserId)
            .get();

    final interviewsSnapshot =
        await FirebaseFirestore.instance
            .collection('interviews')
            .where('userId', isEqualTo: currentUserId)
            .get();

    final interviewMap = {
      for (var doc in interviewsSnapshot.docs) doc['jobId']: doc.data(),
    };

    final combinedList =
        proposalsSnapshot.docs.map((doc) {
          final proposalData = doc.data();
          final jobId = proposalData['jobId'];
          final interviewData = interviewMap[jobId];

          return {...proposalData, 'interview': interviewData};
        }).toList();

    return combinedList;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('yMMMd – HH:mm').format(date);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdfddf3),
      appBar: AppBar(
        backgroundColor: Color(0xffbfbcf3),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: Text(
          'My Applications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _combinedDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No applications found.'));
          }

          final applications = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(12.0),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final interview = app['interview'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app['jobTitle'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20,),
                      Text('🏢 ${app['companyName']}'),
                      SizedBox(height: 8,),
                      Text('📅 Applied: ${_formatDate(app['appliedAt'])}'),
                      SizedBox(height: 8,),
                      Text('📌 Status: ${app['status']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 14),
                      Divider(thickness: 1.5,),
                      SizedBox(height: 8,),
                      if (interview != null)
                        Text('📞 Interview: ${_formatDate(interview!.scheduledAt)} @ ${interview!.location}',
                            style: const TextStyle(color: Colors.green)),
                      if (interview == null)
                        const Text('📞 Interview: None', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
