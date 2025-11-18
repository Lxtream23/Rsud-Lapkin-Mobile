import 'package:flutter/material.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:data_table_2/data_table_2.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

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

  /// Membuat tabel dinamis
  List<List<TextEditingController>> generateTableData(int rows, int columns) {
    return List.generate(
      rows,
      (_) => List.generate(columns, (_) => TextEditingController()),
    );
  }

  // Data tabel (pastikan kolom sesuai header yang nanti dipakai)
  late final List<List<TextEditingController>> tabel1 = generateTableData(5, 5);
  late final List<List<TextEditingController>> tabel2 = generateTableData(3, 7);
  late final List<List<TextEditingController>> tabel3 = generateTableData(4, 3);

  @override
  void dispose() {
    namaController.dispose();
    for (final row in tabel1) {
      for (final c in row) {
        c.dispose();
      }
    }
    for (final row in tabel2) {
      for (final c in row) {
        c.dispose();
      }
    }
    for (final row in tabel3) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  // ---------- helper widgets for tables ----------

  // Tabel umum (1 & 3) — dibungkus supaya dapat layout sebelum hit-test
  Widget buildTable({
    required List<String> headers,
    required List<List<TextEditingController>> data,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowHeight: 42,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 48,
        columns: [
          for (var h in headers)
            DataColumn(
              label: Text(
                h,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
        rows: [
          for (var row in data)
            DataRow(
              cells: [
                for (var cell in row)
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: cell,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // Tabel Triwulan (header dua baris), dibungkus aman
  Widget buildTableTriwulan({required List<List<TextEditingController>> data}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowHeight: 42,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 48,
        columns: const [
          DataColumn(
            label: Text(
              "SASARAN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "INDIKATOR",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "TARGET",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text("I", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("II", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("III", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("IV", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: [
          for (var row in data)
            DataRow(
              cells: [
                for (var cell in row)
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: cell,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // Widget _headerBox(String text, {required int flex}) {
  //   return Expanded(
  //     flex: flex,
  //     child: Container(
  //       height: 48,
  //       alignment: Alignment.center,
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.grey.shade400, width: 0.7),
  //         color: Colors.grey.shade200,
  //       ),
  //       child: AutoSizeText(
  //         text,
  //         maxLines: 2,
  //         minFontSize: 9,
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

  // Widget _emptyBox({required int flex}) {
  //   return Expanded(
  //     flex: flex,
  //     child: Container(
  //       height: 32,
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.grey.shade400, width: 0.7),
  //         color: Colors.grey.shade200,
  //       ),
  //     ),
  //   );
  // }

  // ---------- main build ----------
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

                    // FORM NAMA & JABATAN
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

                    // --- tabel 1 ---
                    buildTable(
                      headers: [
                        "SASARAN",
                        "INDIKATOR KINERJA",
                        "TARGET",
                        "FORMULASI HITUNG",
                        "SUMBER DATA",
                      ],
                      data: tabel1,
                    ),
                    const SizedBox(height: 12),

                    // --- tabel triwulan ---
                    buildTableTriwulan(data: tabel2),
                    const SizedBox(height: 12),

                    // --- tabel 3 ---
                    buildTable(
                      headers: ["PROGRAM", "ANGGARAN", "KETERANGAN"],
                      data: tabel3,
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

          // footer tetap di bawah
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
}
