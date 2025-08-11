import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobmatch_app/screens/recruiters/home_screen_rec.dart';

import 'job_seekers/home_screen.dart';
import 'notifications_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String skills = 'Flutter,Python,Firebase';
  bool isRemoteWork = false;
  String jobType = 'CDI';
  double minSalary = 50000;
  double maxSalary = 100000;
  RangeValues companySizeRange = RangeValues(50, 100);
  String? status;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  bool isImageUploading = false;
  String? profileImageUrl;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController industryController = TextEditingController();

  String? experience;
  String? phoneNumber;
  String? location;
  String? companyName;
  String? industry;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    // Libérer les contrôleurs pour éviter les fuites mémoire
    passwordController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    experienceController.dispose();
    phoneController.dispose();
    locationController.dispose();
    skillsController.dispose();
    companyNameController.dispose();
    industryController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        setState(() {
          final data = doc.data();
          if (data != null) {
            status = data['status']?.toString().trim();
            skills = data['skills'] ?? '';
            experience = data['experience']?.toString();
            phoneNumber = data['phoneNumber'];
            location = data['location'];
            profileImageUrl = data['profileImageUrl'];

            fullNameController.text = data['fullName'] ?? '';
            emailController.text = user.email ?? '';
            experienceController.text = experience ?? '';
            phoneController.text = phoneNumber ?? '';
            locationController.text = location ?? '';
            skillsController.text = skills;
          }
        });

        // Charger les données spécifiques selon le type
        if (status == 'Looking for a work') {
          final prefsDoc = await FirebaseFirestore.instance.collection('job_seekers').doc(user.uid).get();
          if (prefsDoc.exists) {
            final prefs = prefsDoc.data()?['preferences'];
            if (prefs != null) {
              setState(() {
                isRemoteWork = prefs['remote'] ?? false;
                jobType = prefs['jobType'] ?? 'CDI';
                minSalary = (prefs['minSalary'] ?? 50000).toDouble();
                maxSalary = (prefs['maxSalary'] ?? 100000).toDouble();
              });
            }
          }
        } else {
          final recDoc = await FirebaseFirestore.instance.collection('recruiters').doc(user.uid).get();
          if (recDoc.exists) {
            final data = recDoc.data();
            if (data != null) {
              setState(() {
                companyName = data['companyName'];
                industry = data['industry'];
                companySizeRange = RangeValues(
                  (data['companySize']?['min'] ?? 50).toDouble(),
                  (data['companySize']?['max'] ?? 100).toDouble(),
                );

                companyNameController.text = companyName ?? '';
                industryController.text = industry ?? '';
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Widget> _buildConditionalSection() {
    if (status?.trim() == 'Looking for a work') {
      return [
        Text("Preferences", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 16),
        Text("Availability", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("You prefer to work remotely", style: TextStyle(fontSize: 14, color: Colors.black54)),
            Switch(
              value: isRemoteWork,
              onChanged: (val) => setState(() => isRemoteWork = val),
              activeColor: Color(0xFF8B7ED8),
              activeTrackColor: Color(0xFF8B7ED8).withOpacity(0.3),
            ),
          ],
        ),
        SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            SizedBox(height: 8),
            Container(
              height: 60,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
              child: TextFormField(
                initialValue: jobType,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'CDI',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                style: TextStyle(fontSize: 14),
                onChanged: (val) => setState(() => jobType = val),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
        Text('Salary Range', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        SizedBox(height: 8),
        Text('\$${minSalary.round()} - \$${maxSalary.round()}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        RangeSlider(
          values: RangeValues(minSalary, maxSalary),
          min: 0,
          max: 200000,
          divisions: 200,
          activeColor: Color(0xFF8B7ED8),
          inactiveColor: Color(0xFF8B7ED8).withOpacity(0.3),
          onChanged: (values) => setState(() {
            minSalary = values.start;
            maxSalary = values.end;
          }),
        ),
        Text('Minimum required salary', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ];
    } else {
      return [
        Text("Company Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            SizedBox(height: 8),
            Container(
              height: 60,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
              child: TextFormField(
                controller: companyNameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'TechNology',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                style: TextStyle(fontSize: 14),
                onChanged: (val) => setState(() => companyName = val),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
        Text("Company Size", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        SizedBox(height: 8),
        Text('${companySizeRange.start.round()} - ${companySizeRange.end.round()}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        RangeSlider(
          values: companySizeRange,
          min: 1,
          max: 1000,
          divisions: 50,
          activeColor: Color(0xFF8B7ED8),
          inactiveColor: Color(0xFF8B7ED8).withOpacity(0.3),
          onChanged: (val) => setState(() => companySizeRange = val),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Industry', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            SizedBox(height: 8),
            Container(
              height: 60,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
              child: TextFormField(
                controller: industryController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Software Development',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                style: TextStyle(fontSize: 14),
                onChanged: (val) => setState(() => industry = val),
              ),
            ),
            SizedBox(height: 15),
          ],
        )
      ];
    }
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
          'Edit your profile',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (profileImageUrl != null
                          ? NetworkImage(profileImageUrl!) as ImageProvider
                          : null),
                      backgroundColor: Colors.grey[300],
                      child: _imageFile == null && profileImageUrl == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                  if (isImageUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12),
            if (_imageFile != null)
              Center(
                child: ElevatedButton(
                  onPressed: isImageUploading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B7ED8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: isImageUploading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text('Upload Photo', style: TextStyle(color: Colors.white)),
                ),
              ),
            SizedBox(height: 15),
            _buildInputField('Full Name', fullNameController, 'John Doe'),
            SizedBox(height: 15),
            _buildInputField('Experience', experienceController, '3'),
            SizedBox(height: 15),
            _buildInputField('Phone Number', phoneController, '+380 1234567801'),
            SizedBox(height: 15),
            _buildInputField('Location', locationController, 'New York'),
            SizedBox(height: 15),
            _buildInputField('Skills', skillsController, 'Firebase, Python, Java', onChanged: (val) => setState(() => skills = val)),
            SizedBox(height: 35),
            Divider(thickness: 1.5),
            SizedBox(height: 15),
            Center(child: Text('Other')),
            SizedBox(height: 25),
            ..._buildConditionalSection(),
            SizedBox(height: 75),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUploading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B7ED8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: isUploading
                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 80)
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isPassword = false, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            style: TextStyle(fontSize: 14),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('User not authenticated', Colors.red);
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Mettre à jour le nom d'affichage
      await user.updateDisplayName(fullNameController.text.trim());


      // Sauvegarder les informations utilisateur
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'status': status,
        'fullName': fullNameController.text.trim(),
        'skills': skillsController.text.trim(),
        'experience': experienceController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'email': user.email,
        'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sauvegarder selon le type d'utilisateur
      if (status == 'Looking for a work') {
        await FirebaseFirestore.instance.collection('job_seekers').doc(user.uid).set({
          'preferences': {
            'remote': isRemoteWork,
            'jobType': jobType,
            'minSalary': minSalary,
            'maxSalary': maxSalary,
          },
          'favorites': [],
          'viewHistory': [],
          'profileImageUrl': profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance.collection('recruiters').doc(user.uid).set({
          'companyName': companyNameController.text.trim(),
          'companySize': {
            'min': companySizeRange.start,
            'max': companySizeRange.end
          },
          'industry': industryController.text.trim(),
          'profileImageUrl': profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _showSnackBar('Profile saved successfully!', Color(0xFF8B7ED8));

      // Navigation vers l'écran approprié
      if (status == 'Looking for a work') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen())
        );
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreenRec())
        );
      }

    } catch (e) {
      print('Save profile error: $e');
      _showSnackBar('Failed to save profile: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          profileImageUrl = null;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Failed to pick image. Please try again.', Colors.red);
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      isImageUploading = true;
    });

    try {
      String cloudName = 'dr4ib1dom';
      String uploadPreset = 'unsigned_upload';
      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_imageFile!.path),
        'upload_preset': uploadPreset,
      });

      final response = await Dio().post(url, data: formData);

      if (response.statusCode == 200) {
        final downloadUrl = response.data['secure_url'];
        print('Cloudinary Upload successful: $downloadUrl');

        setState(() {
          profileImageUrl = downloadUrl;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'profileImageUrl': profileImageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        _showSnackBar('Photo uploaded successfully!', Colors.green);
      } else {
        throw Exception('Cloudinary upload failed');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      _showSnackBar('Error uploading image: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isImageUploading = false;
        });
      }
    }
  }
}