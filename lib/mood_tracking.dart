import 'package:flutter/material.dart';

class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});

  @override
  _MoodTrackingPageState createState() => _MoodTrackingPageState();
}

class _MoodTrackingPageState extends State<MoodTrackingPage> {
  double _moodScore = 5.0;
  double _wellBeingScore = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Well-being Tracker'),
        backgroundColor: Colors.blue[400],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2C3E50), // A darker relaxing blue
              Color(0xFF4CA1AF), // A lighter shade of blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Track Your Mood and Well-being",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Mood Slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mood:",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Slider(
                        value: _moodScore,
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        label: _moodScore.toStringAsFixed(1),
                        onChanged: (double value) {
                          setState(() {
                            _moodScore = value;
                          });
                        },
                      ),
                      Text(
                        _moodScore.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Well-being Slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Well-being:",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Slider(
                        value: _wellBeingScore,
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        label: _wellBeingScore.toStringAsFixed(1),
                        onChanged: (double value) {
                          setState(() {
                            _wellBeingScore = value;
                          });
                        },
                      ),
                      Text(
                        _wellBeingScore.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    // Logic to save or submit the mood data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mood and Well-being Recorded!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[400],
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
