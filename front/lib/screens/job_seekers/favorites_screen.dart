import 'package:flutter/material.dart';
import 'package:jobmatch_app/screens/job_seekers/home_screen.dart';
import 'package:jobmatch_app/screens/filter_screen.dart';
import 'package:jobmatch_app/screens/notifications_screen.dart';
import 'package:jobmatch_app/screens/job_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatefulWidget {
  final Stream<QuerySnapshot> jobsStream;

  const FavoritesScreen({super.key, required this.jobsStream});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? _searchQuery;
  List<String> _favoriteJobs = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteJobs();
  }

  Future<void> _loadFavoriteJobs() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('job_seekers').doc(uid).get();

    setState(() {
      _favoriteJobs = List<String>.from(doc.data()?['favorites'] ?? []);
    });
  }

  void _toggleFavorite(String jobId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isFavorite = _favoriteJobs.contains(jobId);

    setState(() {
      if (isFavorite) {
        _favoriteJobs.remove(jobId);
      } else {
        _favoriteJobs.add(jobId);
      }
    });

    final jobSeekerRef = FirebaseFirestore.instance.collection('job_seekers').doc(uid);
    await jobSeekerRef.update({
      'favorites': isFavorite
          ? FieldValue.arrayRemove([jobId])
          : FieldValue.arrayUnion([jobId]),
    });
  }

  Widget _buildJobCard(String jobId, String company, String position, Map<String, dynamic> salary, List<String> skills, String location, bool isRemote, String type) {
    final isFavorite = _favoriteJobs.contains(jobId);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JobDetailsScreen(jobId: jobId,)),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(company, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey),
                  onPressed: () => _toggleFavorite(jobId),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(position, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text('Salary: ${salary['min']} - ${salary['max']}', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: skills.map((skill) => Chip(label: Text(skill))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdfddf3),
      appBar: AppBar(
        backgroundColor: Color(0xffbfbcf3),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Favorites', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => NotificationsScreen())),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.jobsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final jobs = snapshot.data!.docs.where((job) => _favoriteJobs.contains(job.id)).toList();

          if (jobs.isEmpty) return Center(child: Text("No favorite jobs."));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final jobId = job.id;
              final data = job.data() as Map<String, dynamic>;

              return _buildJobCard(
                jobId,
                data['company'] ?? 'Unknown',
                data['title'] ?? '',
                data['salary'],
                List<String>.from(data['skills'] ?? []),
                data['location'],
                data['remote'],
                data['type']
              );
            },
          );
        },
      ),
    );
  }
}
