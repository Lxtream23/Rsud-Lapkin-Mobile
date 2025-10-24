import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi", style: AppTextStyle.titleMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sistem Laporan Kinerja (LAPKIN)",
              style: AppTextStyle.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Aplikasi ini dikembangkan oleh Tim IT RSUD Bangil "
              "untuk membantu pegawai dalam penyusunan, pemantauan, "
              "dan pelaporan kinerja secara digital, efisien, dan transparan.",
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text("Versi Aplikasi: 1.0.0", style: AppTextStyle.bodySmall),
            const SizedBox(height: 4),
            Text(
              "© 2025 RSUD Bangil | Tim IT RSUD Bangil",
              style: AppTextStyle.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
