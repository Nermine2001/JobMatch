import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobmatch_app/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(
        user.uid).get();
    if (doc.exists) {
      print(doc.data());
      return doc.data(); // returns a map of user data
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('User not found'));
        }

        final userData = snapshot.data!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24,),
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xffafa3ea),
                  shape: BoxShape.circle,
                ),
                child: userData['profileImageUrl'] == null ? Icon(
                  Icons.person_outline,
                  color: Colors.deepPurple /*(0xff7f45a5)*/,
                  size: 44,
                ) : ClipOval(
                  child: Image.network(userData['profileImageUrl']!, fit: BoxFit.cover,
                    width: 70,
                    height: 70,),
                ),
              ),
            ),
            SizedBox(height: 24,),
            Text(
              '${userData['fullName']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24,),
            Container(
              width: 400,
              margin: EdgeInsets.symmetric(horizontal: 12.0),
              padding: EdgeInsets.all(8.0),
              color: Color(0xffbfbcf3 /*0xffe8daf0*/),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.person_2_outlined,
                          color: Colors.black.withOpacity(0.6),),
                        SizedBox(width: 15,),
                        Text(
                          '${userData['fullName']}',
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
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.calendar_today_outlined,
                          color: Colors.black.withOpacity(0.6),),
                        SizedBox(width: 15,),
                        Text(
                          userData['birthDate'].toString().substring(0, 10),
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
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.phone_outlined,
                          color: Colors.black.withOpacity(0.6),),
                        SizedBox(width: 15,),
                        Text(
                          '${userData['phoneNumber']}',
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
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.email_outlined,
                          color: Colors.black.withOpacity(0.6),),
                        SizedBox(width: 15,),
                        Text(
                          '${userData['email']}',
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
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.person_2_outlined,
                          color: Colors.black.withOpacity(0.6),),
                        SizedBox(width: 15,),
                        Text(
                          'Forgot Password',
                          style: TextStyle(
                              fontSize: 18
                          ),
                        ),
                        SizedBox(width: 140,),
                        Icon(Icons.change_circle_outlined, color: Colors.black.withOpacity(0.6))
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),

                ],
              ),
            ),
            SizedBox(height: 60,),
            Container(
              width: 400,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf1feac),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: 400,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () async {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.5)/*(0xFFf1feac)*/,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
