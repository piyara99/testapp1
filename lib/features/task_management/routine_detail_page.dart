// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoutineDetailPage extends StatefulWidget {
  final String routineId;
  final String routineName;

  const RoutineDetailPage({
    super.key,
    required this.routineId,
    required this.routineName,
  });

  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  late final CollectionReference routineTasksRef;

  @override
  void initState() {
    super.initState();
    routineTasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('child')
        .doc('childProfile')
        .collection('routines')
        .doc(widget.routineId)
        .collection('tasks');
  }

  Future<void> _addOrEditTask({DocumentSnapshot? doc}) async {
    final nameController = TextEditingController(text: doc?['taskName'] ?? '');
    final timeController = TextEditingController(text: doc?['taskTime'] ?? '');
    final imageController = TextEditingController(text: doc?['imageUrl'] ?? '');

    final isEdit = doc != null;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEdit ? 'Edit Task' : 'Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Task Time'),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'taskName': nameController.text.trim(),
                    'taskTime': timeController.text.trim(),
                    'imageUrl': imageController.text.trim(),
                    'status': 'not done',
                  };

                  if (isEdit) {
                    await routineTasksRef.doc(doc.id).update(data);
                  } else {
                    await routineTasksRef.add(data);
                  }

                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Save' : 'Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteTask(String taskId) async {
    await routineTasksRef.doc(taskId).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routineName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditTask(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: routineTasksRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs;
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks in this routine'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final doc = tasks[index];
              final task = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading:
                    task['imageUrl'] != null && task['imageUrl'] != ''
                        ? Image.network(
                          task['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                        : const Icon(Icons.image),
                title: Text(task['taskName'] ?? 'Unnamed Task'),
                subtitle: Text(task['taskTime'] ?? 'No time'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _addOrEditTask(doc: doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTask(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
