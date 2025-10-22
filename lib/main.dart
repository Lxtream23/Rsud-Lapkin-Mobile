import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'features/login/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(fontFamily: 'Poppins'),
      routes: AppRoutes.routes,
      home: const LoginPage(),
    );
  }
}
