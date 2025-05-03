import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E1FF), // Soft lavender background
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('How Do You Feel?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Tap the emoji that best represents how you feel!',
              style: TextStyle(fontSize: 18, color: Colors.purple),
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
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionButton(String emotion, String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion;
        });
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 50)),
          const SizedBox(height: 5),
          Text(
            emotion,
            style: const TextStyle(fontSize: 16, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}
