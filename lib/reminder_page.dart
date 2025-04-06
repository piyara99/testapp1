import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Reminders"),
        backgroundColor: Colors.teal,
      ),
      body:
          userId == null
              ? const Center(child: Text("Please sign in to view reminders."))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('reminders')
                        .orderBy('time')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reminders = snapshot.data?.docs ?? [];
                  if (reminders.isEmpty) {
                    return const Center(child: Text("No reminders found."));
                  }
                  return ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final data =
                          reminders[index].data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Untitled';
                      final desc = data['description'] ?? '';
                      final timestamp = data['time'] as Timestamp?;
                      final timeStr =
                          timestamp != null
                              ? DateFormat(
                                'MMM dd, yyyy – hh:mm a',
                              ).format(timestamp.toDate())
                              : 'No time';

                      return Card(
                        color: Colors.teal.shade50,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.notifications_active,
                            color: Colors.teal,
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (desc.isNotEmpty) Text(desc),
                              Text(
                                timeStr,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _addReminderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addReminderDialog() async {
    String title = '';
    String description = '';
    DateTime? selectedTime;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Reminder"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) => title = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        selectedTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                  child: const Text("Pick Time"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (title.isNotEmpty &&
                      selectedTime != null &&
                      userId != null) {
                    await _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('reminders')
                        .add({
                          'title': title,
                          'description': description,
                          'time': Timestamp.fromDate(selectedTime!),
                        });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
