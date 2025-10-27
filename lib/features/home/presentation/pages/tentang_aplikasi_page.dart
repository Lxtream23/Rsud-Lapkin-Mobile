import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FB), // Warna biru muda lembut
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Tentang Aplikasi',
          style: AppTextStyle.titleMedium.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 Logo dari Assets
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.transparent,
                    ),
                    child: Image.asset(
                      'assets/images/logoAbout.png', // ganti sesuai path logo kamu
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Nama Aplikasi
                  Text(
                    'Sistem Laporan Kinerja',
                    style: AppTextStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Deskripsi Aplikasi
                  Text(
                    'Sistem Laporan Kinerja merupakan aplikasi berbasis web yang dikembangkan untuk mendukung proses administrasi dan pelaporan kinerja pegawai di lingkungan Rumah Sakit Umum Daerah (RSUD) Bangil.\n\n'
                    'Aplikasi ini bertujuan untuk:\n'
                    '1. Meningkatkan efisiensi dalam pengelolaan data perjanjian dan laporan kinerja pegawai.\n'
                    '2. Memfasilitasi proses pelaporan kinerja secara digital, akurat, dan terintegrasi.\n'
                    '3. Menyediakan sarana pemantauan capaian kinerja pegawai secara transparan dan berkesinambungan.\n'
                    '4. Mendukung implementasi tata kelola pemerintahan yang baik (good governance) melalui sistem informasi yang efektif.\n\n'
                    'Dengan hadirnya aplikasi ini, diharapkan seluruh pegawai dapat melakukan pelaporan kinerja dengan lebih mudah, cepat, dan terdokumentasi dengan baik sesuai dengan standar administrasi RSUD Bangil.',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // 🔹 Info Pengembang
                  Text(
                    'Dikembangkan oleh:\nTim IT RSUD Bangil\nVersi: 1.0.0\nTahun: 2025',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 🔹 Footer
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Text(
          '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
        ),
      ),
    );
  }
}
