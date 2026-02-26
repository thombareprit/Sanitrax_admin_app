import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanitrix_admin_app/core/constants/colors.dart';
import 'package:sanitrix_admin_app/features/auth/widgets/auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminAuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Control Center Login", 
            style: GoogleFonts.poppins(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
          const SizedBox(height: 8),
          const Text("Enter your administrator credentials", 
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 35),
          
          _buildLabel("Admin ID"),
          _buildTextField("Enter your ID", Icons.badge_outlined),
          
          const SizedBox(height: 20),
          
          _buildLabel("Password"),
          _buildTextField("••••••••", Icons.lock_outline, isObscure: true),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to Forgot Password
              }, 
              child: const Text("Forgot Password?", 
                style: TextStyle(color: AppColors.logoBlue, fontWeight: FontWeight.w600)),
            ),
          ),
          
          const SizedBox(height: 30),
          
          _buildPrimaryButton("ACCESS DASHBOARD", () {
            // Navigation Logic
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/dashboard', 
              (route) => false, // This removes all previous screens (Login/Signup/Setup)
            );
          }),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("New administrator? ", style: TextStyle(color: AppColors.textSecondary)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'), // Redirects to Signup
                child: const Text("Create Account", 
                  style: TextStyle(color: AppColors.logoBlue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.logoBlue, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.logoBlue, width: 1.5),
        ),
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
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
      ),
    );
  }
}