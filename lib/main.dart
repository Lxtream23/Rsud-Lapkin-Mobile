import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'core/services/supabase_service.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';
import 'features/register/presentation/controllers/register_controller.dart';
import 'features/login/presentation/controllers/login_controller.dart';

import 'core/widgets/ui_helpers/app_snackbar.dart';

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

        /// 🔹 Judul aplikasi
        title: 'RSUD Lapkin Mobile',

        /// 🔹 Tema aplikasi
        theme: ThemeData(
          fontFamily: 'Poppins',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          scaffoldBackgroundColor: Colors.white,
        ),

        /// 🔹 Overlay global untuk snackbar custom
        builder: (context, child) {
          return Overlay(
            key: overlaySnackbarKey,
            initialEntries: [OverlayEntry(builder: (context) => child!)],
          );
        },

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
