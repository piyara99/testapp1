import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:testapp/features/behavior_tracking/behavior_tracking_home_page.dart';
import 'package:testapp/features/image_communication/image_upload_page.dart';
import 'package:testapp/features/dashboard/main_dashboard.dart';
import 'package:testapp/features/task_management/planner_page.dart';
import 'package:testapp/features/reminders/reminder_page.dart';
import 'package:testapp/features/auth/signin.dart' as signin;
import 'package:testapp/features/mood_tracking/mood_tracking.dart';
import 'package:testapp/features/self_care/selfcarediary.dart';
import 'package:testapp/features/dashboard/settings_page.dart';
import 'package:testapp/features/reports/reports_insights_page.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {}
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<Map<String, dynamic>> _getTaskStats() async {
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

    if (snapshot.docs.isEmpty) {
      return {'total': 0, 'done': 0, 'percentage': 0.0};
    }

    final total = snapshot.docs.length;
    final completed =
        snapshot.docs
            .where(
              (doc) =>
                  (doc['status']?.toString().toLowerCase() ?? '') == 'done',
            )
            .length;

    final percentage = (completed / total) * 100;

    return {'total': total, 'done': completed, 'percentage': percentage};
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
        backgroundColor: Color(0xFF6A4C9C),
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
                ReportsInsightsPage(),
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
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.deepPurple),
            ),
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
                    builder: (context) => ReportsInsightsPage(),
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _getTaskStats(),
      builder: (context, snapshot) {
        final data =
            snapshot.data ?? {'total': 0, 'done': 0, 'percentage': 0.0};

        final total = data['total'];
        final completed = data['done'];
        final percentage = data['percentage'];

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
                  '${percentage.toStringAsFixed(1)}% completed ($completed of $total tasks)',
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
          // ignore: deprecated_member_use
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
