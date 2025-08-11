import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notifications_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Focus nodes pour gérer les bordures colorées
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _problemFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Écouter les changements de focus pour redessiner les bordures
    _titleFocusNode.addListener(() => setState(() {}));
    _problemFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _problemController.dispose();
    _titleFocusNode.dispose();
    _problemFocusNode.dispose();
    super.dispose();
  }

  // Fonction pour obtenir la couleur de la bordure selon l'état du champ
  Color _getBorderColor(FocusNode focusNode, TextEditingController controller) {
    if (focusNode.hasFocus) {
      return const Color(0xFF8B7ED8); // Violet quand le champ est sélectionné
    } else if (controller.text.isNotEmpty) {
      return Colors.green; // Vert quand le champ contient du texte
    } else {
      return Colors.grey.shade300; // Gris par défaut
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    // Vider les champs et fermer le modal
    _titleController.clear();
    _problemController.clear();
    Navigator.pop(context);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _openEmailApp() async {
    final String subject = Uri.encodeComponent('Support: ${_titleController.text.trim()}');
    final String body = Uri.encodeComponent('''
Title: ${_titleController.text.trim()}

Description of the problem:
${_problemController.text.trim()}

---
Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}
Plateform: ${Platform.isAndroid ? 'Android' : 'iOS'}
    ''');

    final String emailUrl = 'mailto:nermine.chennaoui@isimg.tn?subject=$subject&body=$body';

    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
      _showSuccessMessage('Email app opened successfully');
    } else {
      _showErrorMessage('The opening of email app is impossible');
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Titre du modal
                    const Text(
                      'We are here to help you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you are experiencing any issues, please let us know. We will try to solve them as soon as possible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Champ Titre
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getBorderColor(_titleFocusNode, _titleController),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getBorderColor(_titleFocusNode, _titleController).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        onChanged: (value) => setModalState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please, enter a title';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Add your grievance title here',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Champ Description du problème
                    const Text(
                      'Explain the problem',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getBorderColor(_problemFocusNode, _problemController),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getBorderColor(_problemFocusNode, _problemController).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _problemController,
                        focusNode: _problemFocusNode,
                        onChanged: (value) => setModalState(() {}),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please, describe your problem';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Type your query here',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton Submit
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _submitForm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7ED8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: const Color(0xFF8B7ED8).withOpacity(0.3),
                        ),
                        child: const Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B7ED8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8B7ED8).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B7ED8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Need an urgent help ?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'You can contact us on this number 1234567892',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _submitForm() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7ED8)),
        ),
      ),
    );

    try {
       await _openEmailApp();

       final doc = await FirebaseFirestore.instance.collection('support_queries').add({
         'title': _titleController.text.trim(),
         'description': _problemController.text.trim(),
         'userId': FirebaseAuth.instance.currentUser?.uid,
         'userEmail': FirebaseAuth.instance.currentUser?.email,
         'status': 'pending',
         'createdAt': FieldValue.serverTimestamp(),
         'confirmationSent': false,
         'responses': [],
         'platform': Platform.isAndroid ? 'Android' : 'iOS'
       });
       _showSuccessMessage('Your query has been sent successfully!');

       /*await doc.update({
         'status': 'resolved',
         'responses': FieldValue.arrayUnion([
           {
             //add response data
           }
         ])
       });*/

    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('Error while sending your support query');
    }

    Navigator.pop(context);
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
          'Help & Support',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image d'illustration
            Image.asset(
              'images/help_support.png',
              //height: 120,
            ),
            const SizedBox(height: 40),

            // Titre principal
            const Text(
              'How can we help you today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Sous-titre
            Text(
              'Enter your details to proceed further. Let us know your issues',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 60),

            // Bouton d'action amélioré
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B7ED8),
                    const Color(0xFF8B7ED8).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B7ED8).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showBottomSheet(context),
                  //borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      //borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Let\'s go',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}








/*
import 'package:flutter/material.dart';

import 'notifications_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                textAlign: TextAlign.center,
                'If you are experiencing any issues, please let us know. We will try to solve them as soon as possible.',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              SizedBox(height: 25,),
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 60,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.symmetric(),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add your grievance title here',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 25,),
              Text(
                'Explain the problem',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 180,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _problemController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type your query here',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 60,),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B7ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Row(
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    'You can contact us on this number',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    '1234567892',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffbfbcf3)),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
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
          'Help & Support',
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
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'images/help_support.png'
            ),
            SizedBox(height: 35),
            Text(
              textAlign: TextAlign.center,
                'How can we help you today?',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
            ),
            SizedBox(height: 10,),
            Text(
              textAlign: TextAlign.center,
              'Enter your details to proceed further',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8,),
            Text(
              textAlign: TextAlign.center,
              'Let us know your issues',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 95),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xffbfbcf3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                   _showBottomSheet(context);
                },
                icon: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/
