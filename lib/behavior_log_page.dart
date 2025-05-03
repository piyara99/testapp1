import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:testapp/behavior_tracking_home_page.dart';

class BehaviorLogPage extends StatefulWidget {
  const BehaviorLogPage({super.key});

  @override
  State<BehaviorLogPage> createState() => _BehaviorLogPageState();
}

class _BehaviorLogPageState extends State<BehaviorLogPage> {
  int selectedIndex = 1; // 1 = Average tab by default
  String selectedDuration = 'Last 7 days';

  final user = FirebaseAuth.instance.currentUser;

  final List<String> durations = [
    'Last 7 days',
    'Last 14 days',
    'Last 30 days',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BehaviorTrackingHomePage(),
              ),
            );
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.emoji_emotions)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: selectedDuration,
              underline: const SizedBox(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              items:
                  durations
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDuration = value!;
                });
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          _buildToggleButtons(),
          const SizedBox(height: 10),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                _buildSymptomsPlaceholder(), // You can create a placeholder widget
                _buildBehaviorAverageList(),
                _buildTrendChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsPlaceholder() {
    return Center(
      child: Text(
        'Symptoms data coming soon!',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ToggleButtons(
        isSelected: [
          selectedIndex == 0,
          selectedIndex == 1,
          selectedIndex == 2,
        ],
        onPressed: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: Colors.deepPurple,
        color: Colors.deepPurple,
        constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
        children: const [Text('Symptoms'), Text('Average'), Text('Trend')],
      ),
    );
  }

  Widget _buildBehaviorAverageList() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('behavior_logs')
              .orderBy('date', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No behavior logs found.'));
        }

        final Map<String, int> behaviorCount = {};
        for (var doc in docs) {
          final behaviors = List<String>.from(doc['behaviors'] ?? []);
          for (var behavior in behaviors) {
            behaviorCount[behavior] = (behaviorCount[behavior] ?? 0) + 1;
          }
        }

        final sortedBehavior =
            behaviorCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        return ListView.builder(
          itemCount: sortedBehavior.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final behavior = sortedBehavior[index];

            Color severityColor = Colors.green;
            String severityText = 'Mild';

            if (behavior.value >= 5) {
              severityColor = Colors.red;
              severityText = 'Major';
            } else if (behavior.value >= 3) {
              severityColor = Colors.orange;
              severityText = 'Substantial';
            } else if (behavior.value >= 1) {
              severityColor = const Color(0xFFFFC107);
              severityText = 'Moderate';
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.deepPurple,
                ),
                title: Text(behavior.key),
                subtitle: LinearProgressIndicator(
                  value: (behavior.value / 10).clamp(0.0, 1.0),
                  valueColor: AlwaysStoppedAnimation<Color>(severityColor),
                  backgroundColor: severityColor.withOpacity(0.2),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    border: Border.all(color: severityColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severityText,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 1.5),
                FlSpot(2, 1.4),
                FlSpot(3, 2),
                FlSpot(4, 1.8),
                FlSpot(5, 2.2),
              ],
              isCurved: true,
              color: Colors.deepPurple,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
