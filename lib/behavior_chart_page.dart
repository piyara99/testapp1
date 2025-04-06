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

  @override
  void initState() {
    super.initState();
    _fetchBehaviorData();
  }

  Future<void> _fetchBehaviorData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('behavior_logs')
            .get();

    Map<String, int> counts = {};

    for (var doc in snapshot.docs) {
      List<dynamic> behaviors = doc['behaviors'];
      for (String behavior in behaviors) {
        counts[behavior] = (counts[behavior] ?? 0) + 1;
      }
    }

    setState(() {
      behaviorCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final behaviors = behaviorCounts.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Behavior Chart")),
      body:
          behaviorCounts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= behaviors.length)
                              return const SizedBox.shrink();
                            return SideTitleWidget(
                              space: 6,
                              meta: meta,
                              child: Text(
                                behaviors[index].key,
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                          reservedSize: 36,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                          reservedSize: 30,
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
                          final behavior = entry.value.key;
                          final count = entry.value.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: Colors.blue,
                                width: 18,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          );
                        }).toList(),
                  ),
                ),
              ),
    );
  }
}
