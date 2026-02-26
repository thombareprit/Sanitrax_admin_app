// import 'dart:developer' as dev; // Add this at the top
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanitrix_admin_app/core/constants/colors.dart';
import 'package:sanitrix_admin_app/features/auth/widgets/auth_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminAuthShell(
      child: Column(
        children: [
          // Header
          Text(
            "Admin Profile Setup",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Define your jurisdiction and role",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 35),

          // Profile Image Picker Section
          _buildProfileImagePicker(),

          const SizedBox(height: 40),

          // Form Fields
          _buildLabel("Official Designation"),
          _buildTextField("e.g. Zonal Commissioner / Waste Manager", Icons.badge_outlined),
          
          const SizedBox(height: 20),
          
          _buildLabel("Assigned City / District"),
          _buildTextField("e.g. Nagpur / Maharashtra", Icons.location_city_rounded),
          
          const SizedBox(height: 20),
          
          _buildLabel("Supervision Ward / Zone"),
          _buildTextField("e.g. Zone 04 - West Ward", Icons.map_outlined),

          const SizedBox(height: 40),

          // Action Button
          _buildPrimaryButton("COMPLETE & LAUNCH DASHBOARD", () {
            // 1. You would save the data to the backend here later
            
            // 2. Navigate and clear the stack
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/dashboard', 
              (route) => false, // This removes all previous screens (Login/Signup/Setup)
            );
          }),
          
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Go Back",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildProfileImagePicker() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.logoBlue.withValues(alpha: 0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.logoTeal.withValues(alpha: 0.1),
            child: const Icon(Icons.person_outline, size: 55, color: AppColors.logoBlue),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              // Add image picker logic later
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.logoDeepBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon) {
    return TextField(
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
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.8),
        ),
      ),
    );
  }
}