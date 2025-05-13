import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class BehaviorCalendarPage extends StatefulWidget {
  const BehaviorCalendarPage({super.key});

  @override
  State<BehaviorCalendarPage> createState() => _BehaviorCalendarPageState();
}

class _BehaviorCalendarPageState extends State<BehaviorCalendarPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  Map<DateTime, List<String>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchBehaviorLogs();
  }

  Future<void> _fetchBehaviorLogs() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('behavior_logs')
            .get();

    Map<DateTime, List<String>> tempEvents = {};

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc['date'];
      DateTime date = DateTime(
        timestamp.toDate().year,
        timestamp.toDate().month,
        timestamp.toDate().day,
      );

      List<String> behaviors = List<String>.from(doc['behaviors']);

      if (tempEvents.containsKey(date)) {
        tempEvents[date]!.addAll(behaviors);
      } else {
        tempEvents[date] = behaviors;
      }
    }

    // Check if the widget is still mounted before calling setState()
    if (mounted) {
      setState(() {
        _events = tempEvents;
      });
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.calendar_today, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'Behavior Calendar',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _selectedDay == null
                    ? const Center(
                      child: Text('Select a day to see behaviors.'),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        children:
                            _getEventsForDay(_selectedDay!)
                                .map(
                                  (behavior) => Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      title: Text(
                                        behavior,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
