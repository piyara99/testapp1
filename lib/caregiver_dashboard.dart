import 'package:flutter/material.dart';
import 'package:testapp/signin.dart';
import 'mood_tracking.dart'; // Import the mood_tracking.dart page
import 'task_management.dart'; // Import the task_management.dart page

void main() {
  runApp(MyApp());
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
      home: CaregiverDashboard(),
    );
  }
}

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CaregiverDashboardState createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background Color
      appBar: AppBar(
        title: Text('Caregiver Dashboard'),
        backgroundColor: Colors.blue[400], // Calm Blue
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Caregiver Name'),
              accountEmail: Text('caregiver@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue[400]),
              ),
              decoration: BoxDecoration(color: Colors.blue[400]),
            ),
            ListTile(title: Text('Dashboard'), onTap: () {}),
            ListTile(title: Text('Settings'), onTap: () {}),
            ListTile(
              title: const Text('Mood Tracking'),
              onTap: () {
                // Navigate to the MoodTrackingPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MoodTrackingPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Manage Tasks'),
              onTap: () {
                // Navigate to the Task Management Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskManagementPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                // Navigate to Sign In Page after log out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
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
            Card(
              color: Colors.blue[50],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Task Completed: Brushing Teeth',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ),
            Card(
              color: Colors.blue[50],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Reminder: Schedule doctor visit',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Overview Section for Completed Tasks
            Text(
              'Child\'s Completed Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[400],
              ),
            ),
            Card(
              color: Colors.blue[50],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '1. Brushed Teeth - 10:00 AM',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ),
            Card(
              color: Colors.blue[50],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '2. Took Medication - 11:30 AM',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
