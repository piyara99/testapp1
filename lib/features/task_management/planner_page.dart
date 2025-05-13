// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'daily';
  String? userId;
  String? childId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    childId = "childProfile"; // Replace with your actual logic if dynamic
  }

  String get formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _saveCurrentDayAsRoutine() async {
    if (userId == null || childId == null) return;

    TextEditingController titleController = TextEditingController();

    // Ask user for routine title
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Routine Title"),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Enter a name for this routine",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Save"),
              ),
            ],
          ),
    );

    final title = titleController.text.trim();
    if (title.isEmpty) return;

    try {
      final tasksSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('child')
              .doc(childId)
              .collection('tasks')
              .doc(formattedDate)
              .collection('taskList')
              .get();

      final tasks =
          tasksSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'title': data['title'] ?? '',
              'description': data['description'] ?? '',
              'time': data['time'] ?? '',
              'imageUrl': data['imageUrl'] ?? '',
              'status': data['status'] ?? 'pending', // Optional default
            };
          }).toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc(childId)
          .collection('routines')
          .add({
            'title': title,
            'tasks': tasks,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Routine saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save routine")));
    }
  }

  Future<void> _applyRoutineToSelectedDay() async {
    if (userId == null || childId == null) return;

    try {
      // Fetch all routines
      var routinesSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('child')
              .doc(childId)
              .collection('routines')
              .get();

      if (routinesSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No saved routines found")),
        );
        return;
      }

      String? selectedRoutineId;
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select a Routine"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children:
                      routinesSnapshot.docs.map((doc) {
                        final data = doc.data();
                        final title = data['title']?.toString() ?? 'Unnamed';

                        return ListTile(
                          title: Text(title),
                          onTap: () {
                            selectedRoutineId = doc.id;
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                ),
              ),
            ),
          );
        },
      );

      if (selectedRoutineId == null) return;

      // Get selected routine
      var routineDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('child')
              .doc(childId)
              .collection('routines')
              .doc(selectedRoutineId)
              .get();

      final routineData = routineDoc.data();

      if (routineData == null || !routineData.containsKey('tasks')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Routine data is missing or invalid")),
        );
        return;
      }

      final tasks = List<Map<String, dynamic>>.from(routineData['tasks']);

      final taskListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc(childId)
          .collection('tasks')
          .doc(formattedDate)
          .collection('taskList');

      // Clear existing tasks for that day
      final existingTasks = await taskListRef.get();
      for (var doc in existingTasks.docs) {
        await doc.reference.delete();
      }

      // Add tasks from the routine
      for (var task in tasks) {
        await taskListRef.add(task);
      }

      setState(() {}); // Refresh UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Routine applied to selected day")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to apply routine")));
    }
  }

  // This method will open the Add Task page
  void _navigateToAddTaskPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planner"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Toggle daily/weekly
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [_viewMode == 'daily', _viewMode == 'weekly'],
              onPressed: (index) {
                setState(() {
                  _viewMode = index == 0 ? 'daily' : 'weekly';
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Daily'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Weekly'),
                ),
              ],
            ),
          ),

          if (_viewMode == 'daily') _buildDateSelector(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _saveCurrentDayAsRoutine,
                child: const Text("Save as Routine"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _applyRoutineToSelectedDay,
                child: const Text("Apply Routine"),
              ),
            ],
          ),

          Expanded(
            child:
                _viewMode == 'daily'
                    ? _buildDailyTasks()
                    : const Center(child: Text("Weekly planner coming soon")),
          ),
        ],
      ),
      // Floating action button to add a new task
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskPage,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(DateFormat('E').format(date)),
                  Text(date.day.toString()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyTasks() {
    if (userId == null || childId == null) {
      return const Center(child: Text("User not authenticated"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('child')
              .doc(childId)
              .collection('tasks')
              .doc(formattedDate)
              .collection('taskList')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!.docs;

        if (tasks.isEmpty) {
          return const Center(child: Text("No tasks for this day"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index].data() as Map<String, dynamic>;
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (task['imageUrl'] != null)
                    Image.network(task['imageUrl'], height: 50),
                  const SizedBox(height: 8),
                  Text(
                    task['title'] ?? 'Untitled',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  if (task['time'] != null)
                    Text(
                      task['time'],
                      style: const TextStyle(color: Colors.black54),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  TimeOfDay _time = TimeOfDay.now();

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final childId = "childProfile"; // Replace with your actual child ID logic
    final taskListRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('child')
        .doc(childId)
        .collection('tasks')
        .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .collection('taskList');

    await taskListRef.add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'time': _time.format(context),
      'imageUrl': _imageUrl,
      'status': 'Pending', // Default status
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            // Add your image picker here
            // For now, we'll just allow manual entry of the image URL
            TextField(
              decoration: const InputDecoration(labelText: 'Image URL'),
              onChanged: (value) => _imageUrl = value,
            ),
            ListTile(
              title: Text('Time: ${_time.format(context)}'),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (pickedTime != null) {
                  setState(() {
                    _time = pickedTime;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
