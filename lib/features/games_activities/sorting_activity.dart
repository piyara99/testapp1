import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:provider/provider.dart'; // Import provider to access theme color
import 'package:testapp/features/child_profile/child_theme_provider.dart'; // Import your provider

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
    'Actions': [],
    'Toys and Play': [],
    'Clothing': [],
  };

  final Map<String, GlobalKey> _categoryKeys = {
    'Fruits': GlobalKey(),
    'Animals': GlobalKey(),
    'Vehicles': GlobalKey(),
    'Actions': GlobalKey(),
    'Toys and Play': GlobalKey(),
    'Clothing': GlobalKey(),
  };

  List<_DraggableItem> _items = [];
  List<Offset> _starPositions = [];
  bool _isStarVisible = false;

  int _score = 0;
  int _level = 1;
  late Stopwatch _stopwatch;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _loadItemsFromFirebase();
  }

  Future<void> _loadItemsFromFirebase() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('imageLibrary').get();
    final items =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return _DraggableItem(
            name: data['name'] ?? '',
            imageUrl: data['url'] ?? '',
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

  void _playSound(bool correct) {
    _player.stop();
    // Add your sound here
  }

  void _checkForWin() {
    if (_items.isEmpty) {
      _stopwatch.stop();
      _saveGameSession();
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Great Job!'),
              content: const Text('You sorted all the items correctly! 🎉'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetAndShuffleItems();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _saveGameSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final gameId = DateTime.now().millisecondsSinceEpoch.toString();

    final sessionData = {
      'level': _level,
      'score': _score,
      'durationInSeconds': _stopwatch.elapsed.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('child')
        .doc('childProfile')
        .collection('gameProgress')
        .doc('sorting_game')
        .collection('sessions')
        .doc(gameId)
        .set(sessionData);
  }

  void _resetAndShuffleItems() {
    setState(() {
      _items.shuffle(Random());
      _categories.updateAll((key, value) => []);
      _starPositions.clear();
      _isStarVisible = false;
      _score = 0;
      _level++;
      _stopwatch.reset();
      _stopwatch.start();
    });
  }

  Widget _buildCategoryTarget(String cat, Color themeColor) {
    return DragTarget<_DraggableItem>(
      // DragTarget UI
      builder: (context, candidateData, rejectedData) {
        return Container(
          key: _categoryKeys[cat],
          width: 80,
          height: 90,
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: themeColor,
              width: 1.5,
            ), // Use theme color for border
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              cat,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: themeColor, // Use theme color for text
              ),
            ),
          ),
        );
      },
      onAcceptWithDetails: (details) {
        final item = details.data;
        if (item.category == cat) {
          setState(() {
            _categories[cat]!.add(item.imageUrl);
            _items.remove(item);
            _score++;
          });

          _playSound(true);
          _checkForWin();

          final RenderBox box =
              _categoryKeys[cat]!.currentContext!.findRenderObject()
                  as RenderBox;
          final position = box.localToGlobal(Offset.zero);
          _showStarAnimation(position + const Offset(25, 20));
        } else {
          _playSound(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Oops! ${item.name} does not belong in $cat.'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme color from ChildThemeProvider
    final themeColor = Provider.of<ChildThemeProvider>(context).childThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort by Category'),
        backgroundColor: themeColor, // Use theme color for AppBar
      ),
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Level: $_level',
                          style: TextStyle(fontSize: 16, color: themeColor),
                        ),
                        Text(
                          'Score: $_score',
                          style: TextStyle(fontSize: 16, color: themeColor),
                        ),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (_, __) {
                            final seconds = _stopwatch.elapsed.inSeconds;
                            final mins = (seconds ~/ 60).toString().padLeft(
                              2,
                              '0',
                            );
                            final secs = (seconds % 60).toString().padLeft(
                              2,
                              '0',
                            );
                            return Text(
                              'Time: $mins:$secs',
                              style: TextStyle(fontSize: 16, color: themeColor),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      children: [
                        for (var item in _items)
                          Draggable<_DraggableItem>(
                            // Draggable items
                            data: item,
                            feedback: Image.network(item.imageUrl, height: 50),
                            childWhenDragging: Opacity(
                              opacity: 0.4,
                              child: Image.network(item.imageUrl, height: 50),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  item.imageUrl,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/placeholder.jpg',
                                      height: 50,
                                    );
                                  },
                                ),
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1.2),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      physics: const NeverScrollableScrollPhysics(),
                      children:
                          _categories.keys
                              .map(
                                (cat) => _buildCategoryTarget(cat, themeColor),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              if (_isStarVisible)
                ..._starPositions.map((position) {
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: const Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 40,
                    ),
                  );
                }),
            ],
          ),
        ),
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
