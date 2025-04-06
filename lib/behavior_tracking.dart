import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'behavior_chart_page.dart';

// BehaviorTrackingPage now uses the logged-in user's ID
class BehaviorTrackingPage extends StatefulWidget {
  const BehaviorTrackingPage({super.key});

  @override
  _BehaviorTrackingPageState createState() => _BehaviorTrackingPageState();
}

class _BehaviorTrackingPageState extends State<BehaviorTrackingPage> {
  final List<String> behaviorOptions = [
    'Excessive Worries',
    'Anxiety',
    'Low Energy',
    'Depressed Mood',
    'Hyperactivity',
    'Difficulty Sleeping',
  ];

  List<String> selectedBehaviors = [];
  final TextEditingController specialNotesController = TextEditingController();
  final TextEditingController customBehaviorController =
      TextEditingController();

  // Get the current user's ID from Firebase Authentication
  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid; // return the user's ID
    }
    return ''; // return empty string if the user is not authenticated
  }

  void _saveBehaviorData() async {
    // Add custom behavior if any
    final customBehavior = customBehaviorController.text.trim();
    if (customBehavior.isNotEmpty &&
        !selectedBehaviors.contains(customBehavior)) {
      selectedBehaviors.add(customBehavior);
    }

    if (selectedBehaviors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select or add at least one behavior.')),
      );
      return;
    }

    try {
      // Save data to Firestore under the user's ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('behavior_logs')
          .add({
            'behaviors': selectedBehaviors,
            'notes': specialNotesController.text.trim(),
            'date': Timestamp.now(), // for chart use
          });

      // Clear form after save
      setState(() {
        selectedBehaviors.clear();
        customBehaviorController.clear();
        specialNotesController.clear();
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Behavior data saved successfully!')),
      );

      // Optionally, navigate back or stay on the page
      // Navigator.pop(context); // Uncomment if you want to navigate back after saving
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving behavior: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Behavior Tracking'),
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add this section for the chart navigation button
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  icon: Icon(Icons.bar_chart, color: Colors.blue[400]),
                  label: Text(
                    'View Chart',
                    style: TextStyle(color: Colors.blue[400]),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BehaviorChartPage(userId: userId),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),

              Text(
                'Select Observed Behaviors:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400],
                ),
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children:
                    behaviorOptions.map((behavior) {
                      return Card(
                        color: Colors.blue[50],
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: CheckboxListTile(
                          title: Text(
                            behavior,
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                          value: selectedBehaviors.contains(behavior),
                          activeColor: Colors.blue[400],
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedBehaviors.add(behavior);
                              } else {
                                selectedBehaviors.remove(behavior);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: 10),
              Text(
                'Add Custom Behavior:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400],
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: customBehaviorController,
                decoration: InputDecoration(
                  hintText: 'Enter custom behavior...',
                  filled: true,
                  fillColor: Colors.blue[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Special Notes:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400],
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: specialNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter any additional notes...',
                  filled: true,
                  fillColor: Colors.blue[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveBehaviorData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Save Behavior Data',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
