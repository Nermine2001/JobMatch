import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'job_seekers/application_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late Future<DocumentSnapshot> _job;

  String? currentUserStatus;

  Future<Map<String, dynamic>> fetchJobWithPublisher() async {
    final jobDoc = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();
    final jobData = jobDoc.data()!;

    final publisherId = jobData['userId'];
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(publisherId).get();
    final userData = userDoc.data()!;




    return {
      'job': jobData,
      'user': userData,
    };
  }

  late DateTime _entryTime;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(currentUserId).get().then((doc) {
      if (doc.exists) {
        setState(() {
          currentUserStatus = doc['status'];
        });
      }
    });
  }

  @override
  void dispose() {
    final exitTime = DateTime.now();
    final duration = exitTime.difference(_entryTime);
    final durationInSeconds = duration.inSeconds;

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('job_seekers').doc(currentUserId).update({
      'viewHistory': FieldValue.arrayUnion([
        {
          'jobId': widget.jobId,
          'timestamp': Timestamp.fromDate(_entryTime),
          'duration': durationInSeconds,
        }
      ])
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: fetchJobWithPublisher(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final job = snapshot.data!['job'];
          final user = snapshot.data!['user'];
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
                job['title'],
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
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 130,
                    width: 450,
                    color: Color(0xfff1feac),
                    child: Row(
                      children: [
                        SizedBox(width: 15,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: user['profileImageUrl'] != null ? NetworkImage(user['profileImageUrl']) : AssetImage('images/default_avatar.jpg'),
                            )
                          ],
                        ),
                        SizedBox(width: 15,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user['fullName'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 8,),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  job['location'],
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: 45,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              (job['postedAt'] as Timestamp).toDate().toString().split(' ')[0],
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            SizedBox(height: 8,),
                            Container(
                              height: 30,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Color(0xffbfbcf3),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Center(
                                child: Text(
                                  job['company'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15,)
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 25,),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About the offer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        SizedBox(height: 15,),
                        Text(
                          job['description'],
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 35,),
                        Text(
                          'Debut Date',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                        SizedBox(height: 15,),
                        Text(
                          'As soon As possible',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25,),
                  Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requirements',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                          SizedBox(height: 15,),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: (job['skills'] as List<dynamic>).map((skill) =>
                                Container(
                                  width: 90,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6B46C1).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      skill,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )).toList(),
                          ),
                        ],
                      ),
                  ),
                  SizedBox(height: 35,),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Salary',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            SizedBox(width: 35,),
                            Container(
                              height: 30,
                              width: 210,
                              decoration: BoxDecoration(
                                color: Color(0xffbfbcf3),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Center(
                                child: Text(
                                  'From: ${job['salary']['min']} to ${job['salary']['max']}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 35,),
                        Row(
                          children: [
                            Text(
                              'Work period',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            SizedBox(width: 35,),
                            Container(
                              height: 30,
                              width: 210,
                              decoration: BoxDecoration(
                                color: Color(0xffbfbcf3),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Center(
                                child: Text(
                                  job['period'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 35,),
                        Row(
                          children: [
                            Text(
                              'Type',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            SizedBox(width: 25,),
                            Container(
                              height: 30,
                              width: 105,
                              decoration: BoxDecoration(
                                color: Color(0xffbfbcf3),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Center(
                                child: Text(
                                  job['type'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 40,),
                            Text(
                              'Category',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            SizedBox(width: 25,),
                            Container(
                              height: 30,
                              width: 105,
                              decoration: BoxDecoration(
                                color: Color(0xffbfbcf3),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Center(
                                child: Text(
                                  job['category'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 35,),
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: Color(0xffbfbcf3),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Required',
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w700
                                          ),
                                        ),
                                        SizedBox(height: 15,),
                                        Text(
                                          job['requiredPosts'].toString(),
                                          style: TextStyle(
                                              color: Colors.black.withOpacity(0.5),
                                              fontSize: 19,
                                              fontWeight: FontWeight.w700
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 60,),
                            Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: Color(0xffbfbcf3),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Proposals',
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w700
                                          ),
                                        ),
                                        SizedBox(height: 15,),
                                        Text(
                                          job['proposals'] == 0 ? 'No proposals' : job['proposals'].toString(),
                                          style: TextStyle(
                                              color: Colors.black.withOpacity(0.5),
                                              fontSize: 19,
                                              fontWeight: FontWeight.w700
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 75,),
                ],
              ),
            ),
            floatingActionButton: currentUserStatus == "Looking for a work" ? Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF8B7ED8),
                shape: BoxShape.circle,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  // Action à définir
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicationScreen(jobId: widget.jobId,),
                    ),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.launch_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ) : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
        }
    );
  }
}
