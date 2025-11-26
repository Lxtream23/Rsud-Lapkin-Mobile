import 'package:flutter/material.dart';

/// GLOBAL overlay key
final GlobalKey<OverlayState> overlaySnackbarKey = GlobalKey<OverlayState>();

class AppSnackbar {
  static OverlayEntry? _entry;
  static bool _isShowing = false;

  static void _show({
    required BuildContext context,
    required String message,
    required Color color,
    IconData icon = Icons.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (_isShowing) return; // cegah duplikasi
    _isShowing = true;

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _SnackbarCard(color: color, icon: icon, message: message),
        ),
      ),
    );

    overlaySnackbarKey.currentState?.insert(_entry!);

    Future.delayed(duration, () {
      _entry?.remove();
      _isShowing = false;
    });
  }

  // ==== PUBLIC METHODS (dipanggil dari mana saja) ====

  static void success(BuildContext context, String msg) {
    _show(
      context: context,
      message: msg,
      color: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void error(BuildContext context, String msg) {
    _show(context: context, message: msg, color: Colors.red, icon: Icons.error);
  }

  static void warning(BuildContext context, String msg) {
    _show(
      context: context,
      message: msg,
      color: Colors.orange,
      icon: Icons.warning,
    );
  }
}

class _SnackbarCard extends StatelessWidget {
  final Color color;
  final String message;
  final IconData icon;

  const _SnackbarCard({
    required this.color,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: const Offset(0, -0.2),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 3),
              color: color.withOpacity(0.35),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
