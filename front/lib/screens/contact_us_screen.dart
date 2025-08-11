import 'dart:ui';

import 'package:flutter/material.dart';

import 'notifications_screen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

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
          'Contact Us',
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
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
                'images/bg_about_us1.jfif',
                fit: BoxFit.cover,
              )
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 150, right: 24, left: 24),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(220)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3)
                        )
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SizedBox(height: 80,),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.deepPurple.shade500,),
                            SizedBox(width: 15,),
                            Expanded(
                              child: Text(
                                '123-456-789-2',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 16,),
                        Row(
                          children: [
                            Icon(Icons.email, color: Colors.deepPurple.shade500,),
                            SizedBox(width: 15,),
                            Expanded(
                              child: Text(
                                'nermine.chennaoui@isimg.tn',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 16,),
                        Row(
                          children: [
                            Icon(Icons.near_me, color: Colors.deepPurple.shade500,),
                            SizedBox(width: 15,),
                            Expanded(
                              child: Text(
                                '12 snit city, sidi boulbaba, Gabes 6012, Tunisia',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 32,),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                    hintText: 'Name'
                                ),
                              ),
                            ),
                            SizedBox(width: 12,),
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                    hintText: 'Email'
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16,),
                        TextFormField(
                          controller: _messageController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Message',
                          ),
                        ),
                        SizedBox(height: 24,),
                        ElevatedButton(
                            onPressed: (){
                              //TODO
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B7ED8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Send Message',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
