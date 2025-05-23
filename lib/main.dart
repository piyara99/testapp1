// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testapp/models/emotion_based_checkins.dart';

import 'package:testapp/features/auth/signin.dart';
import 'package:testapp/features/dashboard/main_dashboard.dart';
import 'package:testapp/features/games_activities/picture_exchange.dart'; // <-- create this file if not already done
import 'package:testapp/models/visual_schedule_page.dart';
import 'features/guided_routine/guided_routine_page.dart';
import 'features/games_activities/memory_match.dart';
import 'features/games_activities/sorting_activity.dart';
import 'features/child_profile/child_theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChildThemeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caring for Carers',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/visual_schedule': (context) => const VisualSchedulePage(),
        '/emotion_based_checkins': (context) => const EmotionCheckInPage(),
        '/guided_routine': (context) => const GuidedRoutinePage(),
        '/picture_exchange': (context) => const PecPage(),
        '/memory_match': (context) => const MemoryMatchPage(),
        '/sorting_activity': (context) => const SortingActivityPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  Future<void> _checkUserAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2C3E50), // Dark blue
              Color(0xFF4CA1AF), // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Top left faded circle
            Positioned(
              top: -50,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Bottom right faded circle
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo inside a white circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Caring for Carers',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
