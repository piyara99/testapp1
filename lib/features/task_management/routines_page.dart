// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'routine_detail_page.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinesPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _routineNameController = TextEditingController();

  CollectionReference<Map<String, dynamic>> get _routineCollection =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc('childProfile')
          .collection('routines');

  Future<void> _createRoutine() async {
    if (_routineNameController.text.trim().isEmpty) return;

    await _routineCollection.add({
      'routineName': _routineNameController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    _routineNameController.clear();
    Navigator.pop(context);
  }

  Future<void> _addTaskToRoutine(String routineId) async {
    final TextEditingController name = TextEditingController();
    final TextEditingController time = TextEditingController();
    final TextEditingController imageUrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Task to Routine'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                TextField(
                  controller: time,
                  decoration: const InputDecoration(labelText: 'Task Time'),
                ),
                TextField(
                  controller: imageUrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (name.text.isEmpty ||
                      time.text.isEmpty ||
                      imageUrl.text.isEmpty) {
                    return;
                  }

                  await _routineCollection
                      .doc(routineId)
                      .collection('tasks')
                      .add({
                        'taskName': name.text.trim(),
                        'taskTime': time.text.trim(),
                        'imageUrl': imageUrl.text.trim(),
                        'status': 'not done',
                      });

                  Navigator.pop(context);
                },
                child: const Text('Add Task'),
              ),
            ],
          ),
    );
  }

  Future<void> _applyRoutine(String routineId) async {
    final routineTasksRef = _routineCollection
        .doc(routineId)
        .collection('tasks');
    final mainTasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('child')
        .doc('childProfile')
        .collection('tasks');

    final tasksSnapshot = await routineTasksRef.get();
    for (var doc in tasksSnapshot.docs) {
      await mainTasksRef.add({
        ...doc.data(),
        'createdAt': FieldValue.serverTimestamp(),
        'routineId': routineId, // optional for tracking
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Routine applied')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.loop, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'Routines',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('New Routine'),
                      content: TextField(
                        controller: _routineNameController,
                        decoration: const InputDecoration(
                          labelText: 'Routine Name',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _createRoutine,
                          child: const Text('Create'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            _routineCollection
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final routines = snapshot.data!.docs;

          if (routines.isEmpty) {
            return const Center(child: Text('No routines found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final doc = routines[index];
              final routineId = doc.id;
              final name = doc['routineName'] ?? 'Unnamed Routine';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: const Icon(Icons.loop, color: Colors.deepPurple),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_task),
                        tooltip: 'Add Task',
                        onPressed: () => _addTaskToRoutine(routineId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.playlist_add_check),
                        tooltip: 'Apply Routine',
                        onPressed: () => _applyRoutine(routineId),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RoutineDetailPage(
                              routineId: routineId,
                              routineName: name,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
