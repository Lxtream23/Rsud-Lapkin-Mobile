import 'package:flutter/material.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/register/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profil_page.dart';
import '../features/kontak/presentation/pages/kontak_page.dart';
import '../../features/home/presentation/pages/panduan_page.dart';
import '../../features/home/presentation/pages/tentang_aplikasi_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/perjanjian/presentation/pages/page_perjanjian.dart';
import '../../features/perjanjian/presentation/pages/form_perjanjian_page.dart';
import '../../features/pimpinan/presentation/pages/pimpinan_dashboard_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/forgotPassword': (context) => const ForgotPasswordPage(),
    '/verifyCode': (context) => const VerifyCodePage(),
    '/newPassword': (context) => const NewPasswordPage(),
    '/home': (context) => const HomePage(),
    '/profil': (context) => const ProfilPage(),
    '/kontak': (context) => const KontakPage(),
    '/panduan': (context) => const PanduanPage(),
    '/settings': (context) => const SettingsPage(),
    '/tentang': (context) => const TentangAplikasiPage(),
    '/perjanjian': (context) => const PagePerjanjian(),
    '/formPerjanjian': (context) => const FormPerjanjianPage(),
    '/pimpinan': (context) => const PimpinanDashboardPage(),
  };
}
