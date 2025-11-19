import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
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

  // helper untuk membuat data tabel (controllers)
  List<List<TextEditingController>> generateTableData(int rows, int cols) {
    return List.generate(
      rows,
      (_) => List.generate(cols, (_) => TextEditingController()),
    );
  }

  // ==== data tabel (pastikan kolom sesuai header) ====
  late final List<List<TextEditingController>> tabel1 = generateTableData(5, 5);
  late final List<List<TextEditingController>> tabel2 = generateTableData(3, 7);
  late final List<List<TextEditingController>> tabel3 = generateTableData(4, 3);

  List<List<TextEditingController>> data = [];

  @override
  void dispose() {
    namaController.dispose();
    for (final r in tabel1) for (final c in r) c.dispose();
    for (final r in tabel2) for (final c in r) c.dispose();
    for (final r in tabel3) for (final c in r) c.dispose();
    super.dispose();
  }

  // ---------- SIMPLE / SAFE TABLE BUILDER ----------
  // headers = list header (excludes "NO")
  // data = list of rows, each row must have same length as headers (TextEditingController)
  Widget buildTableSafe({
    required List<String> headers,
    required List<List<TextEditingController>> data,
    bool showNumber = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final totalCols = headers.length + (showNumber ? 1 : 0);

        // minimal column width (boleh disesuaikan)
        const minColWidth = 100.0;

        // hitung columnWidth: jika layar cukup, pakai pembagian proporsional,
        // kalau tidak, columnWidth tetap minimal sehingga horizontal scroll muncul.
        final columnWidth = (availableWidth / totalCols).clamp(
          minColWidth,
          double.infinity,
        );

        // buat map columnWidths untuk Table widget
        final Map<int, TableColumnWidth> columnWidths = {
          for (int i = 0; i < totalCols; i++) i: FixedColumnWidth(columnWidth),
        };

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            // pastikan tabel minimal selebar parent sehingga Table dapat menghitung layout
            constraints: BoxConstraints(minWidth: availableWidth),
            child: Table(
              columnWidths: columnWidths,
              border: TableBorder.all(color: Colors.grey.shade400, width: 0.8),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // header row
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children:
                      [
                        if (showNumber)
                          _tableHeaderCell("NO")
                        else
                          const SizedBox.shrink(),
                        for (final h in headers)
                          _tableHeaderCell(h.toUpperCase()),
                      ].map((w) {
                        // ensure each header has a widget (no nulls)
                        return (w is SizedBox && w.child == null)
                            ? const SizedBox.shrink()
                            : w;
                      }).toList(),
                ),
                // data rows
                for (int i = 0; i < data.length; i++)
                  TableRow(
                    children: [
                      if (showNumber)
                        _tableBodyCell(
                          Text('${i + 1}', textAlign: TextAlign.center),
                        )
                      else
                        const SizedBox.shrink(),
                      for (int j = 0; j < headers.length; j++)
                        _tableBodyCell(
                          TextField(
                            controller: data[i][j],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AutoSizeText(
        text,
        maxLines: 2,
        minFontSize: 9,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _tableBodyCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(height: 44, child: Center(child: child)),
    );
  }

  // ---------- versi sederhana untuk tabel triwulan (7 kolom) ----------

  /// ================== TABEL TRIWULAN FULL =====================
  /// Panggil: buildTriwulanCombined(data: tabel2)
  Widget buildTriwulanCombined({
    required List<List<TextEditingController>> data,
    required VoidCallback onAddRow, // <- callback untuk tambah baris
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final ratios = <double>[2.0, 2.0, 1.2, 1.0, 1.0, 1.0, 1.0];
        final totalRatio = ratios.reduce((a, b) => a + b);

        final columnWidths = ratios
            .map(
              (r) => (availableWidth * (r / totalRatio)).clamp(
                80.0,
                double.infinity,
              ),
            )
            .toList();

        final totalMinWidth = columnWidths.fold<double>(0, (s, w) => s + w);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: totalMinWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      SizedBox(
                        width: columnWidths[i],
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade200,
                          ),
                          child: Text(
                            ["SASARAN", "INDIKATOR KINERJA", "TARGET"][i],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    // Gabungan target triwulan
                    SizedBox(
                      width:
                          columnWidths[3] +
                          columnWidths[4] +
                          columnWidths[5] +
                          columnWidths[6],
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.grey.shade200,
                        ),
                        child: const Text(
                          "TARGET TRIWULAN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),

                // Sub-header I–IV
                Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      SizedBox(
                        width: columnWidths[i],
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),

                    for (int i = 0; i < 4; i++)
                      SizedBox(
                        width: columnWidths[i + 3],
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade200,
                          ),
                          child: Text(
                            ["I", "II", "III", "IV"][i],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),

                // ================= DATA TABLE =================
                Table(
                  columnWidths: {
                    for (int i = 0; i < 7; i++)
                      i: FixedColumnWidth(columnWidths[i]),
                  },
                  border: TableBorder.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    for (int r = 0; r < data.length; r++)
                      TableRow(
                        children: [
                          for (int c = 0; c < 7; c++)
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: data[r][c],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 13),
                                onTap: () {
                                  if (r == data.length - 1) onAddRow();
                                },
                                onChanged: (v) {
                                  if (r == data.length - 1 && v.isNotEmpty)
                                    onAddRow();
                                },
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget headerTop(String text) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget subHeader(String text) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget subHeaderEmpty() {
    return Container(height: 32, color: Colors.grey.shade200);
  }

  /// =========================
  /// Helper header
  /// =========================

  DataCell headerCell(String text) {
    return DataCell(
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  DataCell subHeaderCell(String text) {
    return DataCell(
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget emptyHeader() {
    return Container(height: 36, color: Colors.grey.shade200);
  }

  Widget headerSub(String text) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget dataCellTF(TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextField(
        controller: c,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    addRow(); // tambah baris pertama
  }

  void addRow() {
    data.add(List.generate(7, (index) => TextEditingController()));
    setState(() {});
  }

  // Fungsi cek apakah harus auto tambah row
  void checkAutoAdd(int rowIndex, int colIndex) {
    final controller = data[rowIndex][colIndex];

    controller.addListener(() {
      final isLastRow = rowIndex == data.length - 1;
      final hasText = controller.text.trim().isNotEmpty;

      if (isLastRow && hasText) {
        // print("Auto create row...");
        addRow();
      }
    });
  }

  // ---------- build utama ----------
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
          // konten scrollable
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

                    // --- Tabel 1 (safe) ---
                    buildTableSafe(
                      headers: [
                        "SASARAN",
                        "INDIKATOR KINERJA",
                        "TARGET",
                        "FORMULASI HITUNG",
                        "SUMBER DATA",
                      ],
                      data: tabel1,
                      showNumber: true,
                    ),
                    const SizedBox(height: 12),

                    // --- Tabel Triwulan (safe) ---
                    // buildTriwulanHeader(),
                    // const SizedBox(height: 4),
                    buildTriwulanCombined(data: data, onAddRow: () => addRow()),
                    const SizedBox(height: 12),

                    // --- Tabel 3 (safe) ---
                    buildTableSafe(
                      headers: ["PROGRAM", "ANGGARAN", "KETERANGAN"],
                      data: tabel3,
                      showNumber: true,
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
