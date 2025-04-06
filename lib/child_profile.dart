import 'package:flutter/material.dart';
import 'image_library_page.dart'; // Import the existing image_library_page.dart

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Child Tasks Page',
      debugShowCheckedModeBanner: false,
      home: ChildTasksPage(),
    );
  }
}

class ChildTasksPage extends StatelessWidget {
  final List<String> taskImages = [
    'assets/task1.png',
    'assets/task2.png',
    'assets/task2.png',
    'assets/task1.png',
    'assets/task2.png',
    'assets/task2.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ No black background
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: Text('Profile'), onTap: () {}),
            ListTile(title: Text('Settings'), onTap: () {}),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white, // ✅ Match background to white
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Task Grid
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                itemCount: taskImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Clicked on Task ${index + 1}'),
                      ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            taskImages[index],
                            fit: BoxFit.cover,
                          ),
                          if (index == 0)
                            Align(
                              alignment: Alignment.center,
                              child: Icon(Icons.thumb_up, size: 40, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button to navigate to the existing ImageLibraryPage
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the ImageLibraryPage (which is in image_library_page.dart)
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
