import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GuidedRoutinePage extends StatefulWidget {
  const GuidedRoutinePage({super.key});

  @override
  State<GuidedRoutinePage> createState() => _GuidedRoutinePageState();
}

class _GuidedRoutinePageState extends State<GuidedRoutinePage> {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _tasks = [
    'Brush your teeth',
    'Get dressed',
    'Eat breakfast',
    'Pack your bag',
    'Put on shoes',
    'Say goodbye',
  ];

  int _currentIndex = 0;
  int _completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _speak(_tasks[_currentIndex]);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setPitch(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  void _nextTask() {
    if (_currentIndex < _tasks.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _speak(_tasks[_currentIndex]);
    } else {
      _speak("Great job! You finished your routine.");
    }
    if (_currentIndex > _completedTasks) {
      setState(() {
        _completedTasks++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFFEADCF8); // soft lavender

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Guided Routine'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Animated Assistant
          Center(
            child: Lottie.asset(
              'assets/animations/robot_guide.json', // Replace with your animation
              height: 180,
              repeat: true,
            ),
          ),
          const SizedBox(height: 20),

          // Task Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: _completedTasks / _tasks.length,
                  color: Colors.purple,
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),

                // Task Display
                Text(
                  'Step ${_currentIndex + 1} of ${_tasks.length}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  _tasks[_currentIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Task Garden: Add a flower or tree after completing a task
                if (_completedTasks > 0)
                  Column(
                    children: List.generate(
                      _completedTasks,
                      (index) => Lottie.asset(
                        'assets/animations/flower_animation.json', // Replace with your flower animation
                        height: 50,
                        repeat: true,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Next Button
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
                  child: const Text('Next', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
