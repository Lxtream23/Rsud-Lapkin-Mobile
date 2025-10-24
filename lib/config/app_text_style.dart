import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

class AppTextStyle {
  // 🔹 Judul besar (misal: halaman utama)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // 🔹 Judul sedang (misal: AppBar, section title)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // 🔹 Subjudul / label form
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  // 🔹 Isi teks normal
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
    height: 1.5,
  );

  // 🔹 Isi teks kecil (misal: footer, keterangan)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
  );

  // 🔹 Gaya khusus tombol utama
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  // 🔹 Gaya link (misal: “Lupa Password?”)
  static const TextStyle link = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );
}
