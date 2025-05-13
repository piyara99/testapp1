// ignore_for_file: empty_catches, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class TaskPage extends StatelessWidget {
  final String taskId;
  final String taskName;
  final String imageUrl;
  final dynamic taskTime; // Use dynamic to handle different types

  const TaskPage({
    required this.taskId,
    required this.taskName,
    required this.imageUrl,
    required this.taskTime, // Pass the taskTime as dynamic
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Format the task time if it's a Timestamp
    String formattedTime = 'N/A'; // Default value
    try {
      if (taskTime is Timestamp) {
        // If it's a Timestamp, convert it to DateTime and format it
        DateTime dateTime = taskTime.toDate();
        formattedTime = DateFormat('hh:mm a').format(dateTime);
      } else if (taskTime is String) {
        // If it's already a string, just use it
        formattedTime = taskTime;
      }
    } catch (e) {}

    return Scaffold(
      appBar: AppBar(title: Text(taskName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the task image if available, or a placeholder icon
            imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : const Icon(Icons.image),
            const SizedBox(height: 20),

            // Display the task name
            Text(
              taskName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Display the task time
            Text(
              'Task Time: $formattedTime',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success button to mark the task as done
                ElevatedButton(
                  onPressed: () async {
                    var userId = FirebaseAuth.instance.currentUser?.uid;

                    if (userId == null) {
                      return;
                    }

                    // Construct the document reference using the userId
                    var taskRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('child')
                        .doc('childProfile')
                        .collection('tasks')
                        .doc(taskId);

                    // Check if the document exists
                    var docSnapshot = await taskRef.get();
                    if (docSnapshot.exists) {
                      // If the document exists, update its status
                      await taskRef.update({'status': 'done'});
                      // Show confirmation message to the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$taskName marked as completed!'),
                        ),
                      );
                    } else {
                      // Handle the error if the document doesn't exist
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Mark as Complete',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(width: 10),

                // Fail button to mark the task as failed
                ElevatedButton(
                  onPressed: () async {
                    var userId = FirebaseAuth.instance.currentUser?.uid;

                    if (userId == null) {
                      return;
                    }

                    // Construct the document reference using the userId
                    var taskRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('child')
                        .doc('childProfile')
                        .collection('tasks')
                        .doc(taskId);

                    // Check if the document exists
                    var docSnapshot = await taskRef.get();
                    if (docSnapshot.exists) {
                      // If the document exists, update its status
                      await taskRef.update({'status': 'failed'});
                      // Show failure message to the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$taskName marked as failed!')),
                      );
                    } else {
                      // Handle the error if the document doesn't exist
                    }

                    // Close and go back
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Fail',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
