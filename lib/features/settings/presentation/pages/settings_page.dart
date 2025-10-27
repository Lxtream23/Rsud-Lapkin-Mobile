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

  // 🔹 Controllers
  final _oldPasswordController = TextEditingController();
  final _confirmOldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _oldEmailController = TextEditingController();
  final _newEmailController = TextEditingController();

  bool _isLoading = false;
  String userId = "123";

  // 🔹 Error message variables
  String? _oldPasswordError;
  String? _confirmOldPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;
  String? _oldEmailError;
  String? _newEmailError;

  @override
  void initState() {
    super.initState();

    // 🔹 Realtime validation listeners
    _oldPasswordController.addListener(_validatePasswordFields);
    _confirmOldPasswordController.addListener(_validatePasswordFields);
    _newPasswordController.addListener(_validatePasswordFields);
    _confirmNewPasswordController.addListener(_validatePasswordFields);
    _oldEmailController.addListener(_validateEmailFields);
    _newEmailController.addListener(_validateEmailFields);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _confirmOldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _oldEmailController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  // ==========================
  // 🔹 VALIDASI REALTIME
  // ==========================
  void _validatePasswordFields() {
    setState(() {
      final oldPass = _oldPasswordController.text.trim();
      final confirmOld = _confirmOldPasswordController.text.trim();
      final newPass = _newPasswordController.text.trim();
      final confirmNew = _confirmNewPasswordController.text.trim();

      _oldPasswordError = oldPass.isEmpty ? "Password lama wajib diisi." : null;

      _confirmOldPasswordError = confirmOld.isEmpty
          ? "Konfirmasi password lama wajib diisi."
          : (confirmOld != oldPass ? "Password lama tidak cocok." : null);

      if (newPass.isEmpty) {
        _newPasswordError = "Password baru wajib diisi.";
      } else if (newPass.length < 8) {
        _newPasswordError = "Minimal 8 karakter.";
      } else {
        _newPasswordError = null;
      }

      _confirmNewPasswordError = confirmNew.isEmpty
          ? "Konfirmasi password baru wajib diisi."
          : (confirmNew != newPass ? "Password baru tidak cocok." : null);
    });
  }

  void _validateEmailFields() {
    setState(() {
      final oldEmail = _oldEmailController.text.trim();
      final newEmail = _newEmailController.text.trim();

      _oldEmailError = oldEmail.isEmpty ? "Email lama wajib diisi." : null;

      if (newEmail.isEmpty) {
        _newEmailError = "Email baru wajib diisi.";
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(newEmail)) {
        _newEmailError = "Format email tidak valid.";
      } else {
        _newEmailError = null;
      }
    });
  }

  // ==========================
  // 🔹 SUBMIT PASSWORD
  // ==========================
  Future<void> _handleChangePassword() async {
    _validatePasswordFields();

    // 🔹 Jika masih ada error, stop
    if (_oldPasswordError != null ||
        _confirmOldPasswordError != null ||
        _newPasswordError != null ||
        _confirmNewPasswordError != null)
      return;

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
      _showSnackBar("Password berhasil diubah.", Colors.green);
      _oldPasswordController.clear();
      _confirmOldPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    } else {
      _showSnackBar("Gagal mengubah password.", Colors.red);
    }
  }

  // ==========================
  // 🔹 SUBMIT EMAIL
  // ==========================
  Future<void> _handleChangeEmail() async {
    _validateEmailFields();

    if (_oldEmailError != null || _newEmailError != null) return;

    setState(() => _isLoading = true);

    final success = await controller.changeEmail(
      userId: userId,
      oldEmail: _oldEmailController.text,
      newEmail: _newEmailController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("Email berhasil diubah.", Colors.green);
      _oldEmailController.clear();
      _newEmailController.clear();
    } else {
      _showSnackBar("Gagal mengubah email.", Colors.red);
    }
  }

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
              // GANTI PASSWORD
              Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Text('Ganti Password', style: AppTextStyle.titleSmall),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField(
                'Password Lama',
                _oldPasswordController,
                true,
                _oldPasswordError,
              ),
              _buildTextField(
                'Konfirmasi Password Lama',
                _confirmOldPasswordController,
                true,
                _confirmOldPasswordError,
              ),
              _buildTextField(
                'Password Baru',
                _newPasswordController,
                true,
                _newPasswordError,
              ),
              _buildTextField(
                'Konfirmasi Password Baru',
                _confirmNewPasswordController,
                true,
                _confirmNewPasswordError,
              ),

              const SizedBox(height: 6),
              _buildSaveButton(_isLoading ? null : _handleChangePassword),
              const SizedBox(height: 25),

              // GANTI EMAIL
              Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Text('Ganti Email', style: AppTextStyle.titleSmall),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField(
                'Email Lama',
                _oldEmailController,
                false,
                _oldEmailError,
              ),
              _buildTextField(
                'Email Baru',
                _newEmailController,
                false,
                _newEmailError,
              ),

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
    String? errorText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
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
              errorText: null, // kita handle manual
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ),
        ],
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
