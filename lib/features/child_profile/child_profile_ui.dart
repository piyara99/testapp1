import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testapp/features/child_profile/child_theme_provider.dart';

class ChildHomePage extends StatefulWidget {
  const ChildHomePage({super.key});

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  bool _isThemeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await Provider.of<ChildThemeProvider>(
      context,
      listen: false,
    ).fetchChildThemeColorFromFirestore();
    setState(() {
      _isThemeLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final childColor = Provider.of<ChildThemeProvider>(context).childThemeColor;

    if (!_isThemeLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final options = [
      {
        'title': 'Daily Schedule',
        'icon': Icons.calendar_today,
        'route': '/visual_schedule',
      },
      {'title': 'Routine', 'icon': Icons.star, 'route': '/guided_routine'},
      {
        'title': 'Check My Mood',
        'icon': Icons.emoji_emotions,
        'route': '/emotion_based_checkins',
      },
      {
        'title': 'Say with Pictures',
        'icon': Icons.image,
        'route': '/picture_exchange',
      },
      {
        'title': 'Matching Activity',
        'icon': Icons.pets,
        'route': '/memory_match',
      },
      {
        'title': 'Sorting Images',
        'icon': Icons.favorite,
        'route': '/sorting_activity',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: childColor,
        title: const Text(
          'Hello, Miguel! 👋',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            return GestureDetector(
              onTap:
                  () => Navigator.pushNamed(context, option['route'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      size: 50,
                      color: childColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      option['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
