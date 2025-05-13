import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BehaviorChartPage extends StatefulWidget {
  final String userId;

  const BehaviorChartPage({required this.userId, super.key});

  @override
  State<BehaviorChartPage> createState() => _BehaviorChartPageState();
}

class _BehaviorChartPageState extends State<BehaviorChartPage> {
  Map<String, int> behaviorCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBehaviorData();
  }

  Future<void> _fetchBehaviorData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('behavior_logs')
              .get();

      Map<String, int> counts = {};

      for (var doc in snapshot.docs) {
        List<dynamic> behaviors = doc['behaviors'];

        // Filter out optional or unwanted behaviors here
        for (String behavior in behaviors) {
          // Example of filtering: Exclude 'optional' behaviors (adjust as needed)
          if (behavior != "optional") {
            counts[behavior] = (counts[behavior] ?? 0) + 1;
          }
        }
      }

      setState(() {
        behaviorCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Color> barColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    final behaviors = behaviorCounts.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Behavior Chart")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : behaviorCounts.isEmpty
              ? const Center(child: Text('No behavior data available.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Child's Recorded Behaviors",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This chart shows how frequently each behavior was logged.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                return BarTooltipItem(
                                  '${behaviors[group.x.toInt()].key}\n${rod.toY.toInt()} times',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                                reservedSize:
                                    32, // Increased space for left titles
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize:
                                    100, // Even more space for bottom titles
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= behaviors.length) {
                                    return const SizedBox.shrink();
                                  }

                                  // Truncate long titles if necessary
                                  String title = behaviors[index].key;
                                  if (title.length > 10) {
                                    title = '${title.substring(0, 10)}...';
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Transform.rotate(
                                      angle:
                                          -0.7, // Rotate titles to prevent overlap
                                      child: Text(
                                        title,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barGroups:
                              behaviors.asMap().entries.map((entry) {
                                final index = entry.key;
                                final count = entry.value.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: count.toDouble(),
                                      color:
                                          barColors[index % barColors.length],
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
