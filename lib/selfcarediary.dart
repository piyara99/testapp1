import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class AISelfCareDiaryPage extends StatefulWidget {
  const AISelfCareDiaryPage({super.key});

  @override
  AISelfCareDiaryPageState createState() => AISelfCareDiaryPageState();
}

class AISelfCareDiaryPageState extends State<AISelfCareDiaryPage> {
  final TextEditingController logController = TextEditingController();
  final TextEditingController chatController = TextEditingController();

  List<String> logs = [];
  List<String> messages = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String geminiApiKey = "AIzaSyD-L8s5WcM_2kGGGkC5x5NnqqQywoyRYvM";

  int selectedIndex = 0; // 0 = Logs tab, 1 = AI Chat tab

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final String userId = getCurrentUserId();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Self-Care Diary'),
        backgroundColor: const Color(0xFFA8DADC),
      ),
      body: Column(
        children: [
          _buildToggleTabs(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [_buildSelfCareLogView(userId), _buildChatView()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        isSelected: [selectedIndex == 0, selectedIndex == 1],
        onPressed: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedColor: Colors.white,
        fillColor: const Color(0xFFA8DADC),
        color: const Color(0xFFA8DADC),
        constraints: const BoxConstraints(minHeight: 40, minWidth: 150),
        children: const [Text("Self-Care Logs"), Text("AI Companion")],
      ),
    );
  }

  Widget _buildSelfCareLogView(String userId) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Write your Self-Care Log for Today:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: logController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What did you do for self-care today?',
                filled: true,
                fillColor: const Color(0xFFB4E1B2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (logController.text.isNotEmpty) {
                  setState(() {
                    logs.add(logController.text);
                  });
                  _addLogToFirestore(userId, logController.text);
                  logController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8DADC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                "Save Self-Care Log",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Self-Care Logs:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('selfCareLogs')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading logs'));
              }

              final logs = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  var logData = logs[index];
                  var log = logData['log'];
                  var timestamp = (logData['timestamp'] as Timestamp).toDate();
                  return ListTile(
                    title: Text(log),
                    subtitle: Text('Date: ${timestamp.toLocal()}'),
                    tileColor: const Color(0xFFD0F0C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "AI Chat Companion",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder:
                (context, index) => ListTile(title: Text(messages[index])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: chatController,
            decoration: InputDecoration(
              hintText: "Ask something...",
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _handleChatMessage,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFE3F2FD),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleChatMessage() async {
    if (chatController.text.isNotEmpty) {
      setState(() {
        messages.add("You: ${chatController.text}");
      });

      try {
        String response = await getGeminiResponse(chatController.text);

        String aiResponse = '';
        try {
          final responseData = jsonDecode(response);
          aiResponse =
              responseData['candidates'][0]['content']['parts'][0]['text'];
        } catch (e) {
          aiResponse = 'Error parsing AI response';
        }

        if (aiResponse.isNotEmpty) {
          setState(() {
            messages.add("AI: $aiResponse");
          });
        } else {
          setState(() {
            messages.add("AI: No response received");
          });
        }
      } catch (e) {
        setState(() {
          messages.add("AI: Error occurred");
        });
      } finally {
        chatController.clear();
      }
    }
  }

  Future<String> getGeminiResponse(String inputText) async {
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "contents": [
          {
            "parts": [
              {"text": inputText},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['candidates']?[0]['content']?['parts']?[0]['text'] ??
          'No content generated';
    } else {
      return 'Error: ${response.statusCode}';
    }
  }

  Future<void> _addLogToFirestore(String userId, String log) async {
    try {
      final Timestamp timestamp = Timestamp.now();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('selfCareLogs')
          .add({'log': log, 'timestamp': timestamp});
    } catch (e) {
      print('Error adding self-care log to Firestore: $e');
    }
  }

  @override
  void dispose() {
    logController.dispose();
    chatController.dispose();
    super.dispose();
  }
}
