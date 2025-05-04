import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class GuidedRoutinePage extends StatefulWidget {
  const GuidedRoutinePage({super.key});

  @override
  State<GuidedRoutinePage> createState() => _GuidedRoutinePageState();
}

class _GuidedRoutinePageState extends State<GuidedRoutinePage> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Map<String, dynamic>> _tasks = [];
  int _currentIndex = 0;
  int _completedTasks = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('child')
              .doc('childProfile')
              .collection('tasks')
              .doc(today)
              .collection('taskList')
              .get();

      final taskList =
          querySnapshot.docs
              .map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'title': data['title'] ?? '',
                  'imageUrl': data['imageUrl'] ?? '',
                  'status': data['status'] ?? 'pending',
                };
              })
              .where((task) => task['status'] != 'done')
              .toList();

      if (taskList.isNotEmpty) {
        await _speak(taskList[0]['title']);
      }

      setState(() {
        _tasks = taskList;
        _loading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setPitch(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  Future<void> _markTaskDone(String taskId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('child')
        .doc('childProfile')
        .collection('tasks')
        .doc(today)
        .collection('taskList')
        .doc(taskId)
        .update({'status': 'done'});
  }

  Future<void> _nextTask() async {
    final currentTaskId = _tasks[_currentIndex]['id'];
    await _markTaskDone(currentTaskId);

    if (_currentIndex < _tasks.length - 1) {
      setState(() {
        _completedTasks++;
        _currentIndex++;
      });
      await _speak(_tasks[_currentIndex]['title']);
    } else {
      await _speak("Great job! You finished your routine.");
      setState(() {
        _completedTasks++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFFEADCF8);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Guided Routine'),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty
              ? const Center(child: Text("No tasks for today"))
              : Column(
                children: [
                  const SizedBox(height: 20),
                  Lottie.asset(
                    'assets/animations/robot_guide.json',
                    height: 180,
                  ),
                  const SizedBox(height: 20),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _completedTasks / _tasks.length,
                          color: Colors.purple,
                          backgroundColor: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Step ${_currentIndex + 1} of ${_tasks.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 🔽 Show task image
                        Image.network(
                          _tasks[_currentIndex]['imageUrl'],
                          height: 120,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 100,
                              ),
                        ),

                        const SizedBox(height: 10),

                        // 🔽 Show task title
                        Text(
                          _tasks[_currentIndex]['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        if (_completedTasks > 0)
                          Column(
                            children: List.generate(
                              _completedTasks,
                              (index) => Lottie.asset(
                                'assets/animations/flower_animation.json',
                                height: 50,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _nextTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
