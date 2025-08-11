import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:jobmatch_app/screens/job_seekers/confirm_application_screen.dart';
import 'package:jobmatch_app/screens/job_seekers/home_screen.dart';
import 'package:jobmatch_app/screens/notifications_screen.dart';
import 'package:jobmatch_app/screens/recruiters/home_screen_rec.dart';

class ApplicationScreen extends StatefulWidget {

  final String jobId;

  const ApplicationScreen({super.key, required this.jobId});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _profileUrlController = TextEditingController();

  String? resumeUrl;
  String? selectedFileName;
  String? status = 'pending';


  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _profileUrlController.dispose();
    super.dispose();
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
          "Apply Now",
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
            SizedBox(height: 34),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Name',
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
              controller: _nameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'John Doe',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
                SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'john.doe@example.com',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
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
                        controller: _phoneController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '+380 1234567801',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Url',
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
                            controller: _profileUrlController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your profile URL',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload your resume',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                 SizedBox(width: 8,),
                                Text(
                                  selectedFileName != null
                                      ? selectedFileName!
                                      : 'Click to upload (.pdf)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: selectedFileName != null ? Colors.black87 : Colors.grey,
                                  ),
                                )

                              ],
                            ),
                          ),
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf']
                            );

                            if (result != null) {
                              final file = result.files.single;
                              Uint8List? bytes = file.bytes;

                              if (bytes == null && file.path != null) {
                                final fileOnDisk = File(file.path!);
                                bytes = await fileOnDisk.readAsBytes();
                              }


                              final fileName = file.name;

                              print("File name: ${file.name}");
                              print("File size: ${file.size}");
                              print("Bytes null? ${bytes == null}");


                              if (bytes == null) return;

                              final cloudinaryUrl = Uri.parse("https://api.cloudinary.com/v1_1/dr4ib1dom/auto/upload");

                              final request = http.MultipartRequest('POST', cloudinaryUrl)
                                ..fields['upload_preset'] = 'unsigned_upload'
                                ..files.add(await http.MultipartFile.fromBytes(
                                  'file',
                                  bytes,
                                  filename: fileName,
                                  contentType: MediaType('application', 'pdf'),
                                ));

                              final response = await request.send();

                              if (response.statusCode == 200) {
                                final resBody = await response.stream.bytesToString();
                                final data = json.decode(resBody);

                                final uploadedUrl = data['secure_url'];
                                print("Uploaded PDF URL: $uploadedUrl");

                                setState(() {
                                  resumeUrl = uploadedUrl;
                                  selectedFileName = fileName;
                                });

                                // Optional: store this URL in Firestore or show a confirmation dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Resume uploaded successfully!")),
                                );
                              } else {
                                print("Failed to upload. Status: ${response.statusCode}");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Upload failed. Try again.")),
                                );
                              }

                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 170),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {

                          if (resumeUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please upload your resume before submitting.")),
                            );
                            return;
                          }

                          DocumentSnapshot job = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();
                          String title = job['title'];
                          String companyName = job['company'];

                          await FirebaseFirestore.instance.collection('proposals').add({
                            'userId': FirebaseAuth.instance.currentUser!.uid,
                            'jobId': widget.jobId,
                            'jobTitle': title,
                            'companyName': companyName,
                            'candidateName': _nameController.text.trim(),
                            'candidateEmail': _emailController.text.trim(),
                            'candidatePhoneNumber': _phoneController.text.trim(),
                            'candidateProfileUrl': _profileUrlController.text.trim(),
                            'resumeUrl': resumeUrl,
                            'appliedAt': Timestamp.now(),
                            'submittedAt': status == 'submitted' ? Timestamp.now() : FieldValue.delete(),
                            'status': status
                          });

                          final jobData = await FirebaseFirestore.instance
                              .collection('jobs')
                              .doc(widget.jobId)
                              .get();

                          await FirebaseFirestore.instance.collection('notifications').add({
                            'fromUserId': FirebaseAuth.instance.currentUser!.uid,
                            'toUserId': jobData.data()?['userId'],
                            'title': 'New Proposal',
                            'description': 'A new proposal sent for one of your job offers',
                            'date': Timestamp.now(),
                            'image': 'images/notif_bell.png',
                            'type': 'proposal',
                            'status': 'unread'
                          });

                          FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({
                            'proposals': FieldValue.increment(1),
                          });

                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConfirmApplicationScreen(jobId: widget.jobId,)));


                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B7ED8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,)
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
