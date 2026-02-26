import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanitrix_admin_app/core/constants/colors.dart';
import 'package:sanitrix_admin_app/features/auth/widgets/auth_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminAuthShell(
      child: Column(
        children: [
          Text(
            "Welcome to the Control Center",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Efficiently manage city-wide sanitation operations and AI-driven task dispatches.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 40),
          
          // Login Button
          _buildWelcomeButton(
            context, 
            label: "LOGIN TO DASHBOARD", 
            isPrimary: true, 
            onTap: () => Navigator.pushNamed(context, '/login'),
          ),
          
          const SizedBox(height: 16),
          
          // Signup Button
          _buildWelcomeButton(
            context, 
            label: "CREATE ADMIN ACCOUNT", 
            isPrimary: false, 
            onTap: () => Navigator.pushNamed(context, '/signup'),
          ),
          
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            "Version 1.0.0-Admin",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeButton(BuildContext context, {required String label, required bool isPrimary, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.logoDeepBlue : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppColors.logoDeepBlue,
          elevation: isPrimary ? 0 : 0,
          side: isPrimary ? BorderSide.none : const BorderSide(color: AppColors.logoDeepBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.8),
        ),
      ),
    );
  }
}