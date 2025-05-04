import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SortingActivityPage extends StatefulWidget {
  const SortingActivityPage({super.key});

  @override
  State<SortingActivityPage> createState() => _SortingActivityPageState();
}

class _SortingActivityPageState extends State<SortingActivityPage> {
  final Map<String, List<String>> _categories = {
    'Fruits': [],
    'Animals': [],
    'Vehicles': [],
  };

  List<_DraggableItem> _items = [];
  List<Offset> _starPositions = []; // Track the positions of the stars
  bool _isStarVisible = false; // Controls visibility of the star

  @override
  void initState() {
    super.initState();
    _loadItemsFromFirebase();
  }

  Future<void> _loadItemsFromFirebase() async {
    await Firebase.initializeApp();
    final snapshot =
        await FirebaseFirestore.instance.collection('sorting_items').get();
    final items =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return _DraggableItem(
            name: data['name'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            category: data['category'] ?? '',
          );
        }).toList();

    setState(() {
      _items = items;
    });
  }

  void _showStarAnimation(Offset position) {
    setState(() {
      _starPositions.add(position);
      _isStarVisible = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isStarVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort by Category'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF5F3FF),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: GridView.count(
                  crossAxisCount: 3,
                  children:
                      _items.map((item) {
                        return Draggable<_DraggableItem>(
                          data: item,
                          feedback: Image.network(item.imageUrl, height: 60),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: Image.network(item.imageUrl),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(item.imageUrl, height: 60),
                              Text(item.name),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              const Divider(thickness: 1.5),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      _categories.keys.map((cat) {
                        return DragTarget<_DraggableItem>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              width: 100,
                              height: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    cat,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ..._categories[cat]!.map(
                                    (imgUrl) =>
                                        Image.network(imgUrl, height: 30),
                                  ),
                                ],
                              ),
                            );
                          },
                          onAccept: (item) {
                            if (item.category == cat) {
                              setState(() {
                                _categories[cat]!.add(item.imageUrl);
                                _items.remove(item);
                              });

                              // Trigger the star animation when the item is correctly placed
                              final starPosition = Offset(
                                100.0,
                                200.0,
                              ); // Placeholder position
                              _showStarAnimation(starPosition);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Oops! ${item.name} does not belong in $cat.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          // Display stars for each correct placement
          if (_isStarVisible)
            ..._starPositions.map((position) {
              return AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                left: position.dx,
                top: position.dy,
                child: Icon(Icons.star, color: Colors.yellow, size: 50),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class _DraggableItem {
  final String name;
  final String imageUrl;
  final String category;

  _DraggableItem({
    required this.name,
    required this.imageUrl,
    required this.category,
  });
}
