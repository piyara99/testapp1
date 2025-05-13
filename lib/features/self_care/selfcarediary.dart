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
  bool isChatOpen = false;
  int selectedIndex = 0; // 0 = Diary, 1 = AI Chat

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String geminiApiKey = "AIzaSyD-L8s5WcM_2kGGGkC5x5NnqqQywoyRYvM";

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final String userId = getCurrentUserId();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            CircleAvatar(
              child: Icon(Icons.self_improvement, color: Color(0xFF5E35B1)),
            ),
            SizedBox(width: 8),
            Text(
              "Self-Care",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [_buildDiaryPage(userId), _buildChatPanelFull()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ToggleButtons(
        isSelected: [selectedIndex == 0, selectedIndex == 1],
        onPressed: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: Colors.deepPurple,
        color: Colors.deepPurple,
        constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
        children: const [Text('Diary'), Text('AI Chat')],
      ),
    );
  }

  Widget _buildDiaryPage(String userId) {
    bool showLogs = true;

    return StatefulBuilder(
      builder:
          (context, setInnerState) => SingleChildScrollView(
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
                      fillColor: const Color(0xFFEDE7F6), // light purple
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
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                    child: const Text(
                      "Save Log",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Self-Care Logs:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          showLogs ? Icons.expand_less : Icons.expand_more,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          setInnerState(() {
                            showLogs = !showLogs;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (showLogs)
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
                          var timestamp =
                              (logData['timestamp'] as Timestamp).toDate();
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            color: const Color(
                              0xFFEDE7F6,
                            ), // light purple background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(log),
                              subtitle: Text(
                                'Date: ${timestamp.toLocal()}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
    );
  }

  Widget _buildChatPanelFull() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF0F0F0),
      child: Column(
        children: [
          const Text(
            "AI Chat Companion",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(messages[index]));
              },
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: chatController,
            decoration: InputDecoration(
              hintText: "Ask something...",
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  await _handleChatMessage();
                },
              ),
            ),
          ),
        ],
      ),
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
          aiResponse = response;
        } catch (e) {
          aiResponse = 'Error parsing AI response';
        }

        setState(() {
          messages.add("AI: $aiResponse");
        });
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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('selfCareLogs')
          .add({'log': log, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      // Handle error
    }
  }
}
