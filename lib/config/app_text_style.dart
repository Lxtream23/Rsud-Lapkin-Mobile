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

  // 🟢 Heading (judul besar)
  static const TextStyle bold24 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle bold20 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle bold18 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle bold16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle bold14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  // 🔹 Medium weight
  static const TextStyle medium16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle medium14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle medium12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // 🔸 Regular text
  static const TextStyle regular16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const TextStyle regular14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const TextStyle regular12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  // 🩶 Grey text (untuk deskripsi atau teks sekunder)
  static const TextStyle grey14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static const TextStyle grey12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black45,
  );
}
