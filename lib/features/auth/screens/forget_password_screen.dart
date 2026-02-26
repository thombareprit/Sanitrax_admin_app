import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanitrix_admin_app/core/constants/colors.dart';
import 'package:sanitrix_admin_app/features/auth/widgets/auth_shell.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminAuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 10),
          Text("Reset Password", 
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Enter your admin email to receive a recovery link.", 
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 35),
          
          _buildLabel("Official Email"),
          _buildTextField("admin@sanitrix.com", Icons.alternate_email),
          
          const SizedBox(height: 30),
          _buildPrimaryButton("SEND RECOVERY LINK"),
        ],
      ),
    );
  }

  // Helper methods (Keep consistent with Login/Signup)
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _buildTextField(String hint, IconData icon) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.logoBlue, size: 20),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );

  Widget _buildPrimaryButton(String label) => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.logoDeepBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}