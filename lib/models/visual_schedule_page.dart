import 'package:flutter/material.dart';

class VisualSchedulePage extends StatefulWidget {
  const VisualSchedulePage({super.key});

  @override
  State<VisualSchedulePage> createState() => _VisualSchedulePageState();
}

class _VisualSchedulePageState extends State<VisualSchedulePage> {
  // Example routine steps
  final List<Map<String, dynamic>> _routineSteps = [
    {'task': 'Wake up', 'done': false},
    {'task': 'Brush Teeth', 'done': false},
    {'task': 'Get Dressed', 'done': false},
    {'task': 'Eat Breakfast', 'done': false},
    {'task': 'Pack Bag', 'done': false},
    {'task': 'Go to School', 'done': false},
  ];

  void _toggleTask(int index) {
    setState(() {
      _routineSteps[index]['done'] = !_routineSteps[index]['done'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E7F0), // soft lavender background
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'My Morning Routine',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap to check off completed tasks:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _routineSteps.length,
                itemBuilder: (context, index) {
                  final task = _routineSteps[index];
                  return GestureDetector(
                    onTap: () => _toggleTask(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: task['done'] ? Colors.green[100] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              task['done']
                                  ? Colors.green
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          task['done']
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task['done'] ? Colors.green : Colors.grey,
                          size: 30,
                        ),
                        title: Text(
                          task['task'],
                          style: TextStyle(
                            fontSize: 18,
                            decoration:
                                task['done']
                                    ? TextDecoration.lineThrough
                                    : null,
                            color: task['done'] ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
