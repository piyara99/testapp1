import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Role Selection',
      debugShowCheckedModeBanner: false,
      home: RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(221, 255, 255, 255),
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'Choose One to Continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 30),
              RoleOption(
                imagePath: 'assets/child.png',
                label: 'Child',
                onTap: () {
                  // Handle Child click
                },
              ),
              SizedBox(height: 20),
              RoleOption(
                imagePath: 'assets/carer.png',
                label: 'Carer',
                onTap: () {
                  // Handle Carer click
                },
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  // Handle Log out
                },
                child: Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleOption extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const RoleOption({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 60, height: 60),
            SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
