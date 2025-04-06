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
                    // Mark task as complete
                    await FirebaseFirestore.instance
                        .collection('tasks')
                        .doc(taskId)
                        .update({'status': 'done'});

                    // Show reward popup
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Congratulations!'),
                          content: const Text(
                            'You completed the task! Here is your reward.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(
                                  context,
                                ); // Go back to ChildProfileFirstPage
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Success'),
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
