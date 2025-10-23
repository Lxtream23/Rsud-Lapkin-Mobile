import 'package:flutter/material.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/register/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRoutes {
  static const login = '/login';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/forgotPassword': (context) => const ForgotPasswordPage(),
    '/verifyCode': (context) => const VerifyCodePage(),
    '/newPassword': (context) => const NewPasswordPage(),
    '/home': (context) => const HomePage(),
    // '/perjanjian': (context) => const PerjanjianPage(),
    // '/laporanKinerja': (context) => const LaporanKinerjaPage(),
    // '/profil': (context) => const ProfilPage(),
    // '/kontak': (context) => const KontakPage(),
    // '/panduan': (context) => const PanduanPage(),
    // '/tentang': (context) => const TentangAplikasiPage(),
  };
}
