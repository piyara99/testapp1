import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';

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

/// Sign-In Page
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

/// Task Management Page
class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  _TaskManagementPageState createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskTimeController = TextEditingController();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = pickedFile;
    });
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'tasks/$userId/${DateTime.now().millisecondsSinceEpoch}',
      );
      final uploadTask = await ref.putFile(File(_image!.path));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addTask() async {
    if (_taskNameController.text.isEmpty || _taskTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task name and time')),
      );
      return;
    }

    final taskName = _taskNameController.text;
    final taskTime = _taskTimeController.text;
    final imageUrl = await _uploadImage();

    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'userId': userId,
        'taskName': taskName,
        'taskTime': taskTime,
        'image': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task added successfully')));
      _taskNameController.clear();
      _taskTimeController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      print('Error adding task: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error adding task')));
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image for Task'),
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
                    FirebaseFirestore.instance
                        .collection('tasks')
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tasks = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        child: ListTile(
                          title: Text(task['taskName']),
                          subtitle: Text(task['taskTime']),
                          leading:
                              task['image'] != null
                                  ? Image.network(task['image'])
                                  : null,
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
