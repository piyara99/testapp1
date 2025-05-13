import 'package:flutter/material.dart';
import 'package:testapp/features/behavior_tracking/behavior_chart_page.dart';
import 'package:testapp/features/behavior_tracking/behavior_tracking.dart';
import 'behavior_calendar_page.dart';
import 'behavior_log_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BehaviorTrackingHomePage extends StatefulWidget {
  const BehaviorTrackingHomePage({super.key});

  @override
  State<BehaviorTrackingHomePage> createState() =>
      _BehaviorTrackingHomePageState();
}

class _BehaviorTrackingHomePageState extends State<BehaviorTrackingHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final List<Widget> pages = [
      const BehaviorTrackingPage(),
      const BehaviorCalendarPage(),
      const BehaviorLogPage(),
      BehaviorChartPage(userId: userId), // ✅ userId now defined above
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Behavior Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Behavior Log',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Chart'),
        ],
      ),
    );
  }
}
