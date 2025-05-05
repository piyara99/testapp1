import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EmotionCheckInPage extends StatefulWidget {
  const EmotionCheckInPage({super.key});

  @override
  State<EmotionCheckInPage> createState() => _EmotionCheckInPageState();
}

class _EmotionCheckInPageState extends State<EmotionCheckInPage> {
  String? _selectedEmotion;
  final Map<String, String> _suggestions = {
    'Happy': "Great! Keep having fun!",
    'Tired': "Let's take a rest.",
    'Upset': "It's okay to feel upset. Take a deep breath.",
    'Excited': "Awesome! Keep that energy up!",
    'Sad': "It's okay to be sad. Maybe we can talk about it.",
  };

  // Track emotion counts for chart
  final Map<String, int> _emotionCounts = {
    'Happy': 0,
    'Tired': 0,
    'Upset': 0,
    'Excited': 0,
    'Sad': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background to white
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Deep purple app bar
        title: const Text(
          'How Do You Feel?',
          style: TextStyle(color: Colors.white), // White title
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Tap the emoji that best represents how you feel!',
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Emoji Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEmotionButton('Happy', '😊'),
                    _buildEmotionButton('Tired', '😴'),
                    _buildEmotionButton('Upset', '😢'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEmotionButton('Excited', '😆'),
                    _buildEmotionButton('Sad', '😞'),
                  ],
                ),
                const SizedBox(height: 30),

                // Suggestion Text
                if (_selectedEmotion != null)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _suggestions[_selectedEmotion] ?? 'Let\'s talk!',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Pie Chart
                const SizedBox(height: 20),
                _buildEmotionPieChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionButton(String emotion, String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion;
          _emotionCounts[emotion] = (_emotionCounts[emotion] ?? 0) + 1;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                emotion,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionPieChart() {
    final total = _emotionCounts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return const Text(
        'No emotion data to show chart.',
        style: TextStyle(fontSize: 16, color: Colors.deepPurple),
      );
    }

    final List<PieChartSectionData> sections =
        _emotionCounts.entries.where((entry) => entry.value > 0).map((entry) {
          final percentage = (entry.value / total) * 100;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
            color: _getColorForEmotion(entry.key),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Emotion Chart',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForEmotion(String emotion) {
    switch (emotion) {
      case 'Happy':
        return Colors.green;
      case 'Tired':
        return Colors.blueGrey;
      case 'Upset':
        return Colors.blue;
      case 'Excited':
        return Colors.orange;
      case 'Sad':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
