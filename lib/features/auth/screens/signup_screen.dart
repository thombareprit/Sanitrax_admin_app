import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanitrix_admin_app/core/constants/colors.dart';
import 'package:sanitrix_admin_app/features/auth/widgets/auth_shell.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminAuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Create Account", 
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text("Join the city sanitation management network", 
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 30),
          
          _buildField("Full Name", Icons.person_outline),
          const SizedBox(height: 16),
          _buildField("Official Email", Icons.email_outlined),
          const SizedBox(height: 16),
          _buildField("Department", Icons.business_outlined),
          const SizedBox(height: 16),
          _buildField("Create Password", Icons.lock_outline, isObscure: true),
          
          const SizedBox(height: 30),
          _buildPrimaryButton("CONTINUE TO PROFILE", () {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/dashboard', 
              (route) => false, // This removes all previous screens (Login/Signup/Setup)
            );
          }),
          
          const SizedBox(height: 16),
          Center(
            child: 
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'), // Redirects to Login
              child: const Text("Already have an account? Login", 
                style: TextStyle(color: AppColors.logoBlue, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Re-using the helpers from Login (you should move these to a shared file later)
  Widget _buildField(String hint, IconData icon, {bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.logoBlue, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.logoDeepBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}