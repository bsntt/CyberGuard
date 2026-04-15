import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/auth/LoginScreen.dart';
import 'screens/auth/SignupScreen.dart';
import 'screens/Homescreen.dart';
import 'screens/admin/AdminScreen.dart';
import 'screens/scan_url_screen.dart';
import 'screens/learn.dart';
import 'screens/ProfileScreen.dart';
import 'screens/tips.dart';
import 'screens/play_quiz.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CyberGuard',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminScreen(),
        '/scan-url': (context) => const ScanUrlScreen(),
        '/learn': (context) => LearnScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/tips': (context) => const TipsScreen(),
        '/quiz': (context) {
          final category = ModalRoute.of(context)!.settings.arguments as String;
          return PlayQuizScreen(category: category);
        },
      },
    );
  }
}
