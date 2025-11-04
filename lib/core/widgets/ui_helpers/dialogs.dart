import 'dart:ui';
import 'package:flutter/material.dart';

/// 🌿 Pop-up sukses (Shadcn dark blur)
Future<void> showShadcnDialogSuccess(
  BuildContext context, {
  String title = 'Berhasil',
  String message = 'Aksi berhasil dilakukan.',
  VoidCallback? onOk,
  String? nextRoute, // 🔹 Optional: navigasi otomatis ke route tertentu
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 26,
              ),
              SizedBox(width: 8),
              Text(
                'Berhasil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                // Tutup dialog dengan rootNavigator
                Navigator.of(dialogContext, rootNavigator: true).pop();

                // Jalankan callback jika ada
                if (onOk != null) onOk();

                // 🔁 Navigasi otomatis jika ada route yang dituju
                if (nextRoute != null) {
                  Navigator.pushReplacementNamed(context, nextRoute);
                }
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// 🔴 Pop-up error (Shadcn dark blur)
Future<void> showShadcnDialogError(
  BuildContext context, {
  String title = 'Terjadi Kesalahan',
  required String message,
  VoidCallback? onOk,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 26),
              SizedBox(width: 8),
              Text(
                'Gagal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                if (onOk != null) onOk();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
