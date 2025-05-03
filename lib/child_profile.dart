import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_page.dart';
import 'image_library_page.dart';

class ChildTasksPage extends StatelessWidget {
  const ChildTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(body: Center(child: Text('No user is logged in.')));
    }

    return Scaffold(
      backgroundColor: Colors.purple[50],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple[300]),
              child: Text(
                'Welcome 🎈',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.purple),
              title: Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.purple),
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Your Tasks 📝',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Greeting Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Text(
                  'Hello, Miguel! 👋',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Are you ready to conquer today’s tasks?',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Task Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('child')
                      .doc('childProfile')
                      .collection('tasks')
                      .where('status', isNotEqualTo: 'done')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      '🎉 No tasks left! Great job!',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final tasks = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final imageUrl = task['imageUrl'] ?? '';
                    final title = task['taskName'] ?? 'Task';

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TaskPage(
                                  taskId: task.id,
                                  taskName: title,
                                  imageUrl: imageUrl,
                                  taskTime: task['taskTime'] ?? 'N/A',
                                ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child:
                                    imageUrl.startsWith('http')
                                        ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.asset(
                                          'assets/default_task.png',
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Image Library Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ImageLibraryPage()),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.image, color: Colors.white),
      ),
    );
  }
}
