import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testapp/signin.dart' as signin;
import 'package:fl_chart/fl_chart.dart';
import 'package:testapp/caregiver_dashboard.dart';

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

  final List<String> _selectedTasks = [];

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
      context,
    ).showSnackBar(SnackBar(content: Text('Mood Recorded! $suggestion')));

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
      children: [
        Text(
          'Select tasks associated with your mood:',
          style: TextStyle(fontSize: 18),
        ),
        CheckboxListTile(
          title: Text('Feeding'),
          value: _selectedTasks.contains('Feeding'),
          onChanged: (bool? selected) {
            setState(() {
              if (selected == true) {
                _selectedTasks.add('Feeding');
              } else {
                _selectedTasks.remove('Feeding');
              }
            });
          },
        ),
        CheckboxListTile(
          title: Text('Medication'),
          value: _selectedTasks.contains('Medication'),
          onChanged: (bool? selected) {
            setState(() {
              if (selected == true) {
                _selectedTasks.add('Medication');
              } else {
                _selectedTasks.remove('Medication');
              }
            });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CaregiverDashboard(),
              ),
            );
          },
        ),
        title: const Text(
          'Mood Tracker',
          style: TextStyle(color: Colors.black),
        ),
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
            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CaregiverDashboard(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Mood Tracking'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodTrackingPage(),
                  ),
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
              const Text(
                "Daily Mood Check-in",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children:
                    _emojiOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option['emoji']!),
                        selected: _selectedEmoji == option['emoji'],
                        onSelected: (selected) {
                          setState(() {
                            _selectedEmoji = selected ? option['emoji']! : '';
                          });
                        },
                        backgroundColor: Colors.white24,
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 24,
                          color:
                              _selectedEmoji == option['emoji']
                                  ? Colors.blue[400]
                                  : Colors.white,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 30),
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
              TextField(
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
              ),
              const SizedBox(height: 30),
              _buildTaskSelector(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMoodData,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[400],
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Submit'),
              ),
              const SizedBox(height: 30),
              const Text(
                "Weekly Mood Report",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getMoodHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No mood history available.');
                  } else {
                    Map<String, int> insights = _generateInsights(
                      snapshot.data!,
                    );
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
              ),
            ],
          ),
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
