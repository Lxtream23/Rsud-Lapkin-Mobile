import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Sedikit delay untuk efek loading
    await Future.delayed(const Duration(seconds: 2));

    try {
      final session = supabase.auth.currentSession;

      if (!mounted) return;

      if (session != null && session.user != null) {
        // ✅ Sudah login → arahkan ke home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // 🔹 Belum login → arahkan ke login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        // Jika error parsing session (misal session corrupt)
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Memeriksa sesi pengguna...',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
