import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/services/auth_service.dart';
import 'package:rsud_lapkin_mobile/features/home/presentation/widgets/premium_menu_card.dart';
import 'package:rsud_lapkin_mobile/config/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<Map<String, dynamic>> userProfileStream() {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    return supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((data) => data.first);
  }

  String getInitial(String name) {
    if (name.isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    userProfileStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildCustomDrawer(context),
      backgroundColor: const Color(0xFFE6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo_pemda.png', height: 30),
            const SizedBox(width: 4),
            Image.asset('assets/images/logo2.png', height: 30),
            const SizedBox(width: 8),
            const Text(
              'PERKIN',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: const Color(0xFFE6F7FB),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bagian Tengah (konten utama)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Selamat datang di Sistem\nPerjanjian Kinerja RSUD Bangil.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Klik tombol menu di bawah untuk melanjutkan',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                              const Spacer(),
                              // PremiumMenuCard(
                              //   //icon: Icons.description_outlined,
                              //   icon: Icons.article_rounded,
                              //   title: 'Perjanjian',
                              //   onTap: () {
                              //     Navigator.pushNamed(context, '/perjanjian');
                              //   },
                              // ),
                              // const SizedBox(height: 20),
                              // PremiumMenuCard(
                              //   //icon: Icons.show_chart_outlined,
                              //   icon: Icons.show_chart_rounded,
                              //   title: 'Laporan Kinerja',
                              //   onTap: () {
                              //     Navigator.pushNamed(context, '/laporanKinerja');
                              //   },
                              // ),
                              /// Bungkus card dengan Center agar ukurannya proporsional
                              Center(
                                child: PremiumMenuCard(
                                  icon: Icons.description_outlined,
                                  title: "Perjanjian Kinerja",
                                  heroTag: "menu-perjanjian",
                                  maxWidth: 275, // atur lebar card di sini
                                  maxHeight: 180, // atur tinggi card di sini
                                  onTap: () {
                                    Navigator.pushNamed(context, '/perjanjian');
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),
                              const Spacer(),
                              // Center(
                              //   child: PremiumMenuCard(
                              //     icon: Icons.show_chart_outlined,
                              //     title: "Laporan Kinerja",
                              //     heroTag: "menu-kinerja",
                              //     maxWidth: 250, // atur lebar card di sini
                              //     maxHeight: 145, // atur tinggi card di sini
                              //     onTap: () {
                              //       Navigator.pushNamed(context, '/laporanKinerja');
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Widget Drawer Custom (muncul dari kanan)
  Widget _buildCustomDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: const Color(
        0xFFE6F7FB,
      ), // Warna body drawer (hijau muda)
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HEADER (Putih)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: StreamBuilder<Map<String, dynamic>>(
                stream: userProfileStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final data = snapshot.data!;
                  final String fullName = data['nama_lengkap'] ?? '-';
                  final String? avatarUrl = data['foto_profil'];

                  final bool hasAvatar =
                      avatarUrl != null && avatarUrl.isNotEmpty;

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: hasAvatar
                            ? NetworkImage(avatarUrl!)
                            : null,

                        // 🔹 fallback
                        child: !hasAvatar
                            ? Text(
                                getInitial(fullName),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // 🔹 MENU BODY
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 10),
                  _drawerItem(
                    icon: Icons.person_outline,
                    text: 'Profil Saya',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profil');
                    },
                  ),
                  _drawerItem(
                    icon: Icons.phone_outlined,
                    iconColor: AppColors.primary,
                    text: 'Kontak',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/kontak');
                    },
                  ),
                  _drawerItem(
                    icon: Icons.help_outline,
                    text: 'Panduan',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/panduan');
                    },
                  ),
                  _drawerItem(
                    icon: Icons.settings_outlined,
                    text: 'Pengaturan',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  _drawerItem(
                    icon: Icons.info_outline,
                    text: 'Tentang Aplikasi',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tentang');
                    },
                  ),
                ],
              ),
            ),

            // 🔹 FOOTER (Putih)
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  const Divider(height: 1, color: Colors.black26),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await AuthService().logout(context);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Reusable Drawer Item
  Widget _drawerItem({
    required IconData icon,
    required String text,
    Color iconColor = AppColors.primary,
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  // ✅ Widget Menu Card dengan Center
  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Center(
      // ⬅️ memastikan card selalu berada di tengah
      child: PremiumMenuCard(
        icon: icon,
        title: title,
        onTap: onTap,
        maxWidth: 250, // ⬅️ ukuran ideal (tidak terlalu lebar)
      ),
    );
  }
}
  // ✅ Widget Menu Utama
  // Widget _buildMenuCard({
  //   required IconData icon,
  //   required String title,
  //   required VoidCallback onTap,
  // }) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       return MouseRegion(
  //         onEnter: (_) => setState(() => _hovered = true),
  //         onExit: (_) => setState(() => _hovered = false),

  //         child: AnimatedScale(
  //           duration: const Duration(milliseconds: 150),
  //           scale: _pressed ? 0.97 : (_hovered ? 1.03 : 1.00),
  //           curve: Curves.easeOut,

  //           child: AnimatedOpacity(
  //             duration: const Duration(milliseconds: 250),
  //             opacity: _hovered ? 0.95 : 1,

  //             child: GestureDetector(
  //               onTapDown: (_) => setState(() => _pressed = true),
  //               onTapCancel: () => setState(() => _pressed = false),
  //               onTapUp: (_) => setState(() => _pressed = false),
  //               onTap: onTap,

  //               child: Container(
  //                 width: 280,
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 22,
  //                   horizontal: 18,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.85),
  //                   borderRadius: BorderRadius.circular(22),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black.withOpacity(_hovered ? 0.12 : 0.06),
  //                       blurRadius: _hovered ? 26 : 12,
  //                       offset: const Offset(0, 6),
  //                     ),
  //                     if (_hovered)
  //                       BoxShadow(
  //                         color: Colors.blue.withOpacity(0.07),
  //                         blurRadius: 40,
  //                         spreadRadius: 1,
  //                       ),
  //                   ],

  //                   // premium glassmorphism effect
  //                   border: Border.all(color: Colors.white.withOpacity(0.4)),
  //                 ),

  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(icon, size: 55, color: Colors.blueAccent),
  //                         const SizedBox(width: 12),
  //                         Flexible(
  //                           child: Text(
  //                             title,
  //                             style: const TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.w700,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),

  //                     const SizedBox(height: 20),

  //                     // INK RIPPLE BUTTON
  //                     InkWell(
  //                       borderRadius: BorderRadius.circular(12),
  //                       onTap: onTap,
  //                       splashColor: Colors.green.withOpacity(0.25),
  //                       highlightColor: Colors.transparent,
  //                       child: Ink(
  //                         padding: const EdgeInsets.symmetric(
  //                           vertical: 10,
  //                           horizontal: 32,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: Colors.teal,
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: const Text(
  //                           "BUKA",
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w700,
  //                             color: Colors.white,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

