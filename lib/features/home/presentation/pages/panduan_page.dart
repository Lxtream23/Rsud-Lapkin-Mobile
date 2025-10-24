import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

class PanduanPage extends StatelessWidget {
  const PanduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panduan", style: AppTextStyle.titleMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              "Panduan Penggunaan Aplikasi",
              style: AppTextStyle.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "1. Login menggunakan akun pegawai yang telah terdaftar.\n\n"
              "2. Pilih menu *Perjanjian* untuk membuat atau melihat perjanjian kinerja.\n\n"
              "3. Pilih menu *Laporan Kinerja* untuk mengisi dan memantau laporan capaian.\n\n"
              "4. Gunakan menu *Profil Saya* untuk memperbarui data pribadi Anda.\n\n"
              "5. Jika mengalami kendala, hubungi Tim IT RSUD Bangil.",
              style: AppTextStyle.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
