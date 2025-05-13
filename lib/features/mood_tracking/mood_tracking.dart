// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:testapp/features/auth/signin.dart' as signin;
import 'package:fl_chart/fl_chart.dart';
import 'package:testapp/features/dashboard/caregiver_dashboard.dart';

class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});

  @override
  _MoodTrackingPageState createState() => _MoodTrackingPageState();
}

class _MoodTrackingPageState extends State<MoodTrackingPage> {
  double _moodScore = 5.0;
  double _wellBeingScore = 5.0;
  String _moodNote = '';
  String _selectedEmoji = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _tasksFuture = Future.value(); // Default dummy future

  final List<String> _selectedTasks = [];
  List<Map<String, dynamic>> _tasks = []; // Store fetched tasks

  // Fetch tasks for a specific date
  Future<void> _fetchTasks() async {
    String? userId = getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not signed in. Please sign in.')),
      );
      return;
    }

    // Set the task date as today's date in 'YYYY-MM-DD' format
    String taskDate =
        DateTime.now().toIso8601String().split('T')[0]; // '2025-05-05'

    // Log for debugging

    try {
      // Access the Firestore collection using the path you provided
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId) // User ID
              .collection('child')
              .doc('childProfile') // Fixed child profile path
              .collection('tasks')
              .doc(taskDate) // Tasks for today's date
              .collection('taskList') // Collection of tasks for this date
              .get();

      // Log the number of tasks fetched

      if (snapshot.docs.isEmpty) {
      } else {
        // Debugging: Log task data
        // ignore: unused_local_variable
        for (var doc in snapshot.docs) {}
      }

      setState(() {
        // Map the fetched tasks to a list of task details (including title, imageUrl, description, etc.)
        _tasks =
            snapshot.docs.map((doc) {
              return {
                'title': doc['title'],
                'imageUrl': doc['imageUrl'], // Add other fields as necessary
                'description': doc['description'],
                'time': doc['time'],
                'status': doc['status'],
              };
            }).toList();
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  // Call _fetchTasks when the page loads
  @override
  void initState() {
    super.initState();
    _tasksFuture = _fetchTasks();
  }

  final List<Map<String, String>> _emojiOptions = [
    {"emoji": "😊", "label": "Happy"},
    {"emoji": "😐", "label": "Neutral"},
    {"emoji": "😢", "label": "Sad"},
    {"emoji": "😡", "label": "Angry"},
    {"emoji": "😴", "label": "Tired"},
  ];

  Map<String, String> selfCareTips = {
    "Happy": "Keep doing what makes you smile!",
    "Neutral": "Try some music or a short walk to lift your mood.",
    "Sad": "Take a break and talk to someone you trust.",
    "Angry": "Breathe deeply or write down your feelings.",
    "Tired": "Make time to rest and recharge.",
  };

  String? getUserId() {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  void _resetForm() {
    setState(() {
      _moodScore = 5.0;
      _wellBeingScore = 5.0;
      _moodNote = '';
      _selectedEmoji = '';
      _selectedTasks.clear();
    });
  }

  Future<void> _saveMoodData() async {
    String? userId = getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not signed in. Please sign in.')),
      );
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_data')
        .add({
          'mood_score': _moodScore,
          'well_being_score': _wellBeingScore,
          'mood_emoji': _selectedEmoji,
          'note': _moodNote.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'tasks': _selectedTasks,
        });

    String moodLabel =
        _emojiOptions.firstWhere(
          (e) => e['emoji'] == _selectedEmoji,
          orElse: () => {"label": "Neutral"},
        )["label"]!;

    String suggestion =
        selfCareTips[moodLabel] ?? "Take care of yourself today.";

    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(SnackBar(content: Text('Mood Recorded! $suggestion')));
    _resetForm();

    setState(() {
      _moodScore = 5.0;
      _wellBeingScore = 5.0;
      _moodNote = '';
      _selectedEmoji = '';
      _selectedTasks.clear();
    });
  }

  Future<List<Map<String, dynamic>>> _getMoodHistory({int days = 7}) async {
    String? userId = getUserId();
    if (userId == null) {
      return [];
    }

    DateTime now = DateTime.now();
    DateTime pastDate = now.subtract(Duration(days: days));

    QuerySnapshot snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('mood_data')
            .where('timestamp', isGreaterThanOrEqualTo: pastDate)
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map(
          (doc) => {
            'mood_score': doc['mood_score'],
            'well_being_score': doc['well_being_score'],
            'mood_emoji': doc['mood_emoji'],
            'timestamp': doc['timestamp'],
            'tasks': List<String>.from(doc['tasks']),
          },
        )
        .toList();
  }

  Map<String, int> _generateInsights(List<Map<String, dynamic>> moodHistory) {
    Map<String, int> moodCounts = {};
    for (var entry in moodHistory) {
      String mood = entry['mood_emoji'];
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    return moodCounts;
  }

  Widget _buildMoodHistory(List<Map<String, dynamic>> moodHistory) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: moodHistory.length,
      itemBuilder: (context, index) {
        final entry = moodHistory[index];
        return ListTile(
          title: Text("Mood: ${entry['mood_emoji']} - ${entry['mood_score']}"),
          subtitle: Text(
            "Well-being: ${entry['well_being_score']} - Tasks: ${entry['tasks'].join(', ')}",
          ),
          trailing: Text((entry['timestamp'] as Timestamp).toDate().toString()),
        );
      },
    );
  }

  Widget _buildTaskSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select tasks associated with your mood:',
          style: TextStyle(fontSize: 18),
        ),
        FutureBuilder<void>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error loading tasks: ${snapshot.error}');
            } else if (_tasks.isEmpty) {
              return const Text('No tasks available for today.');
            } else {
              return Column(
                children:
                    _tasks.map((task) {
                      return CheckboxListTile(
                        title: Text(task['title'] ?? 'No Title'),
                        value: _selectedTasks.contains(task['title']),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedTasks.add(task['title']);
                            } else {
                              _selectedTasks.remove(task['title']);
                            }
                          });
                        },
                      );
                    }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildMoodPieChart(Map<String, int> moodCounts) {
    if (moodCounts.isEmpty) {
      return const Text('No mood data to show chart.');
    }

    final List<PieChartSectionData> sections =
        moodCounts.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: entry.key,
            color: _getColorForMood(entry.key),
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 30)),
    );
  }

  Color _getColorForMood(String moodEmoji) {
    switch (moodEmoji) {
      case '😊':
        return Colors.green;
      case '😐':
        return Colors.blueGrey;
      case '😢':
        return Colors.blue;
      case '😡':
        return Colors.red;
      case '😴':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildWeeklySummary(List<Map<String, dynamic>> moodHistory) {
    if (moodHistory.isEmpty) {
      return const Text('No weekly data available.');
    }

    double avgMoodScore =
        moodHistory
            .map((e) => e['mood_score'] as double)
            .reduce((a, b) => a + b) /
        moodHistory.length;
    Map<String, int> moodCounts = _generateInsights(moodHistory);
    String mostFrequentMood =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Mood Score: ${avgMoodScore.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          'Most Frequent Mood: $mostFrequentMood',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5FAFF),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CaregiverDashboard()),
          );
        },
      ),
      title: Row(
        children: const [
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.mood, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text(
            'Mood Tracking',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
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
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildEmojiSelector() {
    return Wrap(
      spacing: 10,
      children:
          _emojiOptions.map((option) {
            return ChoiceChip(
              label: Text(
                option['emoji']!,
                style: const TextStyle(fontSize: 24),
              ),
              selected: _selectedEmoji == option['emoji'],
              onSelected: (selected) {
                setState(() {
                  _selectedEmoji = selected ? option['emoji']! : '';
                });
              },
              selectedColor: Colors.deepPurple.shade100,
              backgroundColor: Colors.grey.shade100,
              side: const BorderSide(color: Colors.deepPurple),
              labelStyle: TextStyle(
                fontSize: 24,
                color:
                    _selectedEmoji == option['emoji']
                        ? Colors.deepPurple
                        : Colors.black87,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      maxLines: 4,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Optional note or reflection...',
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) => _moodNote = value,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveMoodData,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: const Text('Submit'),
    );
  }

  Widget _buildWeeklyReport() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getMoodHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No mood history available.');
        } else {
          Map<String, int> insights = _generateInsights(snapshot.data!);
          return Column(
            children: [
              _buildWeeklySummary(snapshot.data!),
              const SizedBox(height: 20),
              _buildMoodPieChart(insights),
              const SizedBox(height: 20),
              _buildMoodHistory(snapshot.data!),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Daily Mood Check-in"),
            const SizedBox(height: 16),
            _buildEmojiSelector(),
            const SizedBox(height: 20),
            _buildSlider(
              "Mood",
              _moodScore,
              (val) => setState(() => _moodScore = val),
            ),
            const SizedBox(height: 20),
            _buildSlider(
              "Well-being",
              _wellBeingScore,
              (val) => setState(() => _wellBeingScore = val),
            ),
            const SizedBox(height: 20),
            _buildNoteInput(),
            const SizedBox(height: 20),
            _buildTaskSelector(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 32),
            _buildHeader("Weekly Mood Report"),
            const SizedBox(height: 16),
            _buildWeeklyReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title:", style: const TextStyle(fontSize: 18)),
        Slider(
          value: value,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
        Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
