import 'package:flutter/material.dart';

/// GLOBAL overlay key (pasang di MaterialApp)
final GlobalKey<OverlayState> overlaySnackbarKey = GlobalKey<OverlayState>();

class AppSnackbar {
  static OverlayEntry? _entry;
  static bool _isShowing = false;

  static void _show({
    required BuildContext context,
    required String message,
    required Color lightColor,
    required Color darkColor,
    IconData icon = Icons.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (_isShowing) return;
    _isShowing = true;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? darkColor : lightColor;

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _SnackbarCard(
            color: bgColor,
            icon: icon,
            message: message,
            isDark: isDark,
          ),
        ),
      ),
    );

    overlaySnackbarKey.currentState?.insert(_entry!);

    Future.delayed(duration, () {
      _entry?.remove();
      _entry = null;
      _isShowing = false;
    });
  }

  // ================= PUBLIC API =================

  static void success(BuildContext context, String msg) {
    _show(
      context: context,
      message: msg,
      icon: Icons.check_circle_rounded,
      lightColor: const Color(0xFF22C55E),
      darkColor: const Color(0xFF16A34A),
    );
  }

  static void error(BuildContext context, String msg) {
    _show(
      context: context,
      message: msg,
      icon: Icons.error_rounded,
      lightColor: const Color(0xFFEF4444),
      darkColor: const Color(0xFFDC2626),
    );
  }

  static void warning(BuildContext context, String msg) {
    _show(
      context: context,
      message: msg,
      icon: Icons.warning_rounded,
      lightColor: const Color(0xFFF59E0B),
      darkColor: const Color(0xFFD97706),
    );
  }

  static void info(BuildContext context, String msg) {
    _show(
      context: context,
      message: msg,
      icon: Icons.info_rounded,
      lightColor: const Color(0xFF3B82F6),
      darkColor: const Color(0xFF2563EB),
    );
  }
}

class _SnackbarCard extends StatelessWidget {
  final Color color;
  final String message;
  final IconData icon;
  final bool isDark;

  const _SnackbarCard({
    required this.color,
    required this.message,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: -20, end: 0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(opacity: 1, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.18),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// AppSnackbar.success(context, 'PDF siap diunduh');
// AppSnackbar.error(context, 'Gagal menghapus dokumen');
// AppSnackbar.warning(context, 'Data belum lengkap');
// AppSnackbar.info(context, 'Sedang memproses...');
