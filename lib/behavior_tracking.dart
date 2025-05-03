import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testapp/caregiver_dashboard.dart';
// Back navigation target

class BehaviorTrackingPage extends StatefulWidget {
  const BehaviorTrackingPage({super.key});

  @override
  State<BehaviorTrackingPage> createState() => _BehaviorTrackingPageState();
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

  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  Future<void> _saveBehaviorData() async {
    final customBehavior = customBehaviorController.text.trim();
    if (customBehavior.isNotEmpty &&
        !selectedBehaviors.contains(customBehavior)) {
      selectedBehaviors.add(customBehavior);
    }

    if (selectedBehaviors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add at least one behavior.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('behavior_logs')
          .add({
            'behaviors': selectedBehaviors,
            'notes': specialNotesController.text.trim(),
            'date': Timestamp.now(),
          });

      setState(() {
        selectedBehaviors.clear();
        customBehaviorController.clear();
        specialNotesController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Behavior data saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving behavior: $e')));
    }
  }

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
                builder: (context) => const CaregiverDashboard(),
              ),
            );
          },
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.emoji_emotions, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'Behavior Tracking',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 10),
          _buildSectionTitle('Select Observed Behaviors:'),
          ...behaviorOptions.map(
            (behavior) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: const Color(0xFFF9F6FF), // Updated background color
              child: CheckboxListTile(
                title: Text(
                  behavior,
                  style: const TextStyle(color: Colors.black87),
                ),
                value: selectedBehaviors.contains(behavior),
                activeColor: Colors.deepPurple,
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
            ),
          ),
          const SizedBox(height: 10),
          _buildSectionTitle('Add Custom Behavior:'),
          _buildTextField(
            controller: customBehaviorController,
            hintText: 'Enter custom behavior...',
          ),
          const SizedBox(height: 10),
          _buildSectionTitle('Special Notes:'),
          _buildTextField(
            controller: specialNotesController,
            hintText: 'Enter any additional notes...',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _saveBehaviorData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Save Behavior Data',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
