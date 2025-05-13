import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsInsightsPage extends StatefulWidget {
  const ReportsInsightsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportsInsightsPageState createState() => _ReportsInsightsPageState();
}

class _ReportsInsightsPageState extends State<ReportsInsightsPage> {
  String selectedTab = 'Daily';
  late Future<List<SortingGameSession>> sortingGameData;
  late Future<List<MemoryMatchSession>> memoryMatchGameData;

  @override
  void initState() {
    super.initState();
    sortingGameData = fetchSortingGameData();
    memoryMatchGameData = fetchMemoryMatchData();
  }

  DateTime _getCutoffDate(DateTime now) {
    switch (selectedTab) {
      case 'Weekly':
        return now.subtract(Duration(days: 7));
      case 'Monthly':
        return now.subtract(Duration(days: 30));
      case 'Daily':
      default:
        return now.subtract(Duration(days: 1));
    }
  }

  Future<List<SortingGameSession>> fetchSortingGameData() async {
    final now = DateTime.now();
    final cutoff = _getCutoffDate(now);

    final sortingGameRef = FirebaseFirestore.instance
        .collection('users')
        .doc('1CadpOrTVudnVXqMFLPdR8jIoFO2')
        .collection('child')
        .doc('childProfile')
        .collection('gameProgress')
        .doc('sorting_game')
        .collection('sessions');

    final snapshot =
        await sortingGameRef
            .where('timestamp', isGreaterThanOrEqualTo: cutoff)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SortingGameSession(
        duration: (data['durationInSeconds'] as num?)?.toInt() ?? 0,
        level: (data['level'] as num?)?.toInt() ?? 0,
        score: (data['score'] as num?)?.toInt() ?? 0,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<List<MemoryMatchSession>> fetchMemoryMatchData() async {
    // Get the current user ID dynamically from Firebase Authentication
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not authenticated");
    }

    // You can either fetch the child ID dynamically or pass it from another part of your app
    // Replace with your logic to get childId

    final now = DateTime.now();
    final cutoff = _getCutoffDate(now);

    final memoryMatchRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid) // Use dynamic user ID
        .collection('child')
        .doc('childProfile')
        .collection('gameProgress')
        .doc('memory_match_v1')
        .collection('sessions');

    final snapshot =
        await memoryMatchRef
            .where('date', isGreaterThanOrEqualTo: cutoff)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MemoryMatchSession(
        duration: (data['timeTakenSeconds'] as num?)?.toInt() ?? 0,
        score: (data['score'] as num?)?.toInt() ?? 0,
        timestamp: (data['date'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Widget _buildChartFromSessions(List<SortingGameSession> sessions) {
    Map<String, List<SortingGameSession>> grouped = {};
    for (var session in sessions) {
      String dateKey =
          "${session.timestamp.year}-${session.timestamp.month.toString().padLeft(2, '0')}-${session.timestamp.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateKey, () => []).add(session);
    }

    List<FlSpot> spots = [];
    int index = 0;
    final sortedKeys = grouped.keys.toList()..sort();

    for (var dateKey in sortedKeys) {
      final sessionsForDay = grouped[dateKey]!;
      final avgScore =
          sessionsForDay.map((e) => e.score).reduce((a, b) => a + b) /
          sessionsForDay.length;
      spots.add(FlSpot(index.toDouble(), avgScore));
      index++;
    }

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: true),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFFA8DADC),
                barWidth: 4,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryMatchChart(List<MemoryMatchSession> sessions) {
    Map<String, List<MemoryMatchSession>> grouped = {};
    for (var session in sessions) {
      String dateKey =
          "${session.timestamp.year}-${session.timestamp.month.toString().padLeft(2, '0')}-${session.timestamp.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateKey, () => []).add(session);
    }

    List<FlSpot> spots = [];
    int index = 0;
    final sortedKeys = grouped.keys.toList()..sort();

    for (var dateKey in sortedKeys) {
      final sessionsForDay = grouped[dateKey]!;
      final avgScore =
          sessionsForDay.map((e) => e.score).reduce((a, b) => a + b) /
          sessionsForDay.length;
      spots.add(FlSpot(index.toDouble(), avgScore));
      index++;
    }

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: true),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFF457B9D),
                barWidth: 4,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports & Insights',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['Daily', 'Weekly', 'Monthly'].map((tab) {
                    final isSelected = selectedTab == tab;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tab;
                          sortingGameData = fetchSortingGameData();
                          memoryMatchGameData = fetchMemoryMatchData();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFFA8DADC)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA8DADC)),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFFA8DADC),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sorting Game Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<SortingGameSession>>(
              future: sortingGameData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Sorting Game data available'),
                  );
                } else {
                  return _buildChartFromSessions(snapshot.data!);
                }
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Memory Match Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<MemoryMatchSession>>(
              future: memoryMatchGameData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No Memory Match data available'),
                  );
                } else {
                  return _buildMemoryMatchChart(snapshot.data!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class SortingGameSession {
  final int duration;
  final int level;
  final int score;
  final DateTime timestamp;

  SortingGameSession({
    required this.duration,
    required this.level,
    required this.score,
    required this.timestamp,
  });
}

class MemoryMatchSession {
  final int duration;
  final int score;
  final DateTime timestamp;

  MemoryMatchSession({
    required this.duration,
    required this.score,
    required this.timestamp,
  });
}
