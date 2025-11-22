import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../presentation/widgets/card_table1.dart';
import '../../presentation/widgets/card_table2.dart';
import '../../presentation/widgets/card_table3.dart';

class FormPerjanjianPage extends StatefulWidget {
  const FormPerjanjianPage({Key? key}) : super(key: key);

  @override
  State<FormPerjanjianPage> createState() => _FormPerjanjianPageState();
}

class _FormPerjanjianPageState extends State<FormPerjanjianPage> {
  final TextEditingController namaController = TextEditingController();
  String? selectedJabatan;

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

  // Table data stores (controllers)
  final List<List<TextEditingController>> table1 =
      []; // NO, SASARAN, INDIKATOR, TARGET, FORMULASI, SUMBER
  final List<List<TextEditingController>> table2 =
      []; // NO, PROGRAM, ANGGARAN, KETERANGAN
  final List<List<TextEditingController>> triwulan = []; // 7 columns

  // helpers to create rows
  List<TextEditingController> _newRow(int cols) =>
      List.generate(cols, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    // start each table with 1 empty row
    table1.add(_newRow(5));
    table2.add(_newRow(3));
    triwulan.add(_newRow(7));
  }

  @override
  void dispose() {
    namaController.dispose();
    for (final r in table1) for (final c in r) c.dispose();
    for (final r in table2) for (final c in r) c.dispose();
    for (final r in triwulan) for (final c in r) c.dispose();
    super.dispose();
  }

  // ----------------- UI helpers -----------------
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

  // ----------------- Main build -----------------
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

                    // === Card-based Table 1 ===
                    CardTable1Widget(
                      rows: table1,
                      onAddRow: () => setState(() => table1.add(_newRow(5))),
                      onDeleteRow: (i) {
                        if (table1.length == 1) {
                          for (final c in table1.first) c.clear();
                        } else {
                          setState(() {
                            for (final c in table1[i]) c.dispose();
                            table1.removeAt(i);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // === Card-based Triwulan ===
                    CardTable2Widget(
                      rows: triwulan,
                      onAddRow: () => setState(() => triwulan.add(_newRow(7))),
                      onDeleteRow: (i) {
                        if (triwulan.length == 1) {
                          for (final c in triwulan.first) c.clear();
                        } else {
                          setState(() {
                            for (final c in triwulan[i]) c.dispose();
                            triwulan.removeAt(i);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // === Card-based Table 2 ===
                    CardTable3Widget(
                      rows: table2,
                      onAddRow: () => setState(() => table2.add(_newRow(3))),
                      onDeleteRow: (i) {
                        if (table2.length == 1) {
                          for (final c in table2.first) c.clear();
                        } else {
                          setState(() {
                            for (final c in table2[i]) c.dispose();
                            table2.removeAt(i);
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 18),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {},
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
