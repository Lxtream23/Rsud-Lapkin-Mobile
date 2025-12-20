import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../pages/list_perjanjian/page_list_perjanjian.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PagePerjanjian extends StatelessWidget {
  const PagePerjanjian({super.key});

  Future<List<Map<String, dynamic>>> _fetchPerjanjian() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    final data = await supabase
        .from('perjanjian_kinerja')
        .select('id, status')
        .eq('user_id', user.id);

    return List<Map<String, dynamic>>.from(data);
  }

  int _countByStatus(List<Map<String, dynamic>> data, String? status) {
    if (status == null) return data.length;
    return data.where((e) => e['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Perjanjian',
          style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          // Bagian konten scrollable
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'DAFTAR DATA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'FORM PERJANJIAN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Statistik cards
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchPerjanjian(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text('Gagal memuat data');
                        }

                        final data = snapshot.data ?? [];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCardStatus(
                                      context: context,
                                      number: _countByStatus(
                                        data,
                                        null,
                                      ).toString(),
                                      label: "Laporan Dikirim",
                                      btnColor: Colors.green,
                                      status: null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCardStatus(
                                      context: context,
                                      number: _countByStatus(
                                        data,
                                        'Disetujui',
                                      ).toString(),
                                      label: "Disetujui",
                                      btnColor: Colors.amber,
                                      status: 'Disetujui',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCardStatus(
                                      context: context,
                                      number: _countByStatus(
                                        data,
                                        'Ditolak',
                                      ).toString(),
                                      label: "Ditolak",
                                      btnColor: Colors.red,
                                      status: 'Ditolak',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCardStatus(
                                      context: context,
                                      number: _countByStatus(
                                        data,
                                        'Proses',
                                      ).toString(),
                                      label: "Menunggu",
                                      btnColor: Colors.blue,
                                      status: 'Proses',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Tombol Tambah Perjanjian
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/formPerjanjian');
                      },
                      child: const Text(
                        "Tambah Perjanjian",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Footer tetap di bawah
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
    );
  }

  void _openList(BuildContext context, String? status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PageListPerjanjian(
          status: status,
          showAppBar: true, // 🔥 INI KUNCI-NYA
        ),
      ),
    );
  }

  // Widget Card Statistik
  Widget _buildCardStatus({
    required BuildContext context,
    required String number,
    required String label,
    required Color btnColor,
    required String? status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _openList(context, status),
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              minimumSize: const Size(80, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text("Lihat", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
