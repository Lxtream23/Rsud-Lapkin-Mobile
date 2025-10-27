import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'features/login/presentation/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';
import 'features/profile/presentation/pages/profil_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProfileController())],
      child: const MyApp(),
    ),
  );
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
