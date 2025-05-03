import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure this is imported
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
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(title: Text('Profile'), onTap: () {}),
            ListTile(title: Text('Settings'), onTap: () {}),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.purple),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Text(
                  'Miguel!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Ready for another day?',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Task Grid from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('child')
                      .doc('childProfile')
                      .collection('tasks')
                      .where('status', isNotEqualTo: 'done') // Filter tasks
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tasks available.'));
                }

                final tasks = snapshot.data!.docs;

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasks.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        // Pass the task data to the TaskPage
                        final taskName = task['taskName'] ?? 'Unnamed Task';
                        final imageUrl = task['imageUrl'] ?? '';
                        final taskTime = task['taskTime'] ?? 'N/A';
                        final taskId = task.id;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TaskPage(
                                  taskId: taskId, // Pass the taskId
                                  taskName: taskName, // Pass the taskName
                                  imageUrl: imageUrl, // Pass the imageUrl
                                  taskTime:
                                      taskTime, // Pass the taskTime (if needed)
                                ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl.startsWith('http')
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Image.asset(
                                  'assets/default_task.png',
                                  fit: BoxFit.cover,
                                ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: Colors.black54,
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  title,
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
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

      // Navigate to Image Library Page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImageLibraryPage()),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.image, color: Colors.white),
      ),
    );
  }
}
