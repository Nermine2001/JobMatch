import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jobmatch_app/screens/job_seekers/application_screen.dart';

import '../job_details_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

Future<List<dynamic>> fetchRecommendations({
  required Map<String, dynamic> user,
  required List<Map<String, dynamic>> jobs,
  int topK = 10,
  double threshold = 0.3  // Lowered threshold
}) async {
  final url = Uri.parse('http://10.0.2.2:8000/recommend');

  final requestBody = {
    'user_profile': user,
    'jobs': jobs,
    'top_k': topK,
    'threshold': threshold
  };

  print('Request body: ${jsonEncode(requestBody)}');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // The API returns a list directly, not wrapped in a success object
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('recommendations')) {
        return data['recommendations'];
      }
    }
    throw Exception('Failed to fetch recommendations: ${response.statusCode}');
  } catch (e) {
    print('Error in fetchRecommendations: $e');
    throw e;
  }
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<dynamic> recommendations = [];
  bool loading = true;
  List<String> titles = <String>[];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      // Get user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      final jobSeekerDoc = await FirebaseFirestore.instance
          .collection('job_seekers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;

      // Get favorites safely
      List<String> favoritesIds = [];
      if (jobSeekerDoc.exists) {
        final jobSeekerData = jobSeekerDoc.data()!;
        if (jobSeekerData.containsKey('favorites')) {
          final favorites = jobSeekerData['favorites'];
          if (favorites is List) {
            favoritesIds = favorites.map((e) => e.toString()).toList();
          }
        }
      }

      // Get favorite job titles
      titles.clear();
      if (favoritesIds.isNotEmpty) {
        const int chunkSize = 10;
        for (int i = 0; i < favoritesIds.length; i += chunkSize) {
          final chunk = favoritesIds.sublist(
            i,
            i + chunkSize > favoritesIds.length ? favoritesIds.length : i + chunkSize,
          );

          final jobQuery = await FirebaseFirestore.instance
              .collection('jobs')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          for (var doc in jobQuery.docs) {
            final docData = doc.data();
            if (docData.containsKey('title')) {
              titles.add(docData['title'].toString());
            }
          }
        }
      }

      // Build user profile for API
      final user = {
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'skills': _parseSkills(userData['skills']),
        'experience': _parseExperience(userData['experience']),
        'location': userData['location']?.toString() ?? 'Unknown',
        'preferred_titles': titles,
      };

      print('User profile: $user');

      // Get all jobs
      final jobsSnap = await FirebaseFirestore.instance.collection('jobs').get();

      final jobs = jobsSnap.docs.map((doc) {
        final data = doc.data();

        // Convert Timestamps to strings
        final processedData = <String, dynamic>{};
        data.forEach((key, value) {
          if (value is Timestamp) {
            processedData[key] = value.toDate().toIso8601String();
          } else {
            processedData[key] = value;
          }
        });

        return {
          'job_id': doc.id,
          'title': processedData['title']?.toString() ?? 'Unknown',
          'company': processedData['company']?.toString() ?? 'Unknown',
          'location': processedData['location']?.toString() ?? 'Unknown',
          'description': processedData['description']?.toString() ?? '',
          'skills': List<String>.from(processedData['skills'] ?? []),
          'work_type': processedData['category']?.toString() ?? 'Unknown',
          'employment_type': processedData['type']?.toString() ?? 'Unknown',
        };
      }).toList();

      print('Jobs count: ${jobs.length}');

      // Get recommendations
      final results = await fetchRecommendations(
          user: user,
          jobs: jobs,
          threshold: 0.2  // Lower threshold for testing
      );

      for (var rec in results) {
        try {
          final jobId = rec['job_id']?.toString() ?? '';
          final title = rec['title']?.toString() ?? 'Unknown Title';
          final company = rec['company']?.toString() ?? 'Unknown Company';
          final location = rec['location']?.toString() ?? 'Unknown Location';
          final probability = (rec['probability'] as num?)?.toDouble() ?? 0.0;
          final confidence = rec['confidence']?.toString() ?? 'Unknown';
          final matchReasons = (rec['match_reasons'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

          // pour éviter les répetitions
          final docId = '${FirebaseAuth.instance.currentUser!.uid}_$jobId';

          await FirebaseFirestore.instance.collection('recommendations').doc(docId).set({
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'jobId': jobId,
            'title': title,
            'company': company,
            'location': location,
            'probability': probability,
            'confidence': confidence,
            'matchReasons': matchReasons,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error saving recommendation for jobId: ${rec['job_id']} → $e');
        }
      }

      print('Recommendations received: ${results.length}');

      setState(() {
        recommendations = results;
        loading = false;
      });
    } catch (e, stackTrace) {
      print('Error in loadRecommendations: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        loading = false;
        errorMessage = 'Failed to load recommendations: $e';
      });
    }
  }

  List<String> _parseSkills(dynamic skills) {
    if (skills == null) return [];
    if (skills is String) {
      return skills.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    if (skills is List) {
      return skills.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  int _parseExperience(dynamic experience) {
    if (experience == null) return 0;
    if (experience is int) return experience;
    if (experience is String) {
      return int.tryParse(experience) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadRecommendations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No recommendations found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try updating your profile or skills',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadRecommendations,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        try {
          final recommendation = recommendations[index];

          // Safely access fields with null checks
          final title = recommendation['title']?.toString() ?? 'Unknown Title';
          final company = recommendation['company']?.toString() ?? 'Unknown Company';
          final location = recommendation['location']?.toString() ?? 'Unknown Location';
          final jobId = recommendation['job_id']?.toString() ?? '';
          final probability = (recommendation['probability'] as num?)?.toDouble() ?? 0.0;
          final confidence = recommendation['confidence']?.toString() ?? 'Unknown';
          final matchReasons = recommendation['match_reasons'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and confidence
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                company,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildConfidenceChip(confidence),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Probability score
                    Row(
                      children: [
                        Text(
                          'Match Score: ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${(probability * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(probability),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Progress bar
                    LinearProgressIndicator(
                      value: probability,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(probability),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Match reasons
                    if (matchReasons.isNotEmpty) ...[
                      Text(
                        'Why this recommendation:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...matchReasons.map((reason) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reason.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            try {
                              /*await FirebaseFirestore.instance
                                  .collection('recommendations')
                                  .add({
                                'userId': FirebaseAuth.instance.currentUser!.uid,
                                'jobId': jobId,
                                'title': title,
                                'company': company,
                                'location': location,
                                'probability': probability,
                                'confidence': confidence,
                                'matchReasons': matchReasons.map((e) => e.toString()).toList(),
                                'timestamp': FieldValue.serverTimestamp(),
                              });*/

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsScreen(jobId: jobId),
                                ),
                              );
                            } catch (e) {
                              print('Error saving recommendation: $e');
                              // Still navigate to details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsScreen(jobId: jobId),
                                ),
                              );
                            }
                          },
                          child: const Text('View Details'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApplicationScreen(jobId: jobId),
                              ),
                            );
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } catch (e, stackTrace) {
          print('Error rendering recommendation at index $index: $e');
          print('Stack trace: $stackTrace');
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error rendering recommendation'),
                  const SizedBox(height: 8),
                  Text('Index: $index', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildConfidenceChip(String confidence) {
    Color backgroundColor;
    Color textColor;

    switch (confidence.toLowerCase()) {
      case 'très élevée':
      case 'very high':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'élevée':
      case 'high':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'moyenne':
      case 'medium':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        confidence,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.blue;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }
}