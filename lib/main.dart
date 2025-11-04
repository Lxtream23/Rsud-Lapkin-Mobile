import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'core/services/supabase_service.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';
import 'features/register/presentation/controllers/register_controller.dart';
import 'features/login/presentation/controllers/login_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔹 Inisialisasi Supabase
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('❌ Gagal inisialisasi Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => RegisterController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RSUD Lapkin Mobile',
        theme: ThemeData(
          fontFamily: 'Poppins',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          scaffoldBackgroundColor: Colors.white,
        ),

        /// 🔹 Splash dulu → lalu login / home otomatis
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,

        /// 🔸 Tambahan keamanan untuk route yang tidak ditemukan
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Halaman tidak ditemukan 😅',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
