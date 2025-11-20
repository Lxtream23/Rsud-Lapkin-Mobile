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
  // --- PASTE / REPLACE buildTriwulanCombined dengan ini ---
  Widget buildTriwulanCombined({
    required List<List<TextEditingController>> data,
    required VoidCallback onAddRow,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar yang tersedia; fallback ke width layar jika tidak finite.
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // FIXED column widths (sesuaikan angka jika ingin lebih sempit/lebar)
        // Ini memastikan layout terlihat sama pada berbagai device (scroll muncul bila perlu)
        final List<double> fixed = [
          240, // SASARAN
          240, // INDIKATOR KINERJA
          120, // TARGET
          90, // I
          90, // II
          90, // III
          90, // IV
        ];

        // Jika availableWidth lebih besar daripada jumlah fixed, kita bisa scale sedikit
        final totalFixed = fixed.reduce((a, b) => a + b);
        final scale = (availableWidth > totalFixed)
            ? (availableWidth / totalFixed)
            : 1.0;
        final columnWidths = fixed.map((w) => w * scale).toList();
        final minTotalWidth = columnWidths.fold<double>(0, (s, w) => s + w);

        Widget headerCell(
          String text, {
          required double w,
          required double h,
          bool drawBottom = true,
          bool drawTop = true,
        }) {
          return Container(
            width: w,
            height: h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border(
                top: drawTop
                    ? BorderSide(color: Colors.black, width: 1)
                    : BorderSide.none,
                left: BorderSide(color: Colors.black, width: 1),
                right: BorderSide(color: Colors.black, width: 1),
                bottom: drawBottom
                    ? BorderSide(color: Colors.black, width: 1)
                    : BorderSide.none,
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }

        Widget emptyCell(
          double w,
          double h, {
          bool drawTop = true,
          bool drawBottom = true,
        }) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border(
                top: drawTop
                    ? BorderSide(color: Colors.black, width: 1)
                    : BorderSide.none,
                left: BorderSide(color: Colors.black, width: 1),
                right: BorderSide(color: Colors.black, width: 1),
                bottom: drawBottom
                    ? BorderSide(color: Colors.black, width: 1)
                    : BorderSide.none,
              ),
            ),
          );
        }

        Widget dataCell(TextEditingController controller, double w) {
          return Container(
            width: w,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.black, width: 1),
                right: BorderSide(color: Colors.black, width: 1),
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                // pemanggilan onAddRow diserahkan dari pemanggil
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minTotalWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROW 1: SASARAN | INDIKATOR | TARGET | TARGET TRIWULAN(spans 4 cols)
                // =============== ROW 1 ===============
                // SASARAN | INDIKATOR | TARGET | TARGET TRIWULAN (merged visual)
                Row(
                  children: [
                    headerCell(
                      "SASARAN",
                      w: columnWidths[0],
                      h: 70,
                      drawBottom: false,
                    ),
                    headerCell(
                      "INDIKATOR KINERJA",
                      w: columnWidths[1],
                      h: 70,
                      drawBottom: false,
                    ),
                    headerCell(
                      "TARGET",
                      w: columnWidths[2],
                      h: 70,
                      drawBottom: false,
                    ),

                    // 4 kolom header triwulan (merged secara visual)
                    for (int i = 0; i < 4; i++)
                      Container(
                        width: columnWidths[i + 3],
                        height: 70, // separuh tinggi
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border(
                            top: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            bottom: BorderSide.none,
                            left: i == 0
                                ? const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  )
                                : BorderSide.none,
                            right: i == 3
                                ? const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        child:
                            (i ==
                                1) // kolom kedua dipakai sebagai posisi teks tengah
                            ? const Text(
                                "TARGET TRIWULAN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                  ],
                ),

                // =============== ROW 2 ===============
                // Subheader I–IV
                Row(
                  children: [
                    emptyCell(columnWidths[0], 35, drawTop: false),
                    emptyCell(columnWidths[1], 35, drawTop: false),
                    emptyCell(columnWidths[2], 35, drawTop: false),

                    for (int i = 0; i < 4; i++)
                      Container(
                        width: columnWidths[i + 3],
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: const Border(
                            top: BorderSide(color: Colors.black, width: 1),
                            left: BorderSide(color: Colors.black, width: 1),
                            right: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Text(
                          ["I", "II", "III", "IV"][i],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),

                // DATA ROWS: gunakan Row per data row supaya alignment persis sesuai header widths
                for (int r = 0; r < data.length; r++)
                  Row(
                    children: [
                      // Pastikan setiap row memiliki 7 controller (jika kurang, isi dulu di caller)
                      for (int c = 0; c < 7; c++)
                        SizedBox(
                          width: columnWidths[c],
                          child: GestureDetector(
                            // agar tap pada textfield bisa memicu addRow di pemanggil (boleh disesuaikan)
                            onTap: () {
                              if (r == data.length - 1) onAddRow();
                            },
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
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
                                onChanged: (v) {
                                  if (r == data.length - 1 &&
                                      v.trim().isNotEmpty) {
                                    onAddRow();
                                  }
                                },
                              ),
                            ),
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

  // ================= WIDGET BANTUAN =================

  final boxHeader = BoxDecoration(
    border: Border.all(color: Colors.black),
    color: Colors.grey.shade300,
  );

  Widget _headerCell(String text, double width, {double height = 60}) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: boxHeader,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyHeader(double width) {
    return Container(
      width: width,
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _subHeader(String text, double width) {
    return Container(
      width: width,
      height: 35,
      alignment: Alignment.center,
      decoration: boxHeader,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Helper header widget
  Widget headerBox(String text, double width, double height) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.grey.shade200,
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
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
