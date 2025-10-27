import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final controller = SettingsController();

  // 🔹 Text controllers
  final _oldPasswordController = TextEditingController();
  final _confirmOldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  final _oldEmailController = TextEditingController();
  final _newEmailController = TextEditingController();

  bool _isLoading = false;
  String userId = "123"; // 🔹 sementara statis, nanti ambil dari auth session

  // ==========================
  // 🔹 Fungsi Ganti Password
  // ==========================
  Future<void> _handleChangePassword() async {
    setState(() => _isLoading = true);

    final success = await controller.changePassword(
      userId: userId,
      oldPassword: _oldPasswordController.text,
      confirmOldPassword: _confirmOldPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmNewPassword: _confirmNewPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("Password berhasil diubah", Colors.green);
    } else {
      _showSnackBar("Gagal mengubah password", Colors.red);
    }
  }

  // ==========================
  // 🔹 Fungsi Ganti Email
  // ==========================
  Future<void> _handleChangeEmail() async {
    setState(() => _isLoading = true);

    final success = await controller.changeEmail(
      userId: userId,
      oldEmail: _oldEmailController.text,
      newEmail: _newEmailController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("Email berhasil diubah", Colors.green);
    } else {
      _showSnackBar("Gagal mengubah email", Colors.red);
    }
  }

  // 🔹 Snackbar helper
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ==========================
  // 🔹 UI
  // ==========================
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

              _buildSaveButton(_isLoading ? null : _handleChangePassword),

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

              _buildSaveButton(_isLoading ? null : _handleChangeEmail),

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

  Widget _buildSaveButton(VoidCallback? onPressed) {
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
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
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
