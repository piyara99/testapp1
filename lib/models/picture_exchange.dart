import 'package:flutter/material.dart';

class PecPage extends StatefulWidget {
  const PecPage({super.key});

  @override
  State<PecPage> createState() => _PecPageState();
}

class _PecPageState extends State<PecPage> {
  String sentence = '';

  // Icons for different actions/objects
  final List<String> actions = ['I want', 'I feel'];
  final List<String> objects = ['Water', 'Hungry', 'Tired', 'Toy', 'Food'];

  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E1FF),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('PECS - Build Your Sentence'),
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
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Drag and Drop Area
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDraggableArea(actions),
                const SizedBox(width: 10),
                _buildDraggableArea(objects),
              ],
            ),

            const SizedBox(height: 20),

            // Sentence Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  sentence = selectedItems.join(' → ');
                  selectedItems.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableArea(List<String> items) {
    return Column(
      children:
          items.map((item) {
            return Draggable<String>(
              data: item,
              childWhenDragging: const Icon(
                Icons.accessibility_new,
                color: Colors.transparent,
              ),
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            );
          }).toList(),
    );
  }

  // ignore: unused_element
  Widget _buildDropArea() {
    return DragTarget<String>(
      // ignore: deprecated_member_use
      onAccept: (receivedItem) {
        setState(() {
          selectedItems.add(receivedItem);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 50,
          width: 200,
          color: Colors.purple.shade100,
          child: Center(
            child: Text(
              selectedItems.isEmpty
                  ? 'Drag items here'
                  : selectedItems.join(' → '),
              style: const TextStyle(fontSize: 16, color: Colors.purple),
            ),
          ),
        );
      },
    );
  }
}
