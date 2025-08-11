import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../notifications_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int selectedIndex = 0;
  final userName = FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];

  int activeJobs = 0;
  int prevActiveJobs = 0;

  int totalApplications = 0;
  int prevApplications = 0;

  int totalInterviews = 0;
  int prevInterviews = 0;

  int totalHired = 0;
  int prevHired = 0;


  List<FlSpot> chartData = [];
  List<Map<String, dynamic>> recentActivities = [];
  List<Map<String, dynamic>> topJobs = [];

  bool isLoading = true;
  String selectedTimeRange = 'Last 7 Days';
  List<String> jobIds = [];

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<List<QueryDocumentSnapshot>> getProposalsForJobIds({
    required List<String> jobIds,
    required DateTime start,
    DateTime? end,
    String? status,
  }) async {
    List<QueryDocumentSnapshot> allDocs = [];

    for (int i = 0; i < jobIds.length; i += 10) {
      final batch = jobIds.sublist(i, i + 10 > jobIds.length ? jobIds.length : i + 10);

      Query query = FirebaseFirestore.instance
          .collection('proposals')
          .where('jobId', whereIn: batch)
          .where('submittedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start));

      if (end != null) {
        query = query.where('submittedAt', isLessThan: Timestamp.fromDate(end));
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final result = await query.get();
      allDocs.addAll(result.docs);
    }

    return allDocs;
  }


  Future<void> fetchStatistics() async {
    setState(() {
      isLoading = true;
    });


    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final fourteenDaysAgo = now.subtract(const Duration(days: 14));

      final currentProposalsDocs = await getProposalsForJobIds(
        jobIds: jobIds,
        start: sevenDaysAgo,
        end: now,
      );

      final previousProposalsDocs = await getProposalsForJobIds(
        jobIds: jobIds,
        start: fourteenDaysAgo,
        end: sevenDaysAgo,
      );

      // Interviews
      final currentInterviews = await FirebaseFirestore.instance
          .collection('interviews')
          .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      final previousInterviews = await FirebaseFirestore.instance
          .collection('interviews')
          .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(fourteenDaysAgo))
          .where('scheduledAt', isLessThan: Timestamp.fromDate(sevenDaysAgo))
          .get();

      // Active Jobs - just count current
      final activeJobsSnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'active')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      jobIds = activeJobsSnapshot.docs.map((doc) => doc.id).toList();

      final currentHiredDocs = await getProposalsForJobIds(
        jobIds: jobIds,
        start: sevenDaysAgo,
        status: 'hired',
      );

      final previousHiredDocs = await getProposalsForJobIds(
        jobIds: jobIds,
        start: fourteenDaysAgo,
        end: sevenDaysAgo,
        status: 'hired',
      );

      //print('Active jobs: ${activeJobsSnapshot.docs.length}');

      setState(() {
        activeJobs = activeJobsSnapshot.docs.length;

        totalApplications = currentProposalsDocs.length;
        prevApplications = previousProposalsDocs.length;

        totalInterviews = currentInterviews.docs.length;
        prevInterviews = previousInterviews.docs.length;

        totalHired = currentHiredDocs.length;
        prevHired = previousHiredDocs.length;
      });

      await generateChartData().timeout(Duration(seconds: 10));
      await fetchRecentActivities();
      await fetchTopJobs();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching statistics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> generateChartData() async {


    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    List<FlSpot> spots = [];

    for (int i = 0; i < 7; i++) {
      final day = sevenDaysAgo.add(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayDocs = await getProposalsForJobIds(
        jobIds: jobIds,
        start: dayStart,
        end: dayEnd,
      );

      spots.add(FlSpot(i.toDouble(), dayDocs.length.toDouble()));
    }

    chartData = spots;
  }

  Future<void> fetchRecentActivities() async {


    final activities = <Map<String, dynamic>>[];

    // Fetch recent applications
    final recentApplications = await FirebaseFirestore.instance
        .collection('proposals')
        .where('jobId', whereIn: jobIds)
        .orderBy('submittedAt', descending: true)
        .limit(3)
        .get();

    for (var doc in recentApplications.docs) {
      final data = doc.data();
      activities.add({
        'icon': Icons.person_add,
        'title': 'New application received',
        'subtitle': '${data['jobTitle'] ?? 'Unknown position'}',
        'time': _formatTime(data['submittedAt'] as Timestamp),
        'color': const Color(0xFF4CAF50),
      });
    }

    // Fetch recent interviews
    final recentInterviews = await FirebaseFirestore.instance
        .collection('interviews')
        .where('recruiterId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('scheduledAt', descending: true)
        .limit(2)
        .get();

    for (var doc in recentInterviews.docs) {
      final data = doc.data();
      activities.add({
        'icon': Icons.schedule,
        'title': 'Interview scheduled',
        'subtitle': 'With ${data['candidateName'] ?? 'candidate'}',
        'time': _formatTime(data['scheduledAt'] as Timestamp),
        'color': const Color(0xFF2196F3),
      });
    }

    // Sort activities by time
    activities.sort((a, b) => b['time'].compareTo(a['time']));

    recentActivities = activities.take(5).toList();
  }

  Future<void> fetchTopJobs() async {
    final jobsSnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('status', isEqualTo: 'active')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    List<Map<String, dynamic>> jobsWithStats = [];

    for (var jobDoc in jobsSnapshot.docs) {
      final jobData = jobDoc.data();

      // Count applications for this job
      final applicationsCount = await FirebaseFirestore.instance
          .collection('proposals')
          .where('jobId', isEqualTo: jobDoc.id)
          .get();

      // Count views (you might need to implement view tracking)
      final viewsCount = jobData['views'] ?? 0;

      jobsWithStats.add({
        'id': jobDoc.id,
        'title': jobData['title'] ?? 'Unknown Job',
        'applications': applicationsCount.docs.length,
        'views': viewsCount,
        'color': _getJobColor(jobsWithStats.length),
      });
    }

    // Sort by applications count
    jobsWithStats.sort((a, b) => b['applications'].compareTo(a['applications']));

    topJobs = jobsWithStats.take(3).toList();
  }

  Color _getJobColor(int index) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
    ];
    return colors[index % colors.length];
  }

  String _formatTime(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  String _calculateTrend(int current, int previous) {
    if (previous == 0) return "+$current new";
    final diff = current - previous;
    final percentChange = ((diff / previous) * 100).toStringAsFixed(0);
    return "${diff >= 0 ? "+$percentChange%" : "$percentChange%"} vs last week";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdfddf3),
      appBar: AppBar(
        backgroundColor: Color(0xffbfbcf3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7ED8)),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B7ED8), Color(0xFFB19CD9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B7ED8).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $userName!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Here\'s what\'s happening with your jobs',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    title: 'Active Jobs',
                    value: activeJobs.toString(),
                    icon: Icons.work_outline,
                    color: const Color(0xFF4CAF50),
                    trend: '+${activeJobs} open',
                  ),
                  _buildStatCard(
                    title: 'Applications',
                    value: totalApplications.toString(),
                    icon: Icons.assignment_outlined,
                    color: const Color(0xFF2196F3),
                    trend: _calculateTrend(totalApplications, prevApplications),
                  ),
                  _buildStatCard(
                    title: 'Interviews',
                    value: totalInterviews.toString(),
                    icon: Icons.people_outline,
                    color: const Color(0xFFFF9800),
                    trend: _calculateTrend(totalInterviews, prevInterviews),
                  ),
                  _buildStatCard(
                    title: 'Hired',
                    value: totalHired.toString(),
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF9C27B0),
                    trend: _calculateTrend(totalHired, prevHired),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Applications Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Applications Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B7ED8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Last 7 days',
                            style: TextStyle(
                              color: Color(0xFF8B7ED8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  return Text(
                                    days[value.toInt() % days.length],
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData.isNotEmpty ? chartData : [
                                const FlSpot(0, 0),
                                const FlSpot(1, 0),
                                const FlSpot(2, 0),
                                const FlSpot(3, 0),
                                const FlSpot(4, 0),
                                const FlSpot(5, 0),
                                const FlSpot(6, 0),
                              ],
                              isCurved: true,
                              color: const Color(0xFF8B7ED8),
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF8B7ED8).withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (recentActivities.isEmpty)
                      const Center(
                        child: Text(
                          'No recent activity',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...recentActivities.map((activity) => _buildActivityItem(
                        icon: activity['icon'],
                        title: activity['title'],
                        subtitle: activity['subtitle'],
                        time: activity['time'],
                        color: activity['color'],
                      )).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Top Performers
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Job Postings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (topJobs.isEmpty)
                      const Center(
                        child: Text(
                          'No jobs available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...topJobs.map((job) => _buildJobItem(
                        title: job['title'],
                        applications: job['applications'],
                        views: job['views'],
                        color: job['color'],
                      )).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
            ],
          ),
          Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }


  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildJobItem({
    required String title,
    required int applications,
    required int views,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$applications applications',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$views views',
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
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}










/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedFilter = 'Last 7 Days';
  List<String> filters = ['Today', 'Last 7 Days', 'This Month'];

  List<FlSpot> lineChartData = [];
  List<Map<String, dynamic>> recentApplications = [];

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    // Simulate line data points (replace with real Firebase aggregation)
    lineChartData = List.generate(7, (index) => FlSpot(index.toDouble(), (5 + index * 2).toDouble()));

    // Fetch recent applications (simulate or fetch from 'proposals' collection)
    final snapshot = await FirebaseFirestore.instance
        .collection('proposals')
        .where('submittedAt', isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(0))
        .orderBy('submittedAt', descending: true)
        .limit(5)
        .get();

    setState(() {
      recentApplications = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Widget buildFilterDropdown() {
    return DropdownButton<String>(
      value: selectedFilter,
      items: filters.map((f) {
        return DropdownMenuItem(value: f, child: Text(f));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedFilter = value!;
          fetchStats();
        });
      },
    );
  }

  Widget buildLineChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 2),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                return Text(DateFormat('E').format(day));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: lineChartData,
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  Widget buildRecentApplications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recentApplications.map((app) {
        return ListTile(
          leading: Icon(Icons.person_outline),
          title: Text(app['candidateName'] ?? 'Unknown'),
          subtitle: Text('Applied to: ${app['jobTitle'] ?? 'Job'}'),
          trailing: Text(DateFormat('MMM d').format((app['submittedAt'] as Timestamp).toDate())),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5fc),
      appBar: AppBar(
        backgroundColor: Color(0xffbfbcf3),
        title: Text('Statistics Dashboard', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter by:', style: TextStyle(fontSize: 16)),
                buildFilterDropdown(),
              ],
            ),
            SizedBox(height: 20),

            // Line Chart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Applications Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: buildLineChart()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Recent Applications
            Text('Recent Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              elevation: 2,
              margin: EdgeInsets.only(top: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildRecentApplications(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/







/*import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}*/
