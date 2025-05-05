import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:testapp/behavior_tracking_home_page.dart';
import 'package:testapp/image_upload_page.dart';
import 'package:testapp/main_dashboard.dart';
import 'package:testapp/planner_page.dart';
import 'package:testapp/reminder_page.dart';
import 'package:testapp/signin.dart' as signin;
import 'package:testapp/mood_tracking.dart';
import 'package:testapp/selfcarediary.dart';
import 'package:testapp/settings_page.dart';
import 'package:testapp/reports_insights_page.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() => _auth.currentUser;

  Future<double> _getTaskCompletionPercentage() async {
    final userId = _auth.currentUser?.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('child')
            .doc('childProfile')
            .collection('tasks')
            .doc(today)
            .collection('taskList')
            .get();

    if (snapshot.docs.isEmpty) return 0;

    final total = snapshot.docs.length;
    final completed =
        snapshot.docs
            .where((doc) => doc['status']?.toLowerCase() == 'completed')
            .length;

    return (completed / total) * 100;
  }

  Future<Map<String, List<Map<String, dynamic>>>>
  _getUpcomingReminders() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {'today': [], 'tomorrow': []};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('reminders')
            .get();

    final Map<String, List<Map<String, dynamic>>> groupedReminders = {
      'today': [],
      'tomorrow': [],
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['time'];
      if (timestamp is! Timestamp) continue;

      final time = timestamp.toDate();
      final dateOnly = DateTime(time.year, time.month, time.day);
      data['parsedTime'] = time;

      if (dateOnly == today) {
        groupedReminders['today']!.add(data);
      } else if (dateOnly == tomorrow) {
        groupedReminders['tomorrow']!.add(data);
      }
    }

    // Sort each group by time
    groupedReminders['today']!.sort(
      (a, b) =>
          (a['parsedTime'] as DateTime).compareTo(b['parsedTime'] as DateTime),
    );
    groupedReminders['tomorrow']!.sort(
      (a, b) =>
          (a['parsedTime'] as DateTime).compareTo(b['parsedTime'] as DateTime),
    );

    return groupedReminders;
  }

  @override
  Widget build(BuildContext context) {
    final user = getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD8CFF4),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Caregiver Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTaskStatusCard(),
          const SizedBox(height: 16),
          _buildRemindersCard(), // ✅ This now works
          const SizedBox(height: 24),
          const Text(
            "Quick Access",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickCard(
                'Behavior Tracking',
                Icons.track_changes,
                Colors.blue,
                BehaviorTrackingHomePage(),
              ),
              _buildQuickCard(
                'Image Communication',
                Icons.image,
                Colors.green,
                ImageUploadPage(),
              ),
              _buildQuickCard(
                'Mood Tracking',
                Icons.mood,
                Colors.orange,
                const MoodTrackingPage(),
              ),
              _buildQuickCard(
                'Manage Tasks',
                Icons.list_alt,
                Colors.purple,
                PlannerPage(),
              ),
              _buildQuickCard(
                'Reminders',
                Icons.notifications,
                Colors.red,
                ReminderPage(),
              ),
              _buildQuickCard(
                'Reports & Insights',
                Icons.analytics,
                Colors.teal,
                const ReportsInsightsPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard() {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _getUpcomingReminders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final grouped = snapshot.data!;
        final todayReminders = grouped['today']!;
        final tomorrowReminders = grouped['tomorrow']!;

        if (todayReminders.isEmpty && tomorrowReminders.isEmpty) {
          return const Text('No reminders for today or tomorrow.');
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Reminders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (todayReminders.isNotEmpty) ...[
                  const Text(
                    'Today',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (var reminder in todayReminders)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reminder['title'] ?? 'Untitled'),
                      subtitle: Text(reminder['description'] ?? ''),
                      trailing: Text(
                        DateFormat('h:mm a').format(reminder['parsedTime']),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      leading: const Icon(Icons.notifications),
                    ),
                  const SizedBox(height: 16),
                ],

                if (tomorrowReminders.isNotEmpty) ...[
                  const Text(
                    'Tomorrow',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (var reminder in tomorrowReminders)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reminder['title'] ?? 'Untitled'),
                      subtitle: Text(reminder['description'] ?? ''),
                      trailing: Text(
                        DateFormat('h:mm a').format(reminder['parsedTime']),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      leading: const Icon(Icons.notifications),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Caregiver'),
            accountEmail: Text(user?.email ?? 'caregiver@example.com'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, color: Colors.blue),
              backgroundColor: Colors.white,
            ),
            decoration: BoxDecoration(color: Colors.blue[400]),
          ),
          ListTile(
            title: const Text('Dashboard'),
            onTap:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainDashboard(),
                  ),
                ),
          ),
          ListTile(
            title: const Text('Behavior Tracking'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BehaviorTrackingHomePage(),
                  ),
                ),
          ),
          ListTile(
            title: const Text('AI Self-Care Diary'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AISelfCareDiaryPage(),
                  ),
                ),
          ),
          ListTile(
            title: const Text('Mood Tracking'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodTrackingPage(),
                  ),
                ),
          ),
          ListTile(
            title: const Text('Manage Tasks'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlannerPage()),
                ),
          ),
          ListTile(
            title: const Text('Image Communication'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageUploadPage()),
                ),
          ),
          ListTile(
            title: const Text('Reminders'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderPage()),
                ),
          ),
          ListTile(
            title: const Text('Reports & Insights'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsInsightsPage(),
                  ),
                ),
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
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
    );
  }

  Widget _buildTaskStatusCard() {
    return FutureBuilder<double>(
      future: _getTaskCompletionPercentage(),
      builder: (context, snapshot) {
        final percentage = snapshot.data ?? 0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Completion Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 10,
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}% completed',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickCard(
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap:
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2), // Lighten the background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36), // Keep original icon color
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: color, // Match the icon color
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
