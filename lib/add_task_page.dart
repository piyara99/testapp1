import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:testapp/routines_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _taskNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  TimeOfDay? _selectedTime;
  String _repeatOption = 'None';
  String _categoryOption = 'One-time';
  bool _reminderEnabled = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<String> _routines = [];

  @override
  void initState() {
    super.initState();
    initializeNotification();
    tz.initializeTimeZones();
    _fetchRoutines();
  }

  void initializeNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchRoutines() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final routinesSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('child')
              .doc('childProfile')
              .collection('routines')
              .get();

      setState(() {
        _routines =
            routinesSnapshot.docs
                .map((doc) => doc['routineName'] as String)
                .toList();
      });
    } catch (e) {
      print("Error fetching routines: $e");
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() async {
    if (_taskNameController.text.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Reminder could not be set: exact alarms not permitted. Please allow the app in system settings.',
          ),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: _openExactAlarmSettings,
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final DateTime taskDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Save the task in the correct Firestore path
      DocumentReference taskRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc('childProfile') // Specify childProfile document
          .collection('tasks') // Tasks subcollection under childProfile
          .add({
            'taskName': _taskNameController.text,
            'taskTime': taskDateTime,
            'durationMinutes': int.tryParse(_durationController.text) ?? 0,
            'repeat': _repeatOption,
            'category': _categoryOption,
            'reminder': _reminderEnabled,
            'imageUrl': _imageUrlController.text,
            'status': 'not done',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Schedule the notification if reminder is enabled
      if (_reminderEnabled) {
        _scheduleNotification(taskRef.id, taskDateTime);
      }

      Navigator.pop(context);
    } catch (e) {
      print("Error saving task: $e");
    }
  }

  Future<void> _scheduleNotification(
    String taskId,
    DateTime scheduledTime,
  ) async {
    try {
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        taskId.hashCode,
        'Task Reminder',
        _taskNameController.text,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Reminder could not be set: exact alarms not permitted. Please allow the app in system settings.',
            ),
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  void _openExactAlarmSettings() {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(
                text:
                    _selectedTime == null ? '' : _selectedTime!.format(context),
              ),
              readOnly: true,
              decoration: InputDecoration(labelText: 'Select Time'),
              onTap: _pickTime,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _repeatOption,
              items:
                  ['None', 'Daily', 'Weekly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _repeatOption = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Repeat'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _categoryOption,
              items:
                  ['One-time', ..._routines].map((String value) {
                    // Ensuring only one occurrence of 'One-time'
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _categoryOption = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Category'),
            ),

            SizedBox(height: 10),
            SwitchListTile(
              title: Text('Reminder'),
              value: _reminderEnabled,
              onChanged: (bool value) {
                setState(() {
                  _reminderEnabled = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL (optional)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveTask, child: Text('Save Task')),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_view_week),
              label: const Text('Go to Routines'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoutinesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
