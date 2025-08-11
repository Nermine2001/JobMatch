import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobmatch_app/screens/about_screen.dart';
import 'package:jobmatch_app/screens/feedback_screen.dart';
import 'package:jobmatch_app/screens/help_support_screen.dart';
import 'package:jobmatch_app/screens/job_seekers/your_applications_screen.dart';
import 'package:jobmatch_app/screens/notifications_screen.dart';
import 'package:jobmatch_app/screens/privacy_security_screen.dart';
import 'package:jobmatch_app/screens/job_seekers/favorites_screen.dart';
import 'package:jobmatch_app/screens/login_screen.dart';
import 'package:jobmatch_app/screens/profile_screen.dart';
import 'package:jobmatch_app/screens/recruiters/statistics_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';


import 'contact_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String? userName;
  String? profileImageUrl;
  String? status;
  bool isLoading = true;
  String placeholderUrl = 'https://example.com';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserData();
  }

  void _rateApp() async {
    if (await canLaunchUrl(Uri.parse(placeholderUrl))) {
      await launchUrl(Uri.parse(placeholderUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the rate page')),
      );
    }
  }

  void _shareApp() {

    Share.share(
      'Discover JobMatch – your job-finding assistant! Coming soon: $placeholderUrl',
      subject: 'Check out JobMatch!',
    );
  }



  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    setState(() {
      userName = user.displayName ?? 'User';
      profileImageUrl = doc.data()?['profileImageUrl'];
      status = doc.data()?['status'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 24,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xffafa3ea),
                shape: BoxShape.circle,
              ),
              child: profileImageUrl == null ? Icon(
                Icons.person_outline,
                color: Colors.deepPurple/*(0xff7f45a5)*/,
                size: 44,
              ) : ClipOval(
                child: Image.network(
                    profileImageUrl!,
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$userName',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Colors.black
              ),
            ),


          ],
        ),
        SizedBox(height: 24,),
        Container(
          width: 400,
          margin: EdgeInsets.symmetric(horizontal: 12.0),
          padding: EdgeInsets.all(8.0),
          color: Color(0xffbfbcf3/*0xffe8daf0*/),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.person_2_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                        'Account',
                      style: TextStyle(
                        fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              status == 'Looking for a work' ? GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => YourApplicationsScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.task_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'My applications',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ) : GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.notifications_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Notifications',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              status == 'Looking for a work' ? GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritesScreen(jobsStream: FirebaseFirestore.instance.collection('jobs').snapshots())));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.favorite_outline, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Favorites',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ) : GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.auto_graph_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Statistics',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () async {
                  //await launchUrl(Uri.parse('https://www.termsfeed.com/live/f8069637-31d9-4ccb-b677-2dcd9688b003'), mode: LaunchMode.externalApplication);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySecurityScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.privacy_tip_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Privacy & Security',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.headphones_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Help and Support',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.help_outline, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'About',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.logout_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
        SizedBox(height: 24,),
        SizedBox(width: 350,child: Divider(thickness: 2.5, color: Colors.deepPurple,)),
        SizedBox(height: 24,),
        Container(
          width: 400,
          margin: EdgeInsets.symmetric(horizontal: 12.0),
          padding: EdgeInsets.all(8.0),
          color: Color(0xffbfbcf3/*0xffe8daf0*/),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _rateApp();
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.star_border_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Rate App',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {
                  _shareApp();
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.share_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Share App',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.chat_bubble_outline, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Feedback',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsScreen()));
                },
                child: Row(
                  children: [
                    SizedBox(width: 15,),
                    Icon(Icons.email_outlined, color: Colors.black.withOpacity(0.6),),
                    SizedBox(width: 15,),
                    Text(
                      'Contact Us',
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),

            ],
          ),
        ),

      ],
    );
  }
}
