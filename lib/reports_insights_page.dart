import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsInsightsPage extends StatefulWidget {
  const ReportsInsightsPage({super.key});

  @override
  ReportsInsightsPageState createState() => ReportsInsightsPageState();
}

class ReportsInsightsPageState extends State<ReportsInsightsPage> {
  String selectedTab = "Daily"; // Default tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // App background color
      appBar: AppBar(
        title: const Text("Reports & Insights"),
        backgroundColor: const Color(0xFFA8DADC), // App theme color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: Column(
        children: [
          // Tab Selection (Daily, Weekly, Monthly)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ["Daily", "Weekly", "Monthly"].map((tab) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              selectedTab == tab
                                  ? const Color(0xFFA8DADC)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA8DADC)),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color:
                                selectedTab == tab
                                    ? Colors.white
                                    : const Color(0xFF4A4A4A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Display Data based on Selected Tab
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildChart(), // Chart for insights
                    const SizedBox(height: 30),
                    _buildSummaryCard(
                      "Child's Well-being",
                      "Mood Stability: 80%",
                      Icons.child_care,
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryCard(
                      "Caretaker's Stress Level",
                      "Average: Moderate",
                      Icons.favorite,
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryCard(
                      "Sleep Patterns",
                      "Good Sleep: 75%",
                      Icons.bedtime,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build a simple line chart
  Widget _buildChart() {
    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 3),
                  const FlSpot(1, 3.5),
                  const FlSpot(2, 2.5),
                  const FlSpot(3, 4),
                  const FlSpot(4, 3.2),
                  const FlSpot(5, 4.5),
                ],
                isCurved: true,
                color: const Color(0xFFA8DADC), // App theme color
                barWidth: 4,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build summary cards
  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFA8DADC), // Theme color
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      ),
    );
  }
}
