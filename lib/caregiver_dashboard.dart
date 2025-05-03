import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testapp/behavior_tracking_home_page.dart';
import 'package:testapp/image_upload_page.dart';
import 'package:testapp/main_dashboard.dart';
import 'package:testapp/reminder_page.dart';
import 'package:testapp/signin.dart' as signin;
import 'mood_tracking.dart';
import 'selfcarediary.dart';
import 'settings_page.dart';
import 'reports_insights_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testapp/add_task_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autism Care Dashboard',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        hintColor: Colors.white,
      ),
      home: const CaregiverDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  _CaregiverDashboardState createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    User? user = getCurrentUser();
    String userId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Caregiver Dashboard',
          style: TextStyle(color: Colors.black),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'Caregiver Name'),
              accountEmail: Text(user?.email ?? 'caregiver@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue[400]),
              ),
              decoration: BoxDecoration(color: Colors.blue[400]),
            ),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainDashboard(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Behavior Tracking'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BehaviorTrackingHomePage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('AI Self-Care Diary'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AISelfCareDiaryPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Mood Tracking'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodTrackingPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Manage Tasks'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Image Communication'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageUploadPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Reminders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Reports & Insights'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsInsightsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const signin.SignInPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upcoming Reminders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Upcoming Reminders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('reminders')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(
                      'No reminders for today.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  var reminders = snapshot.data!.docs;

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        reminders.map((doc) {
                          return Container(
                            width: (MediaQuery.of(context).size.width / 2) - 24,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Colors
                                      .primaries[doc.id.hashCode %
                                          Colors.primaries.length]
                                      .shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  doc['description'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Child Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Child\'s Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddTaskPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Inside your Child's Tasks Section (replace the previous one)
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection('users')
                          .doc(userId)
                          .collection('child')
                          .doc('childProfile')
                          .collection('tasks')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No tasks available.'));
                    }

                    var tasks = snapshot.data!.docs;

                    return Column(
                      children:
                          tasks.map((taskDoc) {
                            String status = taskDoc['status'] ?? 'not done';
                            Color lineColor =
                                status == 'done' ? Colors.green : Colors.red;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    taskDoc['taskName'] ?? 'Task',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 4,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: lineColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
