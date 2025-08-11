import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobmatch_app/screens/recruiters/home_screen_rec.dart';
import 'package:jobmatch_app/screens/recruiters/view_applications_screen.dart';

import '../job_details_screen.dart';
import 'add_or_edit_offer_screen.dart';

class YourOffersScreen extends StatefulWidget {

  final List<String> favoriteJobs;
  final Function(String jobId) onToggleFavorite;
  final Stream<QuerySnapshot> jobsStream;
  const YourOffersScreen({super.key, required this.jobsStream, required this.favoriteJobs, required this.onToggleFavorite});

  @override
  State<YourOffersScreen> createState() => _YourOffersScreenState();
}

class _YourOffersScreenState extends State<YourOffersScreen> {

  Widget _buildJobCard(String jobId, String company, String position, Map<String, dynamic> salary, List<String> skills, String location, bool isRemote, String type) {
    //bool isFavorite = widget.favoriteJobs.contains(jobId);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsScreen(jobId: jobId,))),
      child: Container(
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
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Salary: ${salary['min'] ?? 'N/A'} - ${salary['max'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            isRemote ? 'Remote' : 'Non Remote',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                /*IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                  onPressed: () => widget.onToggleFavorite(jobId),
                ),*/
                //Icon(Icons.favorite_border, color: Colors.grey, size: 25),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: skills.map((skill) =>
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF6B46C1).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
            ),
            SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    // final data = await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewApplicationsScreen(jobId: jobId),
                      ),
                    );
                  },
                  icon: Icon(Icons.remove_red_eye_outlined, color: Colors.green),
                  label: Text('View applications'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final data = await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddOrEditOfferScreen(
                          jobId: jobId,
                          initialData: {
                            'title': position,
                            'company': company,
                            'description': data['description'] ?? '',
                            'skills': skills,
                            'salary': salary,
                            'location': data['location'] ?? '',
                            'type': type,
                            'remote': isRemote,
                            'period': data['period'] ?? '',
                            'age': data['age'] ?? '',
                            'experience': data['experience']?.toString(),
                            'category': data['category'] ?? '...',
                            'requiredPosts': data['requiredPosts']?.toString()
                          },
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit, color: Colors.blue),
                  label: Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Confirm'),
                        content: Text('Delete this offer?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
                      final String recruiterId = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance.collection('recruiters').doc(recruiterId).update({
                        'jobCount': FieldValue.increment(-1),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Offer deleted successfully')),
                      );
                    }
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
           /*SizedBox(height: 15,),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Column(
                 children: [
                   Container(
                       decoration: BoxDecoration(
                         color: Color(0xfff1feac),
                         shape: BoxShape.circle
                       ),
                       child: IconButton(
                           onPressed: () {},
                           icon: Icon(
                             Icons.add,
                             size: 30,
                           )
                       )
                   ),
                   SizedBox(height: 8.0,),
                   Text('Add a new offer')
                 ],
               )
             ],
           ),*/
           SizedBox(height: 15,),
           Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: widget.jobsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No jobs found.'));
            }

            final jobs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                final jobId = job.id;
                final data = job.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    _buildJobCard(
                      jobId,
                      data['company'] ?? 'Unknown',
                      data['title'] ?? '',
                      data['salary'],
                      List<String>.from(data['skills'] ?? []),
                      data['location'],
                      data['remote'],
                      data['type']
                    ),
                    SizedBox(height: 12),
                  ],
                );
              },
            );
          },
        ),
      ),
        ],
      ),
    );
  }
}
