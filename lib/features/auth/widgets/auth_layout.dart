import 'package:flutter/material.dart';
import 'package:sanitrix_admin_app/core/constants/colors.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const AuthLayout({super.key, required this.child, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side: The Branding/Image Side (Takes 60% of screen)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.textPrimary.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(60),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SANiTRAX", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    Text("ADMINISTRATIVE PORTAL", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          // Right Side: The Form Side (Takes 40% of screen)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(50),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}