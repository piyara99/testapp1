import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MemoryMatchPage extends StatefulWidget {
  const MemoryMatchPage({super.key});

  @override
  State<MemoryMatchPage> createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends State<MemoryMatchPage> {
  List<String> _imageUrls = [];
  List<_CardItem> _cards = [];
  List<int> _selectedIndexes = [];
  List<int> _matchedIndexes = [];
  bool _loading = true;
  bool _isGameComplete = false;
  List<Offset> _starPositions = [];
  bool _isStarVisible = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      // Fetch images from Firestore
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('imageLibrary')
              .orderBy('timestamp') // Optionally, order by timestamp
              .get();

      final imageUrls =
          querySnapshot.docs.map((doc) {
            // Explicitly cast the 'url' field to a String
            return doc['url'] as String;
          }).toList();

      // Duplicate the URLs to create pairs for the memory game
      final allUrls = [...imageUrls, ...imageUrls];
      allUrls.shuffle(Random());

      setState(() {
        _imageUrls = imageUrls; // This is now a List<String>
        _cards =
            allUrls
                .asMap()
                .entries
                .map((entry) => _CardItem(index: entry.key, url: entry.value))
                .toList();
        _loading = false;
      });
    } catch (e) {
      print("Error loading images from Firestore: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  void _onCardTap(int index) {
    if (_selectedIndexes.length == 2 ||
        _selectedIndexes.contains(index) ||
        _matchedIndexes.contains(index))
      return;

    setState(() {
      _selectedIndexes.add(index);
    });

    if (_selectedIndexes.length == 2) {
      final first = _cards[_selectedIndexes[0]];
      final second = _cards[_selectedIndexes[1]];

      if (first.url == second.url) {
        setState(() {
          _matchedIndexes.addAll(_selectedIndexes);
          _selectedIndexes.clear();
          if (_matchedIndexes.length == _cards.length) {
            _isGameComplete = true;
            _showStarAnimation();
          }
        });
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _selectedIndexes.clear();
          });
        });
      }
    }
  }

  void _showStarAnimation() {
    final random = Random();
    final starPosition = Offset(
      random.nextDouble() * MediaQuery.of(context).size.width,
      random.nextDouble() * MediaQuery.of(context).size.height,
    );
    setState(() {
      _starPositions.add(starPosition);
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
        title: const Text('Match the Pictures'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final isRevealed =
                      _selectedIndexes.contains(index) ||
                      _matchedIndexes.contains(index);

                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color:
                            isRevealed ? Colors.deepPurple[200] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child:
                          isRevealed
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  card.url,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : const Center(
                                child: Icon(
                                  Icons.help_outline,
                                  color: Colors.deepPurple,
                                  size: 40,
                                ),
                              ),
                    ),
                  );
                },
              ),
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
          if (_isGameComplete)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Great Job!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(Icons.star, color: Colors.yellow, size: 100),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CardItem {
  final int index;
  final String url;

  _CardItem({required this.index, required this.url});
}
