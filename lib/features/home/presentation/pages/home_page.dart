import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            Image.asset('assets/images/logo1.png', height: 30),
            const SizedBox(width: 4),
            Image.asset('assets/images/logo2.png', height: 30),
            const SizedBox(width: 8),
            const Text(
              'LAPKIN',
              style: TextStyle(
                color: Color(0xFF008037),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bagian Tengah (konten utama)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selamat datang di Sistem\nLaporan Kinerja RSUD Bangil.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Pilih menu di bawah untuk melanjutkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 40),
                        _buildMenuCard(
                          icon: Icons.description_outlined,
                          title: 'Perjanjian',
                          onTap: () {
                            Navigator.pushNamed(context, '/perjanjian');
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildMenuCard(
                          icon: Icons.show_chart_outlined,
                          title: 'Laporan Kinerja',
                          onTap: () {
                            Navigator.pushNamed(context, '/laporanKinerja');
                          },
                        ),
                      ],
                    ),
                  ),
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
        0xFFE6F7F1,
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
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 45, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nama Sesuai User yang login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
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
    Color iconColor = Colors.black87,
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

  // ✅ Widget Menu Utama
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 250, // 🔹 kontrol lebar agar tidak terlalu lebar
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // 🔹 benar-benar tengah
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blueAccent, size: 60),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// 🔹 Tombol BUKA
          SizedBox(
            // width: 140,
            // height: 40,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 14,
                ),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'BUKA',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
