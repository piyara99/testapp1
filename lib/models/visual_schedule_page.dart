import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:testapp/features/child_profile/child_theme_provider.dart';

class VisualSchedulePage extends StatefulWidget {
  const VisualSchedulePage({super.key});

  @override
  State<VisualSchedulePage> createState() => _VisualSchedulePageState();
}

class _VisualSchedulePageState extends State<VisualSchedulePage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final todayFormatted = DateTime.now().toIso8601String().substring(0, 10);

  late final CollectionReference taskCollection;

  bool _isThemeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    taskCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('child')
        .doc('childProfile')
        .collection('tasks')
        .doc(todayFormatted)
        .collection('taskList');
  }

  Future<void> _loadTheme() async {
    await Provider.of<ChildThemeProvider>(
      context,
      listen: false,
    ).fetchChildThemeColorFromFirestore();
    setState(() {
      _isThemeLoaded = true;
    });
  }

  Future<void> markTaskDone(String taskId) async {
    await taskCollection.doc(taskId).update({'status': 'done'});
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ChildThemeProvider>(context).childThemeColor;

    if (!_isThemeLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4E7F0), // soft lavender
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text(
          'My Visual Schedule',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: taskCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No tasks for today."));
            }

            final tasks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final doc = tasks[index];
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] ?? 'No Title';
                final imageUrl = data['imageUrl'] ?? '';
                final isDone = data['status'] == 'done';

                return GestureDetector(
                  onTap:
                      isDone
                          ? null
                          : () async {
                            await markTaskDone(doc.id);
                          },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green[100] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading:
                          imageUrl.isNotEmpty
                              ? Image.network(imageUrl, width: 50, height: 50)
                              : const Icon(Icons.image_not_supported),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: Icon(
                        isDone ? Icons.check_circle : Icons.circle_outlined,
                        color: isDone ? Colors.green : Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
