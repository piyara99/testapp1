import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF), // Light lavender background
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.deepPurple,
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
                  Expanded(child: _buildDraggableArea('Actions', actions)),
                  Expanded(child: _buildDraggableArea('Objects', objects)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Drop Area
            _buildDropArea(),

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
                backgroundColor: Colors.deepPurple,
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

  Widget _buildDraggableArea(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              items.map((item) {
                return Draggable<String>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Chip(
                      label: Text(
                        item,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Chip(
                      label: Text(item),
                      backgroundColor: Colors.deepPurple[100],
                    ),
                  ),
                  child: Chip(
                    label: Text(item),
                    backgroundColor: Colors.deepPurple[200],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropArea() {
    return DragTarget<String>(
      onAccept: (receivedItem) {
        setState(() {
          selectedItems.add(receivedItem);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 60,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              selectedItems.isEmpty
                  ? 'Drop items here'
                  : selectedItems.join(' → '),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
