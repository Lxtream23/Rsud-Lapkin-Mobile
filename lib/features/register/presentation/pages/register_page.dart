import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // Responsif
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo dua di atas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo1.png', height: 50),
                      const SizedBox(width: 12),
                      Image.asset('assets/images/logo2.png', height: 50),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  const Text(
                    "Daftar Akun",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subjudul
                  const Text(
                    "Isi data berikut untuk membuat\nakun pegawai baru.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 24),

                  // Input fields
                  const CustomTextField(hintText: "ID Pegawai"),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: "Nama lengkap"),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: "Email"),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: "NIP"),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: "Jabatan"),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: "Pangkat"),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: "Divisi"),
                  const SizedBox(height: 12),
                  const CustomTextField(
                    hintText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  const CustomTextField(
                    hintText: "Konfirmasi Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // Tombol Daftar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "DAFTAR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Link ke login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Kembali ke halaman login
                        },
                        child: const Text(
                          "Login di sini",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
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
}
