// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      debugShowCheckedModeBanner: false,
      home:
          FirebaseAuth.instance.currentUser == null
              ? const SignInPage()
              : const TaskManagementPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskManagementPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signIn, child: const Text('Sign In')),
          ],
        ),
      ),
    );
  }
}

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  _TaskManagementPageState createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskTimeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _taskCollection =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc('childProfile')
          .collection('tasks');

  Future<void> _addTask() async {
    if (_taskNameController.text.isEmpty || _taskTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task name and time')),
      );
      return;
    }

    final taskName = _taskNameController.text;
    final taskTime = _taskTimeController.text;
    final imageUrl = _imageUrlController.text.trim();

    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid image URL')),
      );
      return;
    }

    try {
      final tasksRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc('childProfile')
          .collection('tasks');

      await tasksRef.add({
        'taskName': taskName,
        'taskTime': taskTime,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'not done', // ✅ Add this line
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task added successfully')));

      _taskNameController.clear();
      _taskTimeController.clear();
      _imageUrlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error adding task')));
    }
  }

  Future<void> _editTask(
    String taskId,
    String name,
    String time,
    String imageUrl,
  ) async {
    _taskNameController.text = name;
    _taskTimeController.text = time;
    _imageUrlController.text = imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _taskTimeController,
                decoration: const InputDecoration(labelText: 'Task Time'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_taskNameController.text.isEmpty ||
                    _taskTimeController.text.isEmpty ||
                    _imageUrlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  await _taskCollection.doc(taskId).update({
                    'taskName': _taskNameController.text.trim(),
                    'taskTime': _taskTimeController.text.trim(),
                    'imageUrl': _imageUrlController.text.trim(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error updating task')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
        backgroundColor: Colors.blue[400],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Enter Image URL'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskTimeController,
              decoration: const InputDecoration(labelText: 'Task Time'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Add New Task'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _taskCollection
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data!.docs;
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks found'));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final data = task.data() as Map<String, dynamic>;
                      final taskName = data['taskName'] ?? 'Unnamed Task';
                      final taskTime = data['taskTime'] ?? 'No Time';
                      final imageUrl = data['imageUrl'] ?? '';

                      return Card(
                        child: ListTile(
                          leading:
                              imageUrl.isNotEmpty
                                  ? Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                  : const Icon(Icons.image),
                          title: Text(taskName),
                          subtitle: Text(taskTime),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editTask(task.id, taskName, taskTime, imageUrl);
                            },
                          ),
                        ),
                      );
                    },
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
