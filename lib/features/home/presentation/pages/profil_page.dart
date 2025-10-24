import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya", style: AppTextStyle.titleMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 16),
            Text("Nama Pengguna", style: AppTextStyle.titleMedium),
            const SizedBox(height: 8),
            Text("jabatan@rsudbangil.id", style: AppTextStyle.bodySmall),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.badge_outlined,
                color: AppColors.primary,
              ),
              title: const Text("Jabatan"),
              subtitle: const Text("Kabid Pelayanan"),
            ),
            ListTile(
              leading: const Icon(
                Icons.numbers_outlined,
                color: AppColors.primary,
              ),
              title: const Text("NIP"),
              subtitle: const Text("19876543210987"),
            ),
          ],
        ),
      ),
    );
  }
}
