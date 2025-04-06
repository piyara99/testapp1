import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testapp/image_upload_page.dart';
import 'package:testapp/main_dashboard.dart';
import 'package:testapp/reminder_page.dart';
import 'package:testapp/signin.dart'
    as signin; // Import SignInPage with a prefix
import 'mood_tracking.dart';
import 'task_management.dart'
    as task; // Import TaskManagementPage with a prefix
import 'behavior_tracking.dart';
import 'selfcarediary.dart';
import 'settings_page.dart';
import 'reports_insights_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

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
        primaryColor: Colors.blue[400], // Calm Blue
        hintColor: Colors.white, // White
      ),
      home: const CaregiverDashboard(),
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

  // Function to get the current user's info
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    User? user = getCurrentUser();
    String userId = user?.uid ?? ''; // Get the current user's ID

    return Scaffold(
      backgroundColor: Colors.white, // Background Color
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        backgroundColor: Colors.blue[400], // Calm Blue
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
                    builder: (context) => BehaviorTrackingPage(),
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
                  MaterialPageRoute(
                    builder: (context) => task.TaskManagementPage(),
                  ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Latest Notifications Section
            Text(
              'Latest Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[400],
              ),
            ),

            // StreamBuilder to fetch reminders from Firestore
            StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('users')
                      .doc(userId) // Access the user's specific document
                      .collection('reminders') // Fetch reminders for the user
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading reminders'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No reminders available'));
                }

                // Get the reminder data from Firestore
                var reminders = snapshot.data!.docs;

                return Column(
                  children:
                      reminders.map<Widget>((reminder) {
                        return Card(
                          color: Colors.blue[50],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Assuming 'title' and 'message' fields exist in Firestore
                                Text(
                                  reminder['title'] ?? 'No Title',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reminder['description'] ?? 'No Message',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
            // Overview Section for Completed Tasks
            Text(
              'Child\'s Completed Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BehaviorTrackingPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400], // Match theme color
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Track Behavior',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            // StreamBuilder to fetch tasks from Firestore
            StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('users')
                      .doc(userId) // Access the user's document
                      .collection('child') // Access the child's data
                      .doc('childProfile') // Access the child's profile
                      .collection('tasks') // Fetch tasks
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tasks'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tasks available'));
                }

                var tasks = snapshot.data!.docs;
                return Column(
                  children:
                      tasks.map<Widget>((taskDoc) {
                        // Get task status and determine color
                        String status = taskDoc['status'] ?? 'not done';
                        Color taskColor =
                            status == 'done' ? Colors.green : Colors.red;

                        return Card(
                          color: taskColor.withOpacity(
                            0.1,
                          ), // Color change based on status
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display task title
                                Text(
                                  taskDoc['taskName'] ?? 'No Title',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: taskColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
