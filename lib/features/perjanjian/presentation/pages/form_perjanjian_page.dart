// lib/views/your_path/form_perjanjian_page.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

// sesuaikan path import widget sesuai struktur proyekmu:
import '../widgets/tabel1.dart';
import '../widgets/tabel2.dart';
import '../widgets/tabelTriwulan.dart';

class FormPerjanjianPage extends StatefulWidget {
  const FormPerjanjianPage({Key? key}) : super(key: key);

  @override
  State<FormPerjanjianPage> createState() => _FormPerjanjianPageState();
}

class _FormPerjanjianPageState extends State<FormPerjanjianPage> {
  final TextEditingController namaController = TextEditingController();
  String? selectedJabatan;

  // contoh daftar jabatan
  final List<String> jabatanList = [
    'Direktur',
    'Wadir Umum dan Keuangan',
    'Wadir Pelayanan',
    'Kabid Pelayanan',
    'Kabid Pelayanan Keperawatan',
    'Kabid Pelayanan Penunjang',
    'Kabag SDM dan Pengembangan',
    'Kabag Umum',
    'Kabag Keuangan',
    'Ketua Tim Kerja',
    'Admin/Staf',
  ];

  // ---- tabel statis (dipakai untuk tabel1 & tabel3) ----
  // jika kamu ingin Table1 dan Table3 external state, kamu bisa mengubah.
  late final List<List<TextEditingController>> tabel1 = _gen(1, 5);
  late final List<List<TextEditingController>> tabel3 = _gen(1, 3);

  // ---- data triwulan (dinamis) ----
  final List<List<TextEditingController>> triwulanData = [];

  // helper: generate controllers
  static List<List<TextEditingController>> _gen(int rows, int cols) =>
      List.generate(
        rows,
        (_) => List.generate(cols, (_) => TextEditingController()),
      );

  @override
  void initState() {
    super.initState();
    // start triwulan dengan satu baris kosong
    _addTriwulanRow();

    // pastikan tabel statis minimal 1 baris (sesuai behavior yang kamu minta)
    if (tabel1.isEmpty)
      tabel1.add(List.generate(5, (_) => TextEditingController()));
    if (tabel3.isEmpty)
      tabel3.add(List.generate(3, (_) => TextEditingController()));
  }

  @override
  void dispose() {
    namaController.dispose();

    // dispose semua controller di tabel statis dan dinamis
    for (final row in tabel1) {
      for (final c in row) c.dispose();
    }
    for (final row in tabel3) {
      for (final c in row) c.dispose();
    }
    for (final row in triwulanData) {
      for (final c in row) c.dispose();
    }

    super.dispose();
  }

  // ---------------- Triwulan helpers ----------------
  void _addTriwulanRow() {
    setState(() {
      triwulanData.add(List.generate(7, (_) => TextEditingController()));
    });
  }

  void _deleteTriwulanRow(int index) {
    setState(() {
      triwulanData.removeAt(index);
    });
  }

  // ---------------- UI small helpers ----------------
  Widget _input(String hint) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Widget _dropdown(String? value, void Function(String?) onChanged) => SizedBox(
    height: 46,
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      hint: const Text("Pilih Jabatan"),
      items: jabatanList
          .map((jab) => DropdownMenuItem(value: jab, child: Text(jab)))
          .toList(),
      onChanged: onChanged,
    ),
  );

  // ----------------- BUILD -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Form Perjanjian',
          style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "PERJANJIAN KINERJA TAHUN 2025 WAKIL\nDIREKTUR PELAYANAN UOBK RSUD BANGIL\nKABUPATEN PASURUAN",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan, dan akuntabel serta berorientasi pada hasil...",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // --- Form singkat ---
                    _input("BUDI SANTOSO"),
                    const SizedBox(height: 8),
                    _input("Administrasi Pengembangan"),
                    const SizedBox(height: 8),
                    const Text("Selanjutnya disebut PIHAK PERTAMA."),
                    const SizedBox(height: 16),
                    _input("Nama Lengkap"),
                    const SizedBox(height: 8),
                    _dropdown(
                      selectedJabatan,
                      (v) => setState(() => selectedJabatan = v),
                    ),
                    const SizedBox(height: 12),
                    const Text("Selanjutnya disebut PIHAK KEDUA."),
                    const SizedBox(height: 24),
                    const Text(
                      "INDIKATOR KINERJA INDIVIDU\nUOBK RSUD BANGIL TAHUN 2025",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // --- Tabel 1 (external widget) ---
                    // Table1Widget memiliki state internal (auto-add logic dan delete)
                    const Table1Widget(),
                    const SizedBox(height: 12),

                    // --- Tabel Triwulan (external widget) ---
                    // TabelTriwulanWidgets expects data & onAddRow
                    TabelTriwulanWidgets(
                      data: triwulanData,
                      onAddRow: _addTriwulanRow,
                      onDeleteRow: _deleteTriwulanRow,
                    ),
                    const SizedBox(height: 12),

                    // --- Tabel 2 (program) ---
                    const Table2Widget(),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          // contoh: ambil data untuk submit — kamu bisa implementasikan sesuai backend
                          // readTriwulanData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "SIMPAN",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // footer
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
    );
  }
}
