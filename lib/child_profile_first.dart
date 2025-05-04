import 'package:flutter/material.dart';
import 'image_library_page.dart';

class ChildProfilePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ChildProfilePage({super.key});

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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Child Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Caregiver Name'),
              accountEmail: const Text('caregiver@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue[400]),
              ),
              decoration: BoxDecoration(color: Colors.blue[400]),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => print("Profile tapped"),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => print("Settings tapped"),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top Images
              _buildImageCard('assets/head_sketches1.png'),
              const SizedBox(height: 10),
              _buildImageCard('assets/head_sketches2.png'),
              const SizedBox(height: 20),

              // Feature Cards Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _featureCard(
                      context,
                      icon: Icons.photo_library,
                      label: 'Image Library',
                      color: Colors.blue,
                      destination: const ImageLibraryPage(),
                    ),
                    _featureCard(
                      context,
                      icon: Icons.insert_chart,
                      label: 'Other Feature',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(Icons.close, Colors.red, onReject),
                  _actionButton(Icons.check, Colors.green, onAccept),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(imagePath),
    );
  }

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    Widget? destination,
  }) {
    return GestureDetector(
      onTap:
          destination != null
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => destination),
                );
              }
              : null,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        backgroundColor: color,
        radius: 30,
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
