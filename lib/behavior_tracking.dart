import 'package:flutter/material.dart';

// Keeping the _BehaviorTrackingPageState as private for the internal state class
class BehaviorTrackingPage extends StatefulWidget {
  const BehaviorTrackingPage({super.key});

  @override
  _BehaviorTrackingPageState createState() => _BehaviorTrackingPageState();
}

// Private state class for internal use
class _BehaviorTrackingPageState extends State<BehaviorTrackingPage> {
  final List<String> behaviorOptions = [
    'Excessive Worries',
    'Anxiety',
    'Low Energy',
    'Depressed Mood',
    'Hyperactivity',
    'Difficulty Sleeping',
  ];

  // Making selectedBehaviors mutable by using a regular list and not final
  List<String> selectedBehaviors = [];
  final TextEditingController specialNotesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color same as other pages
      appBar: AppBar(
        title: Text('Behavior Tracking'),
        backgroundColor: Colors.blue[400], // Consistent with dashboard
      ),
      body: SingleChildScrollView(
        // Ensures scrollability
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Observed Behaviors:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400], // Consistent color
                ),
              ),
              ListView(
                shrinkWrap:
                    true, // Important for nesting ListView inside Column
                physics:
                    NeverScrollableScrollPhysics(), // Prevent internal scrolling
                children:
                    behaviorOptions.map((behavior) {
                      return Card(
                        color: Colors.blue[50], // Light blue card background
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: CheckboxListTile(
                          title: Text(
                            behavior,
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                          value: selectedBehaviors.contains(behavior),
                          activeColor: Colors.blue[400], // Checkbox color
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
                'Special Notes:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400], // Matching title color
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: specialNotesController,
                decoration: InputDecoration(
                  hintText: 'Enter any additional notes...',
                  filled: true,
                  fillColor: Colors.blue[50], // Light blue background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none, // Remove default border
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submission logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400], // Matching button color
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
