import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool isChatOpen = false;

  final String openAIKey = "your_openai_api_key"; // Replace with actual API key
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "fjS6QHas0dSnrqB729lwmVaUqdk2"; // User ID to store data

  // Function to get AI response from OpenAI GPT
  Future<String> getAIResponse(String userInput) async {
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $openAIKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "You are a helpful AI companion."},
            {"role": "user", "content": userInput},
          ],
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString();
      } else {
        return "Error: Unable to fetch AI response.";
      }
    } catch (e) {
      return "Error: Could not connect to the server.";
    }
  }

  // Add entry to Firestore with timestamp
  Future<void> _addLogToFirestore(String log) async {
    try {
      final Timestamp timestamp = Timestamp.now();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('selfCareLogs')
          .add({'log': log, 'timestamp': timestamp});
    } catch (e) {
      print("Error adding log: $e");
    }
  }

  void toggleChat() {
    setState(() {
      isChatOpen = !isChatOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Self-Care Log'),
        backgroundColor: const Color(0xFFA8DADC),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Daily Self-Care Log:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    var logData = logs[index];
                    var log = logData['log'];
                    var timestamp =
                        (logData['timestamp'] as Timestamp).toDate();
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: logController,
              decoration: InputDecoration(
                hintText: 'Write your self-care log...',
                filled: true,
                fillColor: const Color(0xFFB4E1B2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (text) {
                setState(() {
                  logs.add(text);
                });
                _addLogToFirestore(text); // Add log to Firestore
                logController.clear();
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: toggleChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA8DADC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
            ),
            child: const Text(
              "AI Chat",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          if (isChatOpen) _buildChatPanel(),
        ],
      ),
    );
  }

  Widget _buildChatPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text(
            "AI Chat Companion",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(messages[index]));
              },
            ),
          ),
          TextField(
            controller: chatController,
            decoration: InputDecoration(
              hintText: 'Ask AI...',
              filled: true,
              fillColor: const Color(0xFFE0E0E0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (text) async {
              setState(() {
                messages.add("You: $text");
              });

              String aiResponse = await getAIResponse(text);
              setState(() {
                messages.add("AI: $aiResponse");
              });

              chatController.clear();
            },
          ),
        ],
      ),
    );
  }
}