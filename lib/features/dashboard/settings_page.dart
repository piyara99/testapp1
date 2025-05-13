import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testapp/features/dashboard/caregiver_dashboard.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  Color _selectedColor = Colors.blue; // Default color
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch data from /users/{uid}/child/childProfile
  Future<void> _fetchUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      final doc =
          await _firestore
              .collection('users')
              .doc(user!.uid)
              .collection('child')
              .doc('childProfile')
              .get();

      final data = doc.data();
      if (data != null) {
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        isDarkMode = data['darkMode'] ?? false;

        final hexColor = data['preferredColors']; // e.g., "#FFA500"
        if (hexColor is String) {
          final parsed = _parseColorFromHex(hexColor);
          if (parsed != null) {
            setState(() {
              _selectedColor = parsed;
            });
          }
        }
      }
    }
  }

  // Save to /users/{uid}/child/childProfile
  Future<void> _updateUserData() async {
    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('child')
          .doc('childProfile')
          .update({
            'name': nameController.text,
            'email': emailController.text,
            'darkMode': isDarkMode,
            'preferredColors': _colorToHex(_selectedColor), // Save hex string
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save settings')));
    }
  }

  // Convert hex string like "#FFA500" to Color
  Color? _parseColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      return Color(int.parse("0xFF$hexColor"));
    } catch (_) {
      return null;
    }
  }

  // Convert Color to hex string like "#FFA500"
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CaregiverDashboard(),
              ),
            );
          },
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.settings, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'Settings',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFA8DADC),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Profile Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: _inputDecoration("Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: _inputDecoration("Email"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "App Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDarkMode,
              activeColor: const Color(0xFFA8DADC),
              onChanged: (value) => setState(() => isDarkMode = value),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Theme Color",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _colorOption(Colors.blue),
                _colorOption(Colors.green),
                _colorOption(Colors.orange),
                _colorOption(Colors.pink),
                _colorOption(Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 145, 16, 139),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.black : Colors.grey,
            width: 2,
          ),
        ),
      ),
    );
  }
}
