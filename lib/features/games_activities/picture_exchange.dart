import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider to access theme color
import 'package:testapp/features/child_profile/child_theme_provider.dart'; // Import your provider

class PecPage extends StatefulWidget {
  const PecPage({super.key});

  @override
  State<PecPage> createState() => _PecPageState();
}

class _PecPageState extends State<PecPage> {
  String sentence = '';
  final List<String> actions = ['I want', 'I feel'];
  final List<String> objects = ['Water', 'Hungry', 'Tired', 'Toy', 'Food'];
  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    // Access the theme color from ChildThemeProvider
    final themeColor = Provider.of<ChildThemeProvider>(context).childThemeColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF), // Light lavender background
      appBar: AppBar(
        backgroundColor: themeColor, // Use the theme color here
        title: const Text(
          'PECS - Build Your Sentence',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Sentence Display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                sentence.isEmpty ? 'Drag and Drop to Build Sentence' : sentence,
                style: TextStyle(
                  fontSize: 24,
                  color: themeColor, // Use the theme color here
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Drag & Drop Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDraggableArea('Actions', actions, themeColor),
                  ),
                  Expanded(
                    child: _buildDraggableArea('Objects', objects, themeColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Drop Area
            _buildDropArea(themeColor),

            const SizedBox(height: 30),

            // Build Sentence Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  sentence = selectedItems.join(' → ');
                  selectedItems.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor, // Use the theme color here
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Build Sentence',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // white text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableArea(
    String label,
    List<String> items,
    Color themeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ), // Theme color here
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              items.map((item) {
                return Draggable<String>(
                  // Draggable item
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Chip(
                      label: Text(
                        item,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: themeColor,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Chip(
                      label: Text(item),
                      backgroundColor: themeColor.withOpacity(0.3),
                    ),
                  ),
                  child: Chip(
                    label: Text(item),
                    backgroundColor: themeColor.withOpacity(0.7),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropArea(Color themeColor) {
    return DragTarget<String>(
      onAcceptWithDetails: (receivedItem) {
        setState(() {
          selectedItems.add(receivedItem as String);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 60,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1), // Use the theme color here
            border: Border.all(color: themeColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              selectedItems.isEmpty
                  ? 'Drop items here'
                  : selectedItems.join(' → '),
              style: TextStyle(
                fontSize: 18,
                color: themeColor, // Use the theme color here
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
