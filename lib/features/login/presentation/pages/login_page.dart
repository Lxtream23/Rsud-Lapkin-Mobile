import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rsud_lapkin_mobile/config/app_colors.dart';
import 'package:rsud_lapkin_mobile/core/widgets/custom_text_field.dart';
import 'package:rsud_lapkin_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:rsud_lapkin_mobile/features/home/presentation/pages/home_page.dart';
import 'package:rsud_lapkin_mobile/features/register/presentation/pages/register_page.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loginController = Provider.of<LoginController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Logo RSUD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo1.png', height: 50),
                      const SizedBox(width: 12),
                      Image.asset('assets/images/logo2.png', height: 50),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Masuk ke Akun\nAnda",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "USER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    controller: _emailController,
                    hintText: "Masukkan Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email tidak boleh kosong";
                      }
                      if (!value.contains('@')) {
                        return "Format email tidak valid";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "PASSWORD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Masukkan Password",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password tidak boleh kosong";
                      }
                      if (value.length < 6) {
                        return "Minimal 6 karakter";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // 🔴 Error Message
                  if (loginController.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        loginController.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  // 🔵 Tombol MASUK
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: loginController.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              final success = await loginController.login(
                                context,
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                              if (!mounted) return;

                              if (success) {
                                // ✅ Tampilkan dialog sukses
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => _buildDialog(
                                    icon: Icons.check_circle_outline,
                                    color: Colors.greenAccent,
                                    title: "Login Berhasil",
                                    message:
                                        "Selamat datang kembali!\nMengalihkan ke halaman utama...",
                                  ),
                                );

                                // 🔄 Auto redirect setelah 2 detik
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (!mounted) return;
                                  Navigator.pop(context); // Tutup dialog
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HomePage(),
                                    ),
                                  );
                                });
                              } else {
                                final error =
                                    loginController.errorMessage ??
                                    "Login gagal, periksa kembali email dan password.";

                                // ⚠️ Email belum diverifikasi
                                if (error.contains("Email not confirmed")) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => _buildDialog(
                                      icon: Icons.email_outlined,
                                      color: Colors.orangeAccent,
                                      title: "Verifikasi Diperlukan",
                                      message:
                                          "Akun Anda belum dikonfirmasi.\nSilakan cek email Anda untuk memverifikasi.",
                                    ),
                                  );
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (mounted) Navigator.pop(context);
                                    },
                                  );
                                } else {
                                  // ❌ Dialog error umum
                                  showDialog(
                                    context: context,
                                    builder: (context) => _buildDialog(
                                      icon: Icons.error_outline,
                                      color: Colors.redAccent,
                                      title: "Login Gagal",
                                      message: error,
                                    ),
                                  );
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (mounted) Navigator.pop(context);
                                    },
                                  );
                                }
                              }
                            },
                      child: loginController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "MASUK",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔗 Tautan bawah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },

                        child: const Text(
                          "Daftar Akun",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Lupa Password?",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Fungsi Reusable untuk Dialog (tanpa tombol)
  Widget _buildDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 48),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
