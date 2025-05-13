import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:testapp/features/behavior_tracking/behavior_tracking_home_page.dart';

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

  final List<String> triggerCategories = [
    'Emotional',
    'Environmental',
    'Social',
    'Physiological',
    'Situational',
  ];

  String selectedCategory = 'All';

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
                _buildTriggersList(), // Replace Symptoms with Triggers
                _buildBehaviorAverageList(),
                _buildTrendChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggersList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Category:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedCategory,
                items:
                    ['All', ...triggerCategories]
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ElevatedButton(
            onPressed: _showAddTriggerDialog,
            child: const Text('Add Trigger'),
          ),
        ),
        // Use Column with a scrollable child only if needed
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('triggers')
                    .orderBy('date', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs =
                  snapshot.data!.docs.where((doc) {
                    if (selectedCategory == 'All') return true;
                    return doc['category'] == selectedCategory;
                  }).toList();

              if (docs.isEmpty) {
                return const Center(child: Text('No triggers found.'));
              }

              // Count frequency per trigger
              final Map<String, int> triggerFrequency = {};
              for (var doc in docs) {
                final name = doc['name'];
                triggerFrequency[name] = (triggerFrequency[name] ?? 0) + 1;
              }

              return ListView.builder(
                shrinkWrap: true, // Ensures ListView only takes necessary space
                itemCount: docs.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final trigger = docs[index];
                  final triggerId = trigger.id;
                  final triggerName = trigger['name'] ?? 'Unnamed Trigger';
                  final triggerDescription = trigger['description'] ?? '';
                  final category = trigger['category'] ?? 'Uncategorized';
                  final count = triggerFrequency[triggerName] ?? 1;

                  Color frequencyColor = Colors.green;
                  if (count >= 5) {
                    frequencyColor = Colors.red;
                  } else if (count >= 3) {
                    frequencyColor = Colors.orange;
                  } else if (count >= 2) {
                    frequencyColor = Colors.amber;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.warning, color: frequencyColor),
                      title: Text(triggerName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(triggerDescription),
                          const SizedBox(height: 4),
                          Text("Category: $category"),
                        ],
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'x$count',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: frequencyColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                iconSize:
                                    20, // Make it smaller to reduce height
                                padding:
                                    EdgeInsets.zero, // Remove default padding
                                constraints:
                                    BoxConstraints(), // Remove default size constraints
                                onPressed: () {
                                  _showEditTriggerDialog(
                                    triggerId,
                                    triggerName,
                                    triggerDescription,
                                    category,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  _deleteTrigger(triggerId);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddTriggerDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'Emotional'; // Default category

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Trigger'),
          content: SingleChildScrollView(
            // <-- Add this line
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Trigger Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  items:
                      triggerCategories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTrigger(
                  nameController.text,
                  descriptionController.text,
                  selectedCategory,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add Trigger'),
            ),
          ],
        );
      },
    );
  }

  void _addTrigger(String name, String description, String category) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('triggers')
        .add({
          'name': name,
          'description': description,
          'category': category,
          'date': Timestamp.now(),
        });
  }

  void _showEditTriggerDialog(
    String triggerId,
    String currentName,
    String currentDescription,
    String currentCategory,
  ) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    TextEditingController descriptionController = TextEditingController(
      text: currentDescription,
    );
    String selectedEditCategory = currentCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Trigger'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Trigger Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButton<String>(
                value: selectedEditCategory,
                items:
                    triggerCategories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEditCategory = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateTrigger(
                  triggerId,
                  nameController.text,
                  descriptionController.text,
                  selectedEditCategory,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateTrigger(
    String triggerId,
    String name,
    String description,
    String category,
  ) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('triggers')
        .doc(triggerId)
        .update({
          'name': name,
          'description': description,
          'category': category,
          'date': Timestamp.now(),
        });
  }

  void _deleteTrigger(String triggerId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('triggers')
        .doc(triggerId)
        .delete();
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ToggleButtons(
        isSelected: [selectedIndex == 0, selectedIndex == 1],
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
        children: const [Text('Triggers'), Text('Average')],
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
                  // ignore: deprecated_member_use
                  backgroundColor: severityColor.withOpacity(0.2),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
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
