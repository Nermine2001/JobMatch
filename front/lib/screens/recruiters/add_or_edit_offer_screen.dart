import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../notifications_screen.dart';

class AddOrEditOfferScreen extends StatefulWidget {

  final String? jobId;
  final Map<String, dynamic>? initialData;

  const AddOrEditOfferScreen({super.key, this.jobId, this.initialData});

  @override
  State<AddOrEditOfferScreen> createState() => _AddOrEditOfferScreenState();
}

class _AddOrEditOfferScreenState extends State<AddOrEditOfferScreen> {

  bool isRemoteWork = false;
  String selectedCat = '...';
  double minExp = 0;
  double maxExp = 20;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _descriptionController;
  late TextEditingController _skillsController;
  late TextEditingController _minSalaryController;
  late TextEditingController _maxSalaryController;
  late TextEditingController _locationController;
  late TextEditingController _typeController;
  late TextEditingController _periodController;
  late TextEditingController _minAgeController;
  late TextEditingController _maxAgeController;
  late TextEditingController _experienceController;
  late TextEditingController _requiredPostsController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final parsedExp = double.tryParse(widget.initialData?['experience']?.toString() ?? '0') ?? 0;
    minExp = parsedExp.clamp(0, 20).toDouble();
    maxExp = parsedExp.clamp(0, 20).toDouble();
    selectedCat = widget.initialData?['category'] ?? '...';
    isRemoteWork = widget.initialData?['remote'] ?? false;
    _titleController =
        TextEditingController(text: widget.initialData?['title']);
    _companyController =
        TextEditingController(text: widget.initialData?['company']);
    _descriptionController =
        TextEditingController(text: widget.initialData?['description']);
    _skillsController =
        TextEditingController(text: (widget.initialData?['skills'] as List<dynamic>?)?.join(', '));
    _minSalaryController =
        TextEditingController(text: widget.initialData?['salary']?['min']?.toString());
    _maxSalaryController =
        TextEditingController(text: widget.initialData?['salary']?['max']?.toString());
    _locationController =
        TextEditingController(text: widget.initialData?['location']);
    _typeController = TextEditingController(text: widget.initialData?['type']);
    _periodController =
        TextEditingController(text: widget.initialData?['period']);
    _minAgeController =
        TextEditingController(text: widget.initialData?['age']?['min']?.toString());
    _maxAgeController =
        TextEditingController(text: widget.initialData?['age']?['max']?.toString());
    _experienceController =
        TextEditingController(text: minExp.round().toString() /*widget.initialData?['experience']*/);
    _requiredPostsController =
        TextEditingController(text: widget.initialData?['requiredPosts']);
  }

  @override
  Widget build(BuildContext context) {
    assert(minExp >= 0 && minExp <= 20, 'minExp out of range: $minExp');
    assert(maxExp >= 0 && maxExp <= 20, 'maxExp out of range: $maxExp');

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
          'Add / Edit an offer',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
              children: [
              SizedBox(height: 35),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title (e.g : Flutter Developer)',
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
                  controller: _titleController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Flutter Developer',
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
                'Company Name',
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
                  controller: _companyController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'TechNet',
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
                'Description',
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
                  controller: _descriptionController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Describe The Offer',
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
                'Skills',
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
                  controller: _skillsController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Flutter, Java, Python',
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
          // salary
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
            'Salary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 185,
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
                  controller: _minSalaryController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'min'.toLowerCase(),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  //onChanged: () {},
                ),
              ),
              SizedBox(width: 20),
              Container(
                height: 60,
                width: 185,
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
                  controller: _maxSalaryController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'max'.toLowerCase(),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  //onChanged: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
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
                  controller: _locationController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'San Francisco',
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
                'Type',
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
                  controller: _typeController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'CDI',
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
          //remote
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
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period',
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
                  controller: _periodController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '3 months',
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
          //age
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
            'Age',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 185,
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
                  controller: _minAgeController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'min'.toLowerCase(),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  //onChanged: () {},
                ),
              ),
              SizedBox(width: 20),
              Container(
                height: 60,
                width: 185,
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
                  controller: _maxAgeController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'max'.toLowerCase(),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  //onChanged: () {},
                ),
              ),
            ],
          ),
          //experience
          SizedBox(height: 15),
          Text(
            'Experience',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${minExp.round()} - ${maxExp.round()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          RangeSlider(
            values: RangeValues(minExp, maxExp),
            min: 0,
            max: 20,
            divisions: null,
            activeColor: Color(0xFF8B7ED8),
            inactiveColor: Color(0xFF8B7ED8).withOpacity(0.3),
            onChanged:
                (values) =>
                setState(() {
                  minExp = values.start.clamp(0, 20);
                  maxExp = values.end.clamp(0, 20);
                  _experienceController.text = minExp.round().toString();
                }),
          ),
          //category
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCat,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items:
                    ['...', 'Remote', 'Hybrid', 'On Site']
                        .map(
                          (val) =>
                          DropdownMenuItem<String>(
                            value: val,
                            child: Text(
                              val,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                    )
                        .toList(),
                    onChanged: (val) => setState(() => selectedCat = val!),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required Posts (how much persons to finally accept)',
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
                      controller: _requiredPostsController,
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '3',
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
              SizedBox(height: 75),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    if(FirebaseAuth.instance.currentUser == null) return;

                    if (_experienceController.text.isEmpty) {
                      _experienceController.text = minExp.round().toString();
                    }


                    final jobData = {
                      'title': _titleController.text.trim(),
                      'company': _companyController.text.trim(),
                      'description': _descriptionController.text.trim(),
                      'skills': _skillsController.text.split(',').map((e) => e.trim()).toList(),
                      'salary': {
                        'min' : int.tryParse(_minSalaryController.text.trim()) ?? 20000,
                        'max' : int.tryParse(_maxSalaryController.text.trim()) ?? 100000,
                      },
                      'location': _locationController.text.trim(),
                      'type': _typeController.text.trim(),
                      'remote': isRemoteWork,
                      'postedAt': FieldValue.serverTimestamp(),
                      'period': _periodController.text.trim(),
                      'age': {
                        'min': int.tryParse(_minAgeController.text.trim()) ?? 18,
                        'max': int.tryParse(_maxAgeController.text.trim()) ?? 40,
                      },
                      'experience': int.tryParse(_experienceController.text.trim()) ?? 0,
                      'category': selectedCat,
                      'requiredPosts': int.tryParse(_requiredPostsController.text.trim()),
                      'proposals': 0,
                      'status': 'active',
                      'views': 0,
                      'userId': FirebaseAuth.instance.currentUser!.uid,
                    };

                    if (widget.jobId == null) {
                      // Add new
                      final String recruiterId = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance.collection('jobs').add(jobData);
                      await FirebaseFirestore.instance.collection('recruiters').doc(recruiterId).update({
                        'jobCount': FieldValue.increment(1),
                      });
                    } else {
                      // Edit
                      await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update(jobData);

                      final querySnap = await FirebaseFirestore.instance
                            .collection('proposals')
                            .where('jobId', isEqualTo: widget.jobId)
                            .get();

                      final candidates = querySnap.docs;

                      for (final doc in candidates) {
                        final userId = doc['userId'];
                        await FirebaseFirestore.instance.collection('notifications').add({
                          'fromUserId': FirebaseAuth.instance.currentUser!.uid,
                          'toUserId': userId,
                          'title': 'Offer Updated',
                          'description': 'An offer that you apply for is updated',
                          'date': Timestamp.now(),
                          'image': 'images/notif_bell.png',
                          'type': 'alert',
                          'status': 'unread'
                        });
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Job offer saved successfully!'),
                        backgroundColor: Color(0xFF8B7ED8),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B7ED8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 75,)
            ],
          ),
          ]
                ),
              ],
              )]),
        )));

  }
}
