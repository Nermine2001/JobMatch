import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'notifications_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {

  // bool isPressed = false;
  int rate = 0;
  final TextEditingController _feedController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _feedController.dispose();
  }

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
          'Feedback',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('images/feedback.png'),
            ),
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Send us your ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700
                  ),
                ),
                Text(
                  'Feedback!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              'Tell us how your experience was and leave a comment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 5 emojis expressing the feeling of user
                GestureDetector(
                  onTap: () {
                    setState(() {
                      //isPressed = true;
                      rate = 1;
                    });
                  },
                  child: Icon(
                    Icons.sentiment_very_dissatisfied_outlined,
                    color: rate == 1 ? Colors.amber : Colors.grey,
                    size: 54,
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      //isPressed = true;
                      rate = 2;
                    });

                  },
                  child: Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    color: rate == 2 ? Colors.amber : Colors.grey,
                    size: 54,
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      //isPressed = true;
                      rate = 3;
                    });
                  },
                  child: Icon(
                    Icons.sentiment_neutral_outlined,
                    color: rate == 3 ? Colors.amber : Colors.grey,
                    size: 54,
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      //isPressed = true;
                      rate = 4;
                    });
                  },
                  child: Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: rate == 4 ? Colors.amber : Colors.grey,
                    size: 54,
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      //isPressed = true;
                      rate = 5;
                    });
                  },
                  child: Icon(
                    Icons.sentiment_very_satisfied_outlined,
                    color: rate == 5 ? Colors.amber : Colors.grey,
                    size: 54,
                  ),
                ),
                SizedBox(width: 10,),

              ],
            ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _feedController,
                minLines: 8,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Express your honest point of view about our application and precise what are our strengthens and weaknesses.',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: 45,),
            ElevatedButton(
              onPressed: () async {
                //
                await FirebaseFirestore.instance.collection('feedbacks').add({
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                  'createdAt': Timestamp.now(),
                  'feedback': _feedController.text.trim(),
                  'rate': rate,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback sent. Thank you!')),
                );

                setState(() {
                  rate = 0;
                  //isPressed = false;
                  _feedController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff1feac),
                foregroundColor: Colors.black,
                minimumSize: const Size(400, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Send Feedback",
                style: TextStyle(
                    fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }
}
