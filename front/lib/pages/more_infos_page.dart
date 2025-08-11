import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobmatch_app/screens/job_seekers/home_screen.dart';
import 'package:jobmatch_app/screens/recruiters/home_screen_rec.dart';

class MoreInfosPage extends StatefulWidget {
  const MoreInfosPage({super.key});

  @override
  State<MoreInfosPage> createState() => _MoreInfosPageState();
}

class _MoreInfosPageState extends State<MoreInfosPage> {
  String selectedStatus = 'Looking for a work';
  String skills = 'Flutter,Python,Firebase';
  String experience = '';
  String phoneNumber = '+380 1234567801';
  String location = 'New York';
  bool isRemoteWork = false;
  String jobType = 'CDI';
  double minSalary = 50000;
  double maxSalary = 100000;

  String companyName = '';
  RangeValues companySizeRange = RangeValues(50, 100);
  String industry = '';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  bool isImageUploading = false; // Séparé pour l'upload d'image
  String? profileImageUrl;

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
          "Informations of your profile",
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
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildDropdownStatus(),
            _buildTextField("Skills", skills, (val) => setState(() => skills = val)),
            _buildTextField("Experience", experience, (val) => setState(() => experience = val)),
            _buildTextField("Phone Number", phoneNumber, (val) => setState(() => phoneNumber = val), TextInputType.phone),
            _buildTextField("Location", location, (val) => setState(() => location = val)),

            SizedBox(height: 32),
            ..._buildConditionalSection(),
            SizedBox(height: 20,),
            Text(
              'Profile Photo',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87
              ),
            ),
            SizedBox(height: 8,),
            Center(
              child: GestureDetector(
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
            SizedBox(height: 40),
            _buildSaveButton(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
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
          profileImageUrl = null; // Reset URL car nouvelle image sélectionnée
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /*Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isImageUploading = true;
    });

    try {
      final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Créer une référence unique avec timestamp
      final userId = user.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      print('Uploading to path: profile_images/$fileName');


      // Upload du fichier
      final uploadTask = ref.putFile(_imageFile!, SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': user.uid, 'uploadedAt': DateTime.now().toIso8601String()},
      ));


      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Attendre la fin de l'upload
      final snapshot = await uploadTask;

      // Obtenir l'URL de téléchargement
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Upload successful. Download URL: $downloadUrl');

      setState(() {
        profileImageUrl = downloadUrl;
        isImageUploading = false;
      });

      // Sauvegarder l'URL dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      setState(() {
        isImageUploading = false;
      });

      String errorMessage;
      switch (e.code) {
        case 'storage/unauthorized':
          errorMessage = 'You don\'t have permission to upload images';
          break;
        case 'storage/canceled':
          errorMessage = 'Upload was canceled';
          break;
        case 'storage/unknown':
          errorMessage = 'Unknown error occurred during upload';
          break;
        case 'storage/object-not-found':
          errorMessage = 'Storage bucket not found. Please check Firebase configuration.';
          break;
        case 'storage/bucket-not-found':
          errorMessage = 'Storage bucket not found. Please check Firebase configuration.';
          break;
        default:
          errorMessage = 'Upload failed: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        isImageUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }*/

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      isImageUploading = true;
    });

    try{
      String cloudName = 'dr4ib1dom';
      String uploadPreset = 'unsigned_upload';

      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_imageFile!.path),
        'upload_preset': uploadPreset,
      });

      final response = await Dio().post(url, data: formData);

      if(response.statusCode == 200) {
        final downloadUrl = response.data['secure_url'];
        print('Cloudinary Upload successful: $downloadUrl');

        setState(() {
          profileImageUrl = downloadUrl;
          isImageUploading = false;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'profileImageUrl': profileImageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo uploaded to Cloudinary!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('Cloudinary upload failed');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      setState(() {
        isImageUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e'), backgroundColor: Colors.red),
      );
    }

  }

  Widget _buildDropdownStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('You are...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: ['Looking for a work', 'Looking for a worker']
                  .map((val) => DropdownMenuItem<String>(value: val, child: Text(val, style: TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (val) => setState(() => selectedStatus = val!),
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged, [TextInputType? type]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        SizedBox(height: 8),
        Container(
          height: 60,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: _boxDecoration(),
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: type,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your $label'.toLowerCase(),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            style: TextStyle(fontSize: 14),
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildConditionalSection() {
    if (selectedStatus == 'Looking for a work') {
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
        _buildTextField("Job Type", jobType, (val) => setState(() => jobType = val)),
        Text('Min Salary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
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
        Text('Minimum of required salary', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ];
    } else {
      return [
        Text("Company Informations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 16),
        _buildTextField("Company Name", companyName, (val) => setState(() => companyName = val)),
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
        _buildTextField("Industry", industry, (val) => setState(() => industry = val)),
      ];
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
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
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Upload de l'image si elle n'est pas encore uploadée
      if (_imageFile != null && profileImageUrl == null) {
        await _uploadImage();
      }

      // Sauvegarder les informations utilisateur
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'status': selectedStatus,
        'skills': skills,
        'experience': experience,
        'phoneNumber': phoneNumber,
        'location': location,
        'email': user.email,
        'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sauvegarder selon le type d'utilisateur
      if (selectedStatus == 'Looking for a work') {
        await FirebaseFirestore.instance.collection('job_seekers').doc(user.uid).set({
          'preferences': {
            'remote': isRemoteWork,
            'jobType': jobType,
            'minSalary': minSalary,
            'maxSalary': maxSalary,
          },
          'favorites': [],
          'viewHistory': [],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (selectedStatus == 'Looking for a worker'){
        await FirebaseFirestore.instance.collection('recruiters').doc(user.uid).set({
          'companyName': companyName,
          'companySize': {
            'min': companySizeRange.start,
            'max': companySizeRange.end
          },
          'industry': industry,
          'jobCount': 0,
          'profileImageUrl': profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Color(0xFF8B7ED8),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigation vers l'écran approprié
      if (selectedStatus == 'Looking for a work') {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
      ],
    );
  }
}





/*
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobmatch_app/screens/job_seekers/home_screen.dart';
import 'package:jobmatch_app/screens/recruiters/home_screen_rec.dart';

class MoreInfosPage extends StatefulWidget {
  const MoreInfosPage({super.key});

  @override
  State<MoreInfosPage> createState() => _MoreInfosPageState();
}

class _MoreInfosPageState extends State<MoreInfosPage> {
  String selectedStatus = 'Looking for a work';
  String skills = 'Flutter,Python,Firebase';
  String experience = '';
  String phoneNumber = '+380 1234567801';
  String location = 'New York';
  bool isRemoteWork = false;
  String jobType = 'CDI';
  double minSalary = 50000;
  double maxSalary = 100000;

  String companyName = '';
  RangeValues companySizeRange = RangeValues(50, 100);
  String industry = '';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  bool isImageUploading = false;
  String? profileImageUrl;


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
          "Informations of your profile",
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
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildDropdownStatus(),
            _buildTextField("Skills", skills, (val) => setState(() => skills = val)),
            _buildTextField("Experience", experience, (val) => setState(() => experience = val)),
            _buildTextField("Phone Number", phoneNumber, (val) => setState(() => phoneNumber = val), TextInputType.phone),
            _buildTextField("Location", location, (val) => setState(() => location = val)),

            SizedBox(height: 32),
            ..._buildConditionalSection(),
            SizedBox(height: 20,),
            Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87
              ),
            ),
            SizedBox(height: 8,),
            Container(
              color: Colors.grey[300],
              width: 450,
              child: GestureDetector(
                onTap: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (profileImageUrl != null
                      ? NetworkImage(profileImageUrl!) as ImageProvider
                      : AssetImage('assets/default_avatar.png')),
                  backgroundColor: Colors.grey[300],
                  child: _imageFile == null && profileImageUrl == null
                      ? Icon(Icons.camera_alt, size: 28, color: Colors.white)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 12),
            if (_imageFile != null)
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  if (_imageFile == null) return;

                  setState(() {
                    isUploading = true;
                  });

                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final ref = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');

                  await ref.putFile(_imageFile!);
                  profileImageUrl = await ref.getDownloadURL();

                  // Save URL to Firestore
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'profileImageUrl': profileImageUrl,
                  });

                  setState(() {
                    isUploading = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B7ED8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Upload Photo'),
              ),
            SizedBox(height: 40),
            _buildSaveButton(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('You are...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: ['Looking for a work', 'Looking for a worker']
                  .map((val) => DropdownMenuItem<String>(value: val, child: Text(val, style: TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (val) => setState(() => selectedStatus = val!),
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged, [TextInputType? type]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: _boxDecoration(),
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: type,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your $label'.toLowerCase(),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            style: TextStyle(fontSize: 14),
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildConditionalSection() {
    if (selectedStatus == 'Looking for a work') {
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
        _buildTextField("Job Type", jobType, (val) => setState(() => jobType = val)),
        Text('Min Salary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
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
        Text('Minimum of required salary', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ];
    } else {
      return [
        Text("Company Informations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 16),
        _buildTextField("Company Name", companyName, (val) => setState(() => companyName = val)),
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
        _buildTextField("Industry", industry, (val) => setState(() => industry = val)),
      ];
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          // TODO
          // save on differnt tables
          final uid = FirebaseAuth.instance.currentUser!.uid;

          setState(() {
            isUploading = true;
          });

          // Upload profile image if selected and not uploaded yet
          if (_imageFile != null && profileImageUrl == null) {
            try {
              final ref = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');
              await ref.putFile(_imageFile!);
              profileImageUrl = await ref.getDownloadURL();
            } catch (e) {
              print('Image upload error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload image.'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                isUploading = false;
              });
              return;
            }
          }

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'status': selectedStatus,
            'skills': skills,
            'experience': experience,
            'phoneNumber': phoneNumber,
            'location': location,
            'email': FirebaseAuth.instance.currentUser!.email,
            'profileImageUrl': profileImageUrl,
          }, SetOptions(merge: true));

          if (selectedStatus == 'Looking for a work') {
            await FirebaseFirestore.instance.collection('job_seekers').doc(uid).set({
              'preferences': {
                'remote': isRemoteWork,
                'jobType': jobType,
                'minSalary': minSalary,
                'maxSalary': maxSalary,
              },
              'favorites': [],
              'viewHistory': [],
            });
          } else {
            await FirebaseFirestore.instance.collection('recruiters').doc(uid).set({
              'companyName': companyName,
              'companySize': {
                'min': companySizeRange.start,
                'max': companySizeRange.end
              },
              'industry': industry,
              'jobCount': 0,
              'profileImageUrl': profileImageUrl,
            }, SetOptions(merge: true));
          }

          setState(() {
            isUploading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile saved successfully!'),
              backgroundColor: Color(0xFF8B7ED8),
              duration: Duration(seconds: 3),
            ),
          );

          if (selectedStatus == 'Looking for a work') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreenRec()));
          }

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B7ED8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0,
        ),
        child: isUploading
            ? CircularProgressIndicator(color: Colors.white)
            : Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
      ],
    );
  }
}
*/
