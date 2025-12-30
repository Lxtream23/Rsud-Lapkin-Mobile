import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/config/app_colors.dart';
import 'package:rsud_lapkin_mobile/features/pimpinan/presentation/pages/list_perjanjian_pimpinan/page_list_perjanjian_pimpinan.dart';

class PimpinanDashboardPage extends StatefulWidget {
  const PimpinanDashboardPage({super.key});

  @override
  State<PimpinanDashboardPage> createState() => _PimpinanDashboardPageState();
}

class _PimpinanDashboardPageState extends State<PimpinanDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Container(
          width: double.infinity,
          color: const Color(0xFFE6F7FB),
          child: Column(
            children: [
              // ================= KONTEN =================
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
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
                                style: TextStyle(color: Colors.black54),
                              ),

                              const SizedBox(height: 24),

                              // ========== Kartu Statistik ==========
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  _StatCard(
                                    icon: Icons.assignment,
                                    title: 'Total Laporan\nDiterima',
                                    value: '12',
                                    color: const Color(0xFF009688),
                                    onTap: () {
                                      Navigator.of(context).push(
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
                                  const SizedBox(height: 10),

                                  _StatCard(
                                    icon: Icons.check_circle,
                                    title: 'Disetujui',
                                    value: '5',
                                    color: const Color(0xFFFFEB3B),
                                    textColor: Colors.black,
                                    onTap: () {
                                      Navigator.of(context).push(
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
                                  const SizedBox(height: 10),
                                  _StatCard(
                                    icon: Icons.cancel,
                                    title: 'Ditolak',
                                    value: '5',
                                    color: const Color(0xFFF44336),
                                    onTap: () {
                                      Navigator.of(context).push(
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
                                  const SizedBox(height: 10),
                                  _StatCard(
                                    icon: Icons.hourglass_top,
                                    title: 'Proses',
                                    value: '12',
                                    color: Colors.blue,
                                    heroTag: 'stat-proses',
                                    onTap: () {
                                      Navigator.of(context).push(
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

                              const SizedBox(height: 28),

                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'LAPORAN TERBARU',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              TextField(
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari berdasarkan Nama, Jabatan, Tanggal',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              const _ReportCard(
                                name: 'Budi Santoso',
                                date: '17 Desember 2025',
                                status: 'Diproses',
                              ),
                              const _ReportCard(
                                name: 'Dwi indrianti',
                                date: '15 Desember 2025',
                                status: 'Ditolak',
                              ),
                              const _ReportCard(
                                name: 'Muchlas Aji S.',
                                date: '14 Desember 2025',
                                status: 'Disetujui',
                              ),

                              const Spacer(), // ⬅️ KUNCI BIAR KONTEN NAIK
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ================= FOOTER =================
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final String? heroTag;
  final double? maxWidth;
  final double? maxHeight;

  const _StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
    this.heroTag,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final cardWidth =
        maxWidth ?? (size.width >= 420 ? 110.0 : size.width * 0.26);

    final cardHeight = maxHeight ?? (size.height >= 700 ? 110.0 : 96.0);

    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.12),
        highlightColor: Colors.white.withOpacity(0.06),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: textColor),

              const SizedBox(height: 4),

              /// 🔥 TITLE — fleksibel & tidak overflow
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.95),
                    ),
                  ),
                ),
              ),

              /// 🔥 VALUE — auto scale
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ===== HERO WRAPPER =====
    if (heroTag != null) {
      card = Hero(
        tag: heroTag!,
        flightShuttleBuilder:
            (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: toHeroContext.widget,
              );
            },
        child: card,
      );
    }

    return card;
  }
}

class _ReportCard extends StatelessWidget {
  final String name;
  final String date;
  final String status;

  const _ReportCard({
    required this.name,
    required this.date,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case 'Disetujui':
        return Colors.yellow.shade700;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
