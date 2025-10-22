import 'package:flutter/material.dart';
import '../../features/login/presentation/pages/login_page.dart';

class AppRoutes {
  static const login = '/login';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
  };
}
