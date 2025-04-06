import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});

  @override
  _MoodTrackingPageState createState() => _MoodTrackingPageState();
}

class _MoodTrackingPageState extends State<MoodTrackingPage> {
  double _moodScore = 5.0;
  double _wellBeingScore = 5.0;
  String _moodNote = '';
  String _selectedEmoji = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> _emojiOptions = [
    {"emoji": "😊", "label": "Happy"},
    {"emoji": "😐", "label": "Neutral"},
    {"emoji": "😢", "label": "Sad"},
    {"emoji": "😡", "label": "Angry"},
    {"emoji": "😴", "label": "Tired"},
  ];

  Map<String, String> selfCareTips = {
    "Happy": "Keep doing what makes you smile!",
    "Neutral": "Try some music or a short walk to lift your mood.",
    "Sad": "Take a break and talk to someone you trust.",
    "Angry": "Breathe deeply or write down your feelings.",
    "Tired": "Make time to rest and recharge.",
  };

  String? getUserId() {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<void> _saveMoodData() async {
    String? userId = getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not signed in. Please sign in.')),
      );
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_data')
        .add({
          'mood_score': _moodScore,
          'well_being_score': _wellBeingScore,
          'mood_emoji': _selectedEmoji,
          'note': _moodNote.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

    String moodLabel =
        _emojiOptions.firstWhere(
          (e) => e['emoji'] == _selectedEmoji,
          orElse: () => {"label": "Neutral"},
        )["label"]!;

    String suggestion =
        selfCareTips[moodLabel] ?? "Take care of yourself today.";

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mood Recorded! $suggestion')));

    setState(() {
      _moodScore = 5.0;
      _wellBeingScore = 5.0;
      _moodNote = '';
      _selectedEmoji = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Mood Tracker'),
        backgroundColor: Colors.blue[400],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Daily Mood Check-in",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          children:
                              _emojiOptions.map((option) {
                                return ChoiceChip(
                                  label: Text(option['emoji']!),
                                  selected: _selectedEmoji == option['emoji'],
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedEmoji =
                                          selected ? option['emoji']! : '';
                                    });
                                  },
                                  backgroundColor: Colors.white24,
                                  selectedColor: Colors.white,
                                  labelStyle: TextStyle(
                                    fontSize: 24,
                                    color:
                                        _selectedEmoji == option['emoji']
                                            ? Colors.blue[400]
                                            : Colors.white,
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 30),
                        _buildSlider(
                          "Mood",
                          _moodScore,
                          (val) => setState(() => _moodScore = val),
                        ),
                        const SizedBox(height: 20),
                        _buildSlider(
                          "Well-being",
                          _wellBeingScore,
                          (val) => setState(() => _wellBeingScore = val),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Optional note or reflection...',
                            hintStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) => _moodNote = value,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _saveMoodData,
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title:",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        Slider(
          value: value,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
