import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChildThemeProvider with ChangeNotifier {
  Color _childThemeColor = Colors.orange;

  Color get childThemeColor => _childThemeColor;

  // Fetch the theme color from Firestore and update the color
  Future<void> fetchChildThemeColorFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('child')
                .doc('childProfile')
                .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          String hexColor =
              data?['preferredColors'] ??
              '#6A4C9C'; // Default to deep purple if not found
          _childThemeColor = _colorFromHex(hexColor);
          notifyListeners();
        }
      }
    } catch (e) {
      // Set a default color in case of error
      _childThemeColor = Colors.deepPurple;
      notifyListeners();
    }
  }

  // Helper function to convert hex string to Color
  Color _colorFromHex(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }

  // Set the color manually, e.g., for testing or user input
  void setColor(Color newColor) {
    _childThemeColor = newColor;
    notifyListeners();
  }

  // Set the color from a hex string, useful for storing and updating the color in Firestore
  void setColorFromHex(String hexColor) {
    _childThemeColor = _colorFromHex(hexColor);
    notifyListeners();
  }
}
