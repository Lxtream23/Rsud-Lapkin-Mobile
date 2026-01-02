import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/user_role.dart';
import '../services/auth_service.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/pimpinan/presentation/pages/pimpinan_dashboard_page.dart';
import 'splash_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<UserRole> _roleFuture;

  @override
  void initState() {
    super.initState();

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      _roleFuture = AuthService().fetchCurrentRole();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const LoginPage();
    }

    return FutureBuilder<UserRole>(
      future: _roleFuture, // ✅ TIDAK RE-CREATE
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashPage();
        }

        if (snapshot.hasError) {
          return const LoginPage();
        }

        switch (snapshot.data) {
          case UserRole.pimpinan:
            return const PimpinanDashboardPage();
          case UserRole.user:
          default:
            return const HomePage();
        }
      },
    );
  }
}
