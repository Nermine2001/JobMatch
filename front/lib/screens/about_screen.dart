import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'notifications_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdfddf3),
      appBar: AppBar(
        backgroundColor: const Color(0xffbfbcf3),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'images/about.png',
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Icon(CupertinoIcons.sparkles, color: Colors.amber, size: 30.0,),
                SizedBox(width: 10,),
                Text(
                  'Welcome to JobMatch',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              'We are passionate about creating innovative solutions that make your daily life easier, smarter, and more enjoyable.',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey
              ),
            ),
            SizedBox(height: 15,),
            Text(
              'Whether you\'re here to manage job offers, get support, stay updated, or explore new features —— we\'ve built this app with care, performance, and simplicity in mind.',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Icon(CupertinoIcons.lightbulb_fill, color: Colors.amberAccent, size: 30.0,),
                SizedBox(width: 10,),
                Text(
                  'Our Mission',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              'To deliver a seamless and empowering user experience by combining technology, accessibility, and creativity. We aim to build tools that people genuinely love to use.',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Icon(CupertinoIcons.person_2_alt, color: Colors.grey, size: 30.0,),
                SizedBox(width: 10,),
                Text(
                  'Who We Are',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              'We are a dedicated team of developers, designers, and thinkers from ISIMG, driven by curiosity and innovation. Each line of code we write is crafted to bring more value to your fingertips',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Icon(CupertinoIcons.phone_fill, color: Colors.red, size: 30.0,),
                SizedBox(width: 10,),
                Text(
                  'Need Help?',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              'If you ever need assistance, feel free to reach out via the Help & Support section, or contact us directly:',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.deepPurple, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'nermine.chennaoui@isimg.tn',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.deepPurple, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '123-456-789-2',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.deepPurple, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '12 snit city, sidi boulbaba, Gabes 6012, Tunisia',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Icon(Icons.celebration, color: Colors.blue, size: 30.0,),
                SizedBox(width: 10,),
                Expanded(
                  child: Text(
                    'Thank You For Choosing JobMatch',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              'We truly appreciate your trust. Your feedback helps us grow and improve every day. Stay tuned for more updates and features coming soon!',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 65,),
          ],
        ),
      ),
    );
  }
}
