import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notifications_screen.dart';

class ViewApplicationsScreen extends StatefulWidget {

  final String jobId;

  const ViewApplicationsScreen({super.key, required this.jobId});

  @override
  State<ViewApplicationsScreen> createState() => _ViewApplicationsState();
}

class _ViewApplicationsState extends State<ViewApplicationsScreen> {


  Future<List<Map<String, dynamic>>>? _applicationsFuture;

  @override
  void initState() {
    super.initState();
    //_applicationsFuture = _fetchApplications();
  }

  Future<List<Map<String, dynamic>>> _fetchApplications() async {
    final proposalsSnapshot = await FirebaseFirestore.instance
        .collection('proposals')
        .where('jobId', isEqualTo: widget.jobId)
        .orderBy('appliedAt', descending: true)
        .get();

    final List<Map<String, dynamic>> proposals = [];

    for (var doc in proposalsSnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      // Check if there's an interview scheduled
      final interviewSnap = await FirebaseFirestore.instance
          .collection('interviews')
          .where('jobId', isEqualTo: widget.jobId)
          .where('userId', isEqualTo: data['userId'])
          .limit(1)
          .get();

      if (interviewSnap.docs.isNotEmpty) {
        data['interviewStatus'] = interviewSnap.docs.first['status'];
        data['interviewId'] = interviewSnap.docs.first.id;
      } else {
        data['interviewStatus'] = 'Not Scheduled';
      }

      proposals.add(data);
    }

    return proposals;
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
            'Applications',
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
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NotificationsScreen()));
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _applicationsFuture ?? _fetchApplications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading applications'));
            }

            final applications = snapshot.data!;
            if (applications.isEmpty) {
              return const Center(child: Text('No applications yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row (Avatar + Info + Resume button)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.deepPurple.shade100,
                              child: Text(
                                app['candidateName'][0].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app['candidateName'],
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(app['candidateEmail']),
                                  Text(app['candidatePhoneNumber']),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.description_outlined),
                              onPressed: () async {
                                final uri = Uri.parse(app['resumeUrl']);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Could not launch resume URL")),
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Status + Applied Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 36.0),
                              child: Text("Applied: ${_formatTimestamp(app['appliedAt'])}"),
                            ),
                            _buildStatusBadge(app['status']),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Divider(thickness: 1.5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Interview Status: ",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  app['interviewStatus'] ?? 'Not Scheduled',
                                  style: TextStyle(
                                    color: app['interviewStatus'] == 'hired'
                                        ? Colors.green
                                        : app['interviewStatus'] == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (app['interviewId'] != null)
                              TextButton(
                                onPressed: () async {
                                  final selected = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Update Interview Status'),
                                      content: const Text('Mark this candidate as hired or rejected.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, 'hired'),
                                            child: const Text('Hired')),
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, 'rejected'),
                                            child: const Text('Rejected')),
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, null),
                                            child: const Text('Cancel')),
                                      ],
                                    ),
                                  );

                                  if (selected != null) {
                                    await FirebaseFirestore.instance
                                        .collection('interviews')
                                        .doc(app['interviewId'])
                                        .update({'status': selected});

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Interview marked as $selected')),
                                    );

                                    setState(() {
                                      _applicationsFuture = _fetchApplications();
                                    });
                                  }
                                },
                                child: const Text("Update"),
                              ),
                          ],
                        ),

                        SizedBox(height: 12,),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                final jobSnap = await FirebaseFirestore.instance
                                    .collection('jobs')
                                    .doc(widget.jobId)
                                    .get();

                                final jobData = jobSnap.data();
                                final requiredPosts = jobData?['requiredPosts'] ?? 0;

                                final submittedCountSnap = await FirebaseFirestore.instance
                                    .collection('proposals')
                                    .where('jobId', isEqualTo: widget.jobId)
                                    .where('status', isEqualTo: 'submitted')
                                    .get();

                                if (submittedCountSnap.size >= requiredPosts) {
                                  FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({
                                    'status': 'inactive'
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Maximum number of submissions reached.")),
                                  );
                                  return;
                                }

                                final selectedDateTime = await _pickDateTime(context);

                                if (selectedDateTime == null) return; // user canceled


                                await FirebaseFirestore.instance
                                    .collection('proposals')
                                    .doc(app['id'])
                                    .update({'status': 'submitted'});

                                final interviewDoc = await FirebaseFirestore.instance.collection('interviews').add({
                                  'jobId': widget.jobId,
                                  'userId': app['userId'],
                                  'recruiterId': FirebaseAuth.instance.currentUser!.uid,
                                  'candidateName': app['candidateName'],
                                  'jobTitle': app['jobTitle'],
                                  'scheduledAt': Timestamp.fromDate(selectedDateTime),
                                  'status': 'pending'
                                });


                                await FirebaseFirestore.instance.collection('notifications').add({
                                  'fromUserId': FirebaseAuth.instance.currentUser!.uid,
                                  'toUserId': app['userId'],
                                  'title': 'Interview Alert',
                                  'description': 'We\'re exited to inform you that your application is accepted for now, so you\'re invited to pass an interview that\'s scheduled for ${Timestamp.fromDate(selectedDateTime)}',
                                  'date': Timestamp.now(),
                                  'image': 'images/notif_bell.png',
                                  'type': 'interview',
                                  'status': 'unread'
                                });

                                if (Timestamp.now().seconds > Timestamp.fromDate(selectedDateTime).seconds) {
                                  await FirebaseFirestore.instance.collection('interviews').doc(interviewDoc.id).update({
                                    'status': 'completed'
                                  });
                                }

                                setState(() => _applicationsFuture = _fetchApplications());
                              },
                              icon: const Icon(Icons.check, color: Colors.green),
                              label: const Text('Submit'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirm'),
                                    content: const Text('Reject this application?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('proposals')
                                      .doc(app['id'])
                                      .delete();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Application rejected')),
                                  );

                                  setState(() => _applicationsFuture = _fetchApplications());
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Reject'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );


                /*return Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Text(app['candidateName'][0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        title: Text(app['candidateName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app['candidateEmail']),
                            Text(app['candidatePhoneNumber']),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.description_outlined),
                          onPressed: () {
                            // TODO: open resume or show detail modal
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Open resume coming soon")),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final data = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();

                          },
                          icon: Icon(Icons.edit, color: Colors.blue),
                          label: Text('Submit'),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Confirm'),
                                content: Text('Reject this application?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).delete();
                              final String recruiterId = FirebaseAuth.instance.currentUser!.uid;
                              await FirebaseFirestore.instance.collection('recruiters').doc(recruiterId).update({
                                'jobCount': FieldValue.increment(-1),
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Application rejected successfully')),
                              );
                            }
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text('Reject'),
                        ),
                      ],
                    )
                  ],
                );*/
              },
            );
          },
        ),
    );
  }
}

Widget _buildStatusBadge(String status) {
  Color color;
  switch (status.toLowerCase()) {
    case 'submitted':
      color = Colors.green;
      break;
    case 'rejected':
      color = Colors.red;
      break;
    default:
      color = Colors.orange; // pending
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );
}


String _formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  return "${date.day}/${date.month}/${date.year}";
}

Future<DateTime?> _pickDateTime(BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

