import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobmatch_app/screens/login_screen.dart';
import 'package:jobmatch_app/services/auth_service.dart';

import '../pages/more_infos_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = "John Doe";
    _emailController.text = "john.doe@example.com";
    _dateController.text = "08/17/2023";
    _passwordController.text = "password";
  }

  DateTime parseDate(String dateString) {
    final format = DateFormat('MM/dd/yyyy');
    return format.parse(dateString);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
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
                      'Sign Up',
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

                    // Full Name
                    const Text(
                      'Full Name',
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
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 24),

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

                    // Date of Birth
                    const Text(
                      'Date of Birth',
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
                        controller: _dateController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 20,
                          ),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 16),
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2023, 8, 17),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            _dateController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MM/DD/YYYY',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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

                    const Spacer(),

                    // Register Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Action d'inscription
                          try {
                            final user = await AuthService().register(_nameController.text.trim(), _emailController.text.trim(), parseDate(_dateController.text.trim()) , _passwordController.text.trim());

                            if (!context.mounted) {
                                  print("Context non monté");
                                  return;
                            }

                              if (user != null)
                             {
                              print("Registered successfully, navigating...");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MoreInfosPage())
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
                          'Register',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Sign In Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // Navigation vers Sign In
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                child: const Text(
                                  'Sign In',
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