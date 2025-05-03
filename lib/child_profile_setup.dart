import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main_dashboard.dart'; // Import the dashboard page

class ChildProfileSetupPage extends StatefulWidget {
  const ChildProfileSetupPage({super.key});

  @override
  _ChildProfileSetupPageState createState() => _ChildProfileSetupPageState();
}

class _ChildProfileSetupPageState extends State<ChildProfileSetupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _medicalInfoController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _colorPreferenceController = TextEditingController();
  final _soundPreferenceController = TextEditingController();
  final _autismLevelController = TextEditingController();
  final _genderController = TextEditingController();

  int _currentStep = 0; // Tracks which stage the user is on
  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Up Child's Profile")),
      body: SingleChildScrollView(
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped:
              (step) => setState(() {
                _currentStep = step;
              }),
          onStepContinue: () {
            if (_currentStep == 0) {
              _saveBasicInfo();
            } else if (_currentStep == 1) {
              _saveAdvancedInfo();
            } else {
              _completeProfileSetup();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: _getSteps(),
        ),
      ),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: Text("Basic Info"),
        content: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Child's Name"),
            ),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(labelText: "Date of Birth"),
            ),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(labelText: "Gender"),
            ),
            TextField(
              controller: _medicalInfoController,
              decoration: InputDecoration(labelText: "Medical Info"),
            ),
            TextField(
              controller: _emergencyContactController,
              decoration: InputDecoration(labelText: "Emergency Contact"),
            ),
          ],
        ),
        isActive: _currentStep == 0,
        state: _currentStep == 0 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: Text("Advanced Preferences"),
        content: Column(
          children: [
            TextField(
              controller: _colorPreferenceController,
              decoration: InputDecoration(labelText: "Preferred Colors"),
            ),
            TextField(
              controller: _soundPreferenceController,
              decoration: InputDecoration(labelText: "Likes/Dislikes Sounds"),
            ),
            TextField(
              controller: _autismLevelController,
              decoration: InputDecoration(labelText: "Autism Level"),
            ),
          ],
        ),
        isActive: _currentStep == 1,
        state: _currentStep == 1 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: Text("Confirmation"),
        content: Column(
          children: [
            Text("You’re all set!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _completeProfileSetup();
              },
              child: Text("Go to Dashboard"),
            ),
          ],
        ),
        isActive: _currentStep == 2,
        state: _currentStep == 2 ? StepState.editing : StepState.complete,
      ),
    ];
  }

  Future<void> _saveBasicInfo() async {
    try {
      // Save the basic information to Firestore under a single childProfile document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc('childProfile')
          .set({
            'name': _nameController.text,
            'dob': _dobController.text,
            'gender': _genderController.text,
            'medicalInfo': _medicalInfoController.text,
            'emergencyContact': _emergencyContactController.text,
          });

      setState(() {
        _currentStep = 1; // Move to next step
      });
    } catch (e) {
      print("Error saving basic info: $e");
    }
  }

  Future<void> _saveAdvancedInfo() async {
    try {
      // Save the advanced preferences to the same childProfile document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('child')
          .doc('childProfile')
          .update({
            'preferredColors': _colorPreferenceController.text,
            'soundPreference': _soundPreferenceController.text,
            'autismLevel': _autismLevelController.text,
          });

      setState(() {
        _currentStep = 2; // Move to confirmation step
      });
    } catch (e) {
      print("Error saving advanced info: $e");
    }
  }

  Future<void> _completeProfileSetup() async {
    // Display confirmation and navigate to the main dashboard after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainDashboard()),
      );
    });
  }
}
