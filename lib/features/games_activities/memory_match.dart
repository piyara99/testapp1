import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Import provider to access theme color
import 'package:testapp/features/child_profile/child_theme_provider.dart'; // Import your provider

class MemoryMatchPage extends StatefulWidget {
  const MemoryMatchPage({super.key});

  @override
  State<MemoryMatchPage> createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends State<MemoryMatchPage> {
  List<_CardItem> _cards = [];
  final List<int> _selectedIndexes = [];
  final List<int> _matchedIndexes = [];
  bool _loading = true;
  bool _isGameComplete = false;
  final List<Offset> _starPositions = [];
  bool _isStarVisible = false;

  // 👇 Game performance tracking
  late Stopwatch _stopwatch;
  int _correctAttempts = 0;
  int _incorrectAttempts = 0;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('imageLibrary')
              .orderBy('timestamp')
              .limit(
                6,
              ) // Limit to 6 images, because there will be 12 tiles in the game (6 pairs)
              .get();

      final imageUrls =
          querySnapshot.docs.map((doc) => doc['url'] as String).toList();

      final allUrls = [...imageUrls, ...imageUrls]; // Create pairs
      allUrls.shuffle(Random()); // Shuffle images

      setState(() {
        _cards =
            allUrls
                .asMap()
                .entries
                .map((entry) => _CardItem(index: entry.key, url: entry.value))
                .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onCardTap(int index) {
    if (_selectedIndexes.length == 2 ||
        _selectedIndexes.contains(index) ||
        _matchedIndexes.contains(index)) {
      return;
    }

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
          _correctAttempts++;
          if (_matchedIndexes.length == _cards.length) {
            _stopwatch.stop();
            _isGameComplete = true;
            _saveGameResult();
            _showStarAnimation();
          }
        });
      } else {
        _incorrectAttempts++;
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _selectedIndexes.clear();
          });
        });
      }
    }
  }

  Future<void> _saveGameResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final userId = user.uid;
    const childId = 'childProfile'; // Or make dynamic if needed later

    final gameData = {
      'score': _correctAttempts,
      'correctAttempts': _correctAttempts,
      'incorrectAttempts': _incorrectAttempts,
      'timeTakenSeconds': _stopwatch.elapsed.inSeconds,
      'totalCards': _cards.length,
      'date': Timestamp.now(),
      'completed': true,
      'gameId': 'memory_match_v1',
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('child')
        .doc(childId)
        .collection('gameProgress')
        .doc('memory_match_v1')
        .collection('sessions')
        .add(gameData);
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

  void _reshuffleGame() {
    setState(() {
      _cards.clear();
      _selectedIndexes.clear();
      _matchedIndexes.clear();
      _correctAttempts = 0;
      _incorrectAttempts = 0;
      _stopwatch.reset();
      _stopwatch.start();
      _isGameComplete = false;
      _loading = true;
    });

    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme color from ChildThemeProvider
    final childThemeColor =
        Provider.of<ChildThemeProvider>(context).childThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match the Pictures'),
        backgroundColor: childThemeColor, // Use the theme color here
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reshuffleGame, // Reshuffle icon button
          ),
        ],
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
                            isRevealed
                                ? childThemeColor.withOpacity(
                                  0.7,
                                ) // Use the theme color here
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
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
                              : Center(
                                child: Icon(
                                  Icons.help_outline,
                                  color:
                                      childThemeColor, // Use the theme color here
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
            }),
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
