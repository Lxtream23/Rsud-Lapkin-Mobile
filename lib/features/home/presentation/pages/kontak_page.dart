import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kontak", style: AppTextStyle.titleMedium),
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
            Text("Hubungi Kami", style: AppTextStyle.titleMedium),
            const SizedBox(height: 8),
            Text("Tim IT RSUD Bangil", style: AppTextStyle.bodyMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primary),
              title: const Text("Telepon"),
              subtitle: const Text("(0343) 741118"),
            ),
            ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
              ),
              title: const Text("Email"),
              subtitle: const Text("it@rsudbangil.id"),
            ),
            ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
              ),
              title: const Text("Alamat"),
              subtitle: const Text("Jl. Raya Raci No.12, Bangil, Pasuruan"),
            ),
          ],
        ),
      ),
    );
  }
}
