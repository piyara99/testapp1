import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskPage extends StatelessWidget {
  final String taskId;
  final String taskName;
  final String imageUrl;
  final String taskTime; // Add taskTime parameter

  const TaskPage({
    required this.taskId,
    required this.taskName,
    required this.imageUrl,
    required this.taskTime, // Include taskTime in the constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              'Task Time: $taskTime',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success button to mark the task as done
                ElevatedButton(
                  onPressed: () async {
                    // Get the userId from Firebase Authentication
                    var userId = FirebaseAuth.instance.currentUser?.uid;

                    if (userId == null) {
                      // Handle case where user is not logged in
                      print('No user is logged in');
                      return;
                    }

                    // Construct the document reference using the userId
                    var taskRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId) // Use the userId here
                        .collection('child')
                        .doc('childProfile')
                        .collection('tasks')
                        .doc(taskId); // Ensure taskId is valid

                    // Check if the document exists
                    var docSnapshot = await taskRef.get();
                    if (docSnapshot.exists) {
                      // If the document exists, update its status
                      await taskRef.update({'status': 'done'});
                    } else {
                      // Handle the error if the document doesn't exist
                      print('Document not found');
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
                  onPressed: () {
                    // Mark task as failed
                    FirebaseFirestore.instance
                        .collection('tasks')
                        .doc(taskId)
                        .update({'status': 'failed'});

                    // Close and go back
                    Navigator.pop(context);
                  },
                  child: const Text('Fail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
