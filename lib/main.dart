// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sanitrix_admin_app/core/services/data.dart';
import 'package:sanitrix_admin_app/features/auth/screens/welcome_screen.dart';
import 'package:sanitrix_admin_app/features/auth/screens/login_screen.dart';
import 'package:sanitrix_admin_app/features/auth/screens/signup_screen.dart';
import 'package:sanitrix_admin_app/features/auth/screens/profile_setup_screen.dart';
import 'package:sanitrix_admin_app/features/dashboard/screens/dashboard_screen.dart'; // Create this file next

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockDataService.init();
  runApp(const SanitrixAdminApp());
}

class SanitrixAdminApp extends StatelessWidget {
  const SanitrixAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sanitrix Admin',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/dashboard': (context) => const DashboardScreen(), // The Main Hub
      },
    );
  }
}