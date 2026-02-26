import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanitrix_admin_app/core/constants/colors.dart';

class AdminAuthShell extends StatelessWidget {
  final Widget child;
  const AdminAuthShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.logoTeal, AppColors.logoBlue],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Text("Sanitrix", 
                  style: GoogleFonts.poppins(
                    fontSize: 70, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.logoDeepBlue,
                    letterSpacing: -2,
                    height: 0.8,
                  ),
                ),
                Text("admin", 
                  style: GoogleFonts.clickerScript(
                    fontSize: 45, 
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                // Form Card
                Container(
                  width: 450,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}