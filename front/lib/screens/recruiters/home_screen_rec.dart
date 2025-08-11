import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobmatch_app/screens/filter_screen.dart';
import 'package:jobmatch_app/screens/job_details_screen.dart';
import 'package:jobmatch_app/screens/job_seekers/recommendations_screen.dart';
import 'package:jobmatch_app/screens/notifications_screen.dart';
import 'package:jobmatch_app/screens/profile_screen.dart';
import 'package:jobmatch_app/screens/recruiters/your_offers_screen.dart';
import 'package:jobmatch_app/screens/settings_screen.dart';

import 'add_or_edit_offer_screen.dart';

class HomeScreenRec extends StatefulWidget {
  final Map<String, dynamic>? filters;

  const HomeScreenRec({super.key, this.filters });

  @override
  State<HomeScreenRec> createState() => _HomeScreenRecState();
}

class _HomeScreenRecState extends State<HomeScreenRec> {
  int _selectedIndex = 0;
  List<String> _favoriteJobs = [];
  Map<String, dynamic>? filters;
  String? _sortBy;
  String? _searchQuery;

  final List<String> _titles = [
    'Looking for a worker',
    'Your offers',
    'Settings',
    'Profile',
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filters = widget.filters;
    fetchFavorites(FirebaseAuth.instance.currentUser!.uid);
  }

  Stream<QuerySnapshot> getFilteredJobs({String? sortBy}) {
    Query query = FirebaseFirestore.instance.collection('jobs');

    if (filters != null) {
      if (filters!['category'] != null && filters!['category'] != '...') {
        query = query.where('category', isEqualTo: filters!['category']);
      }

      if (filters!['position'] != null && filters!['position'].isNotEmpty) {
        query = query.where('title', isEqualTo: filters!['position']);
      }

      if (filters!['minSalary'] != null && filters!['minSalary'].isNotEmpty) {
        final minSalary = int.tryParse(filters!['minSalary']);
        if (minSalary != null)
          query = query.where('salary', isGreaterThanOrEqualTo: minSalary);
      }

      if (filters!['maxSalary'] != null && filters!['maxSalary'].isNotEmpty) {
        final maxSalary = int.tryParse(filters!['maxSalary']);
        if (maxSalary != null)
          query = query.where('salary', isLessThanOrEqualTo: maxSalary);
      }

      if (filters!['minExperience'] != null) {
        query = query.where(
            'experience', isGreaterThanOrEqualTo: filters!['minExperience']);
      }

      if (filters!['maxExperience'] != null) {
        query = query.where(
            'experience', isLessThanOrEqualTo: filters!['maxExperience']);
      }

      if (filters!['minAge'] != null && filters!['minAge'].isNotEmpty) {
        final minAge = int.tryParse(filters!['minAge']);
        if (minAge != null)
          query = query.where('age', isGreaterThanOrEqualTo: minAge);
      }

      if (filters!['maxAge'] != null && filters!['maxAge'].isNotEmpty) {
        final maxAge = int.tryParse(filters!['maxAge']);
        if (maxAge != null)
          query = query.where('age', isLessThanOrEqualTo: maxAge);
      }

      if (filters!['location'] != null && filters!['location'].isNotEmpty) {
        query = query.where('location', isEqualTo: filters!['location']);
      }

      if (filters!['workPeriod'] != null && filters!['workPeriod'].isNotEmpty) {
        query = query.where('period', isEqualTo: filters!['workPeriod']);
      }
    }

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      query = query.where('title', isGreaterThanOrEqualTo: _searchQuery)
          .where('title', isLessThanOrEqualTo: _searchQuery! + '\uf8ff');
    }

    if (sortBy != null) {
      query = query.orderBy(sortBy);
    }

    return query.snapshots();
  }


  Future<void> fetchFavorites(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('job_seekers').doc(
        uid).get();
    final data = doc.data();

    if (data != null && data['favorites'] != null) {
      _favoriteJobs = List<String>.from(data['favorites']);
    }
  }

  void toggleFavorite(String jobId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isFavorite = _favoriteJobs.contains(jobId);

    setState(() {
      if (isFavorite) {
        _favoriteJobs.remove(jobId);
      } else {
        _favoriteJobs.add(jobId);
      }
    });


    final jobSeeker = FirebaseFirestore.instance.collection('job_seekers').doc(
        uid);

    await jobSeeker.update({
      'favorites': isFavorite
          ? FieldValue.arrayRemove([jobId])
          : FieldValue.arrayUnion([jobId])
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xffbfbcf3) : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xffbfbcf3) : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeTabScreen(
          favoriteJobs: _favoriteJobs,
          onToggleFavorite: toggleFavorite,
          jobsStream: getFilteredJobs(sortBy: _sortBy),
          sortBy: _sortBy,
          onSortChanged: (String? newSortBy) {
            setState(() {
              _sortBy = newSortBy;
            });
          }
      ),
      YourOffersScreen(
        jobsStream: FirebaseFirestore.instance
            .collection('jobs')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        favoriteJobs: _favoriteJobs,
        onToggleFavorite: toggleFavorite,
      ),
      SettingsScreen(),
      ProfileScreen(),
    ];

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
          _titles[_selectedIndex],
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
        bottom: _titles[_selectedIndex] == 'Looking for a worker'
            ? PreferredSize(
            preferredSize: Size.fromHeight(70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchAnchor(
                      builder: (BuildContext context,
                          SearchController controller) {
                        return SearchBar(
                          constraints: BoxConstraints(
                            maxWidth: 360,
                            minHeight: 45,
                          ),
                          controller: controller,
                          padding: WidgetStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(horizontal: 16)),
                          onTap: () {
                            controller.openView();
                          },
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          leading: Icon(Icons.search),
                          hintText: 'Hinted search text',
                        );
                      },
                      suggestionsBuilder: (BuildContext context,
                          SearchController controller) {
                        return List<ListTile>.generate(5, (int index) {
                          final String item = 'item $index';
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              /*setState(() {
                                controller.closeView(item);
                              });*/
                            },
                          );
                        });
                      }
                  ),
                ),
                SizedBox(width: 5.0,),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Color(0xffdfddf3),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    child: Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.black,
                    ),
                    onTap: () async {
                      final selectedFilters = await Navigator.push<
                          Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(builder: (_) => FilterScreen()),
                      );

                      if (selectedFilters != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) =>
                              HomeScreenRec(filters: selectedFilters)),
                        );
                      }
                    },

                  ),
                )
              ],
            )
        )
            : null,

      ),
      // search bar + filter
      body: _pages[_selectedIndex],
      bottomNavigationBar: /*_selectedIndex == 1 ?*/ Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.check_circle_outline, 'Your offers', 1),
            // Bouton d'ajout au milieu
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
                  // Naviguer vers l'écran d'ajout d'offre
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddOrEditOfferScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            _buildNavItem(Icons.settings_outlined, 'Settings', 2),
            _buildNavItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      )/* : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xffbfbcf3),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Your offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),*/
    );
  }
}


class HomeTabScreen extends StatefulWidget {
  final List<String> favoriteJobs;
  final Stream<QuerySnapshot> jobsStream;
  final Function(String jobId) onToggleFavorite;
  final String? sortBy;
  final Function(String?) onSortChanged;

  const HomeTabScreen({
    super.key,
    required this.favoriteJobs,
    required this.onToggleFavorite,
    required this.jobsStream,
    this.sortBy,
    required this.onSortChanged });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {

  String? _sortBy;

  Widget _buildJobCard(String jobId, String company, String position,
      Map<String, dynamic> salary, List<String> skills, String location, bool isRemote, String type) {
    // bool isFavorite = widget.favoriteJobs.contains(jobId);
    return GestureDetector(
      onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsScreen(jobId: jobId)));
          await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
            'views': FieldValue.increment(1),
          });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Salary: ${salary['min']} - ${salary['max']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            isRemote ? 'Remote' : 'Non Remote',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                /*IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                  onPressed: () => widget.onToggleFavorite(jobId),
                ),*/
                //Icon(Icons.favorite_border, color: Colors.grey, size: 25),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: skills.map((skill) =>
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF6B46C1).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      {required IconData icon, required String label, required String sortField}) {
    final bool isSelected = widget.sortBy == sortField;
    return GestureDetector(
      onTap: () {
        widget.onSortChanged(isSelected ? null : sortField);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: isSelected ? Border.all() : null,
          color: isSelected ? Color(0xffbfbcf5) : Color(0xff8d71cb),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.black),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip(icon: Icons.location_on_outlined,
                  label: 'Location',
                  sortField: 'location'),
              SizedBox(width: 12),
              _buildFilterChip(icon: Icons.work_outline,
                  label: 'Job Type',
                  sortField: 'type'),
              SizedBox(width: 12,),
              _buildFilterChip(icon: Icons.schedule_outlined,
                  label: 'Period',
                  sortField: 'period'),
              SizedBox(width: 12),
              _buildFilterChip(icon: Icons.attach_money_outlined,
                  label: 'Cost',
                  sortField: 'salary'),
            ],
          ),
          SizedBox(height: 15,),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.jobsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No jobs found.'));
                }

                final jobs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    final jobId = job.id;
                    final data = job.data() as Map<String, dynamic>;

                    return Column(
                      children: [
                        _buildJobCard(
                          jobId,
                          data['company'] ?? 'Unknown',
                          data['title'] ?? '',
                          data['salary'],
                          List<String>.from(data['skills'] ?? []),
                          data['location'],
                          data['remote'],
                          data['type']
                        ),
                        SizedBox(height: 12),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          /*Expanded(
              child: ListView(
                children: [
                  _buildJobCard('job1', 'Company1', 'Flutter Developer', '40000 - 55000', ['Flutter', 'Dart', 'Firebase']),
                  SizedBox(height: 12,),
                  _buildJobCard('job2', 'Company1', 'Flutter Developer', '40000 - 55000', ['Flutter', 'Dart', 'Firebase']),
                  SizedBox(height: 12,),
                  _buildJobCard('job3', 'Company1', 'Flutter Developer', '40000 - 55000', ['Flutter', 'Dart', 'Firebase']),
                  SizedBox(height: 12,),
                  _buildJobCard('job4', 'Company1', 'Flutter Developer', '40000 - 55000', ['Flutter', 'Dart', 'Firebase']),
                  SizedBox(height: 12,),
                  _buildJobCard('job5', 'Company1', 'Flutter Developer', '40000 - 55000', ['Flutter', 'Dart', 'Firebase']),
                  SizedBox(height: 12,),
                ],
              )
          ),*/
        ],
      ),
    );
  }
}
