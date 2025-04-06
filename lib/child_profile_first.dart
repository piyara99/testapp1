import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChildProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChildProfilePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onProfileClick() {
    print("Profile clicked!");
  }

  void onAccept() {
    print("Accept clicked!");
  }

  void onReject() {
    print("Reject clicked!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 🔑 Connect the key
      backgroundColor: Colors.black87,
      drawer: Drawer( // ✅ Drawer Added
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => print("Profile tapped"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => print("Settings tapped"),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(0), // Ensure no extra margin
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Top Row (Menu + Profile Image)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.purple, size: 30),
                    onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                  ),
                  GestureDetector(
                    onTap: onProfileClick,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/profile.png'),
                      radius: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Top Image Box
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8),
                child: Image.asset('assets/head_sketches1.png'),
              ),
              SizedBox(height: 10),

              // Bottom Image Box
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(8),
                child: Image.asset('assets/head_sketches2.png'),
              ),
              SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: onReject,
                    child: CircleAvatar(
                      backgroundColor: Colors.purple,
                      radius: 30,
                      child: Icon(Icons.close, color: Colors.white, size: 30),
                    ),
                  ),
                  GestureDetector(
                    onTap: onAccept,
                    child: CircleAvatar(
                      backgroundColor: Colors.purple,
                      radius: 30,
                      child: Icon(Icons.check, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
