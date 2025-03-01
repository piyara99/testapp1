import 'package:flutter/material.dart';

class AISelfCareDiaryPage extends StatefulWidget {
  const AISelfCareDiaryPage({Key? key}) : super(key: key);

  @override
  _AISelfCareDiaryPageState createState() => _AISelfCareDiaryPageState();
}

class _AISelfCareDiaryPageState extends State<AISelfCareDiaryPage> {
  final TextEditingController diaryController = TextEditingController();
  final TextEditingController chatController = TextEditingController();
  List<String> messages = [];

  // Asynchronous function for AI response (integrating actual API in future)
  Future<String> getAIResponse(String userInput) async {
    // Here, you can integrate with OpenAI or another AI API to get the response.
    // For now, we'll simulate the response.
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return "AI: I hear you! How can I assist you further?"; // Simulated AI response
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB), // Light Gray background
      appBar: AppBar(
        title: Text('AI Self-Care Diary'),
        backgroundColor: Color(0xFFA8DADC), // Soft Blue for the header
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Diary section
            Text(
              'Your Self-Care Diary:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A), // Dark Slate Gray
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: diaryController,
              decoration: InputDecoration(
                hintText: 'Write about your feelings, thoughts, or goals...',
                filled: true,
                fillColor: Color(
                  0xFFB4E1B2,
                ), // Mint Green background for text input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 6,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to save diary entry here (or use a database)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Your diary entry has been saved.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA8DADC), // Soft Blue button
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
              child: Text('Save Entry', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),

            // AI Chat Section
            Text(
              'Chat with AI Companion:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
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
                hintText: 'Ask your AI companion...',
                filled: true,
                fillColor: Color(0xFFB4E1B2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (text) async {
                setState(() {
                  // Add user message to the list
                  messages.add("You: $text");
                });

                // Get AI response
                String aiResponse = await getAIResponse(text);
                setState(() {
                  // Add AI response to the list
                  messages.add(aiResponse);
                });

                // Clear chat input field
                chatController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
