import 'package:flutter/material.dart';

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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  '© 2025 RSUD Bangil | Dikelola oleh Tim IT RSUD Bangil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.2, // jarak antar baris lebih rapat
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
      backgroundColor: const Color(0xFFF1FFF9),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nama Sesuai User yang login',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 30, color: Colors.black26),
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
              icon: Icons.info_outline,
              text: 'Tentang Aplikasi',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tentang');
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            _drawerItem(
              icon: Icons.logout,
              text: 'Log Out',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Widget Drawer Item
  Widget _drawerItem({
    required IconData icon,
    required String text,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text, style: TextStyle(color: textColor)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 60),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008037),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'BUKA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
