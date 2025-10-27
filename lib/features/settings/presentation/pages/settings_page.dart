import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _oldPasswordController = TextEditingController();
  final _confirmOldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  final _oldEmailController = TextEditingController();
  final _newEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Settings',
          style: AppTextStyle.titleMedium.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Ganti Password
              Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Text('Ganti Password', style: AppTextStyle.titleSmall),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField('Password Lama', _oldPasswordController, true),
              _buildTextField(
                'Konfirmasi Password Lama',
                _confirmOldPasswordController,
                true,
              ),
              _buildTextField('Password Baru', _newPasswordController, true),
              _buildTextField(
                'Konfirmasi Password Baru',
                _confirmNewPasswordController,
                true,
              ),

              const SizedBox(height: 6),

              _buildSaveButton(() {
                // TODO: tambahkan logika ganti password di sini
              }),

              const SizedBox(height: 25),

              // 🔹 Ganti Email
              Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Text('Ganti Email', style: AppTextStyle.titleSmall),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField('Email Lama', _oldEmailController, false),
              _buildTextField('Email Baru', _newEmailController, false),

              const SizedBox(height: 6),

              _buildSaveButton(() {
                // TODO: tambahkan logika ganti email di sini
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // FOOTER
      bottomNavigationBar: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.2),
        ),
      ),
    );
  }

  // 🔹 Widget Reusable untuk TextField
  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    bool obscureText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔹 Widget Tombol Simpan
  Widget _buildSaveButton(VoidCallback onPressed) {
    return Center(
      child: SizedBox(
        width: 180,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'SIMPAN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
