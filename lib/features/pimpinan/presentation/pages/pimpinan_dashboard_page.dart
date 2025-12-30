import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/config/app_colors.dart';
import 'package:rsud_lapkin_mobile/features/pimpinan/presentation/pages/list_perjanjian_pimpinan/page_list_perjanjian_pimpinan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rsud_lapkin_mobile/core/services/auth_service.dart';

class PimpinanDashboardPage extends StatefulWidget {
  const PimpinanDashboardPage({super.key});

  @override
  State<PimpinanDashboardPage> createState() => _PimpinanDashboardPageState();
}

class _PimpinanDashboardPageState extends State<PimpinanDashboardPage> {
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
              'PIMPINAN',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Sistem Perjanjian Kinerja',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'RSUD Bangil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== STAT CARD GRID =====
                    Center(
                      child: SizedBox(
                        width: 340, // 2 card × 150 + spacing
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ===== BARIS ATAS =====
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatCard(
                                  icon: Icons.assignment,
                                  title: 'Total Laporan\nDiterima',
                                  value: '12',
                                  color: Colors.green,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PageListPerjanjianPimpinan(
                                              status: null,
                                              showAppBar: true,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _StatCard(
                                  icon: Icons.check_circle,
                                  title: 'Laporan\nDisetujui',
                                  value: '5',
                                  color: Colors.amber,
                                  textColor: Colors.black,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PageListPerjanjianPimpinan(
                                              status: 'Disetujui',
                                              showAppBar: true,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ===== BARIS BAWAH =====
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatCard(
                                  icon: Icons.cancel,
                                  title: 'Laporan\nDitolak',
                                  value: '5',
                                  color: Colors.red,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PageListPerjanjianPimpinan(
                                              status: 'Ditolak',
                                              showAppBar: true,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _StatCard(
                                  icon: Icons.hourglass_top,
                                  title: 'Menunggu',
                                  value: '12',
                                  color: Colors.blue,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PageListPerjanjianPimpinan(
                                              status: 'Proses',
                                              showAppBar: true,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // const Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Text(
                    //     'LAPORAN TERBARU',
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.grey,
                    //     ),
                    //   ),
                    // ),

                    // const SizedBox(height: 12),

                    // TextField(
                    //   decoration: InputDecoration(
                    //     hintText: 'Cari berdasarkan Nama, Jabatan, Tanggal',
                    //     hintStyle: const TextStyle(
                    //       fontSize: 13,
                    //       color: Colors.grey,
                    //     ),
                    //     prefixIcon: const Icon(Icons.search),
                    //     iconColor: Colors.grey,
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(14),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //   ),
                    // ),

                    // const SizedBox(height: 16),

                    // const _ReportCard(
                    //   name: 'Budi Santoso',
                    //   date: '17 Desember 2025',
                    //   status: 'Diproses',
                    // ),
                    // const _ReportCard(
                    //   name: 'Dwi indrianti',
                    //   date: '15 Desember 2025',
                    //   status: 'Ditolak',
                    // ),
                    // const _ReportCard(
                    //   name: 'Muchlas Aji S.',
                    //   date: '14 Desember 2025',
                    //   status: 'Disetujui',
                    // ),
                  ],
                ),
              ),
            ),

            // ===== FOOTER =====
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Text(
                '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 160,
          height: 130, // 🔥 tinggi FIX → tidak unbounded
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 26, color: textColor),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),

              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
