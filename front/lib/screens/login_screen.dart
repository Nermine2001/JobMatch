import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobmatch_app/main.dart';
import 'package:jobmatch_app/screens/recruiters/home_screen_rec.dart';
import 'package:jobmatch_app/screens/register_screen.dart';

import '../services/auth_service.dart';
import 'job_seekers/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;



  Future<String?> fetchUserStatus() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['status']; // 'Looking for a work' ou 'Looking for a worker'
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = "john.doe@example.com";
    _passwordController.text = "password";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBfbcF3),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec bouton retour
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // Contenu principal
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFdfddf3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),


                    // Email
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),


                    const SizedBox(height: 24),

                    // Password
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 8,),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Action forgot password
                        },
                        child: const Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35,),

                    // Login Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Action de connexion
                          try {
                            final user = await AuthService().signIn(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                            String? status = await fetchUserStatus();
                            if (user != null) {
                              if (status == 'Looking for a work') {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                              }else if (status == 'Looking for a worker') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreenRec()));
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
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
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35,),

                    const Center(
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Continue with Google
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: () {
                          // Action Google
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffdfddf3),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          side: const BorderSide(color: Colors.grey, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Continue with Facebook
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: () {
                          // Action Facebook
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffdfddf3),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          side: const BorderSide(color: Colors.grey, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'f',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with facebook',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Continue with Apple
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action Apple
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffdfddf3),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          side: const BorderSide(color: Colors.grey, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.apple,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with apple',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //const Spacer(),
                    const SizedBox(height: 8,),

                    // Sign Up Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'You don\'t have an account yet? ',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // Navigation vers Sign Up
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}