import 'package:flutter/material.dart';

class TaskManagementPage extends StatelessWidget {
  const TaskManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tasks'),
        backgroundColor: Colors.blue[400], // Calm Blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[400],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // You can add your task creation logic here
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[400], // Text color
              ),
              child: Text('Add New Task'),
            ),
            SizedBox(height: 20),
            Text(
              'Current Tasks:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[400],
              ),
            ),
            // List of current tasks
            Expanded(
              child: ListView(
                children: [
                  Card(
                    color: Colors.blue[50],
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Task 1: Brushing Teeth - 10:00 AM',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.blue[50],
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Task 2: Medication - 11:30 AM',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ),
                  ),
                  // Add more tasks here...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
