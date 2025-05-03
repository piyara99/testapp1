import 'package:flutter/material.dart';

class ChildHomePage extends StatelessWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'title': 'Daily Schedule',
        'icon': Icons.calendar_today,
        'route':
            '/visual_schedule', // Changed route to the visual_schedule_page
      },
      {'title': 'Fun Rewards', 'icon': Icons.star, 'route': '/rewards'},
      {
        'title': 'Check My Mood',
        'icon': Icons.emoji_emotions,
        'route': '/guided_routine', // Changed route to guided_routine_page
      },
      {
        'title': 'Say with Pictures',
        'icon': Icons.image,
        'route': '/picture_exchange', // Changed route to picture_exchange.dart
      },
      {
        'title': 'Matching Activity', // Renamed to Matching Activity
        'icon': Icons.pets,
        'route': '/memory_match', // Route for memory_match.dart
      },
      {
        'title': 'Sorting Images', // Renamed to Sorting Images
        'icon': Icons.favorite,
        'route': '/sorting_activity', // Route for sorting_activity.dart
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF), // Soft lavender background
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
                      color: Colors.deepPurple,
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
