import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PerjanjianPdfGenerator {
  static Future<pw.Document> generate({
    required Map<String, dynamic> data,
    required bool isTriwulan, // true → Landscape
  }) async {
    // ===========================
    // LOAD FONT POPPINS
    // ===========================
    final poppinsRegular = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Poppins-Regular.ttf"),
    );
    final poppinsBold = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Poppins-Bold.ttf"),
    );

    // ===========================
    // LOGO
    // ===========================
    final logo = pw.MemoryImage(
      (await rootBundle.load(
        "assets/images/logo_pemda.png",
      )).buffer.asUint8List(),
    );

    final pdf = pw.Document();

    final f4 = PdfPageFormat(210 * PdfPageFormat.mm, 330 * PdfPageFormat.mm);

    final pageFormat = isTriwulan
        ? PdfPageFormat(
            330 * PdfPageFormat.mm,
            210 * PdfPageFormat.mm,
          ) // F4 landscape
        : f4; // F4 portrait

    //final fungsiList = (data["fungsi"] as List).cast<String>();
    final table1 = (data["table1"] as List).cast<List<String>>();
    final table2 = (data["table2"] as List).cast<List<String>>();
    final table3 = (data["table3"] as List).cast<List<String>>();

    // ============================================================
    //                      PAGE CONTENT
    // ============================================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
        build: (context) => [
          // ===========================
          // LOGO
          // ===========================
          pw.Center(child: pw.Image(logo, width: 80)),

          pw.SizedBox(height: 12),

          // ===========================
          // HEADER TITLE
          // ===========================
          pw.Center(
            child: pw.Text(
              "PERJANJIAN KINERJA TAHUN 2025\n"
              "${data["jabatanPihakPertama"]?.toUpperCase() ?? ""}\n"
              "UOBK RSUD BANGIL\n"
              "KABUPATEN PASURUAN",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: poppinsBold, fontSize: 15),
            ),
          ),

          pw.SizedBox(height: 22),

          // ============================================================
          //                     PARAGRAF PEMBUKA
          // ============================================================
          pw.Text(
            "Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel "
            "serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini:",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
            textAlign: pw.TextAlign.justify,
          ),

          pw.SizedBox(height: 16),

          // ============================================================
          //                     PIHAK PERTAMA
          // ============================================================
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Nama",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
              pw.Text("   :   ", style: pw.TextStyle(font: poppinsRegular)),
              pw.Text(
                data["namaPihakPertama"] ?? "",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
            ],
          ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Jabatan",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
              pw.Text(" :   ", style: pw.TextStyle(font: poppinsRegular)),
              pw.Text(
                data["jabatanPihakPertama"] ?? "",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
            ],
          ),

          pw.Text(
            "Selanjutnya disebut pihak pertama.",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),

          pw.SizedBox(height: 14),

          // ============================================================
          //                     PIHAK KEDUA
          // ============================================================
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Nama",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
              pw.Text("   :   ", style: pw.TextStyle(font: poppinsRegular)),
              pw.Text(
                data["namaPihakKedua"] ?? "",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
            ],
          ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Jabatan",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
              pw.Text(" :   ", style: pw.TextStyle(font: poppinsRegular)),
              pw.Text(
                data["jabatan"] ?? "",
                style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
              ),
            ],
          ),

          pw.Text(
            "Selaku atasan pihak pertama, selanjutnya disebut pihak kedua.",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),

          pw.SizedBox(height: 14),

          // ============================================================
          // PARAGRAF 2
          // ============================================================
          pw.Text(
            "Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran "
            "perjanjian ini, dalam rangka mencapai target kinerja jangka menengah seperti yang telah "
            "ditetapkan dalam dokumen perencanaan. Keberhasilan dan kegagalan pencapaian target "
            "kinerja tersebut menjadi tanggung jawab kami.",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
            textAlign: pw.TextAlign.justify,
          ),

          pw.SizedBox(height: 14),

          // ============================================================
          // PARAGRAF 3
          // ============================================================
          pw.Text(
            "Pihak kedua akan melakukan evaluasi terhadap capaian kinerja dari perjanjian ini dan "
            "mengambil tindakan yang diperlukan dalam rangka pemberian penghargaan dan sanksi.",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
            textAlign: pw.TextAlign.justify,
          ),

          pw.SizedBox(height: 40),

          // ============================================================
          // TANDATANGAN (2 KOLOM)
          // ============================================================
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // =======================================================
              //                     KOLOM KIRI
              // =======================================================
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 15),
                  pw.Text(
                    data["jabatan"] ?? "",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.SizedBox(height: 8),

                  /// === TANDA TANGAN KIRI ===
                  pw.Container(
                    height: 90,
                    width: 160,
                    alignment: pw.Alignment.center,
                    // child: pw.Image(
                    //   pw.MemoryImage(
                    //     (await rootBundle.load("assets/images/ttd_kiri.png"))
                    //         .buffer
                    //         .asUint8List(),
                    //   ),
                    //   fit: pw.BoxFit.contain,
                    // ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    data["namaPihakKedua"] ?? "",
                    style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                  ),

                  pw.Text(
                    "Pembina",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.Text(
                    "NIP. ${data["nipPihakKedua"] ?? ""}",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),
                ],
              ),

              // =======================================================
              //                     KOLOM KANAN
              // =======================================================
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "Pasuruan, 2 Januari 2025",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),
                  pw.Text(
                    data["jabatanPihakPertama"] ?? "",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.SizedBox(height: 8),

                  /// === TANDA TANGAN KANAN ===
                  pw.Container(
                    height: 90,
                    width: 160,
                    alignment: pw.Alignment.center,
                    // child: pw.Image(
                    //   pw.MemoryImage(
                    //     (await rootBundle.load("assets/images/ttd_kanan.png"))
                    //         .buffer
                    //         .asUint8List(),
                    //   ),
                    //   fit: pw.BoxFit.contain,
                    // ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    data["namaPihakPertama"] ?? "",
                    style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                  ),

                  pw.Text(
                    "Pembina",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.Text(
                    "NIP. ${data["nipPihakPertama"] ?? ""}",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 40),

          // ============================================================
          //              TABEL TAMBAHAN (opsional)
          // ============================================================
          // if (table1.isNotEmpty)
          //   _buildTable1("TABEL 1", table1, poppinsRegular, poppinsBold),

          // if (table2.isNotEmpty) pw.SizedBox(height: 20),
          // if (table2.isNotEmpty)
          //   _buildTable("TABEL 2", table2, poppinsRegular, poppinsBold),

          // if (table3.isNotEmpty) pw.SizedBox(height: 20),
          // if (table3.isNotEmpty)
          //   _buildTable("TABEL 3", table3, poppinsRegular, poppinsBold),
        ],
      ),
    );

    // =============================================================
    //               HALAMAN KEDUA
    // =============================================================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.SizedBox(height: 12),

          // === TITLE DI TENGAH ===
          pw.Center(
            child: pw.Text(
              "INDIKATOR KINERJA INDIVIDU\n"
              "${data["jabatanPihakPertama"]?.toUpperCase() ?? ""}\n"
              "UOBK RSUD BANGIL\n"
              "TAHUN 2025",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: poppinsBold, fontSize: 15),
            ),
          ),

          pw.SizedBox(height: 24),
          // // ============================
          // //   JABATAN, TUGAS, FUNGSI
          // // ============================
          // pw.Text(
          //   "Jabatan:",
          //   style: pw.TextStyle(font: poppinsBold, fontSize: 12),
          // ),
          // pw.Text(
          //   data["jabatanPihakPertama"] ?? "",
          //   style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          // ),

          // pw.SizedBox(height: 12),

          // pw.Text(
          //   "Tugas:",
          //   style: pw.TextStyle(font: poppinsBold, fontSize: 12),
          // ),
          // pw.Text(
          //   data["tugas"] ?? "",
          //   style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          // ),

          // pw.SizedBox(height: 12),

          // // ======= FUNGSI (A, B, C...) =======
          // pw.Text(
          //   "Fungsi:",
          //   style: pw.TextStyle(font: poppinsBold, fontSize: 12),
          // ),

          // pw.Column(
          //   crossAxisAlignment: pw.CrossAxisAlignment.start,
          //   children: [
          //     for (int i = 0; i < fungsiList.length; i++)
          //       pw.Padding(
          //         padding: const pw.EdgeInsets.only(bottom: 4),
          //         child: pw.Text(
          //           "${String.fromCharCode(97 + i)}. ${fungsiList[i]}",
          //           style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          //         ),
          //       ),
          //   ],
          // ),

          // pw.SizedBox(height: 20),

          // === TABEL 1 ===
          if (table1.isNotEmpty)
            _buildTable1(table1, poppinsRegular, poppinsBold),

          pw.SizedBox(height: 20),

          // === TABEL 3 ===
          if (table3.isNotEmpty)
            _buildTable3(table3, poppinsRegular, poppinsBold),

          pw.SizedBox(height: 20),

          // ===========================
          //     TANDA TANGAN
          // ===========================
          pw.SizedBox(height: 40),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // =======================================================
              //                     KOLOM KIRI
              // =======================================================
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 15),
                  pw.Text(
                    data["jabatan"] ?? "",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.SizedBox(height: 8),

                  /// === TANDA TANGAN KIRI ===
                  pw.Container(
                    height: 90,
                    width: 160,
                    alignment: pw.Alignment.center,
                    // child: pw.Image(
                    //   pw.MemoryImage(
                    //     (await rootBundle.load("assets/images/ttd_kiri.png"))
                    //         .buffer
                    //         .asUint8List(),
                    //   ),
                    //   fit: pw.BoxFit.contain,
                    // ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    data["namaPihakKedua"] ?? "",
                    style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                  ),

                  pw.Text(
                    "Pembina",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.Text(
                    "NIP. ${data["nipPihakKedua"] ?? ""}",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),
                ],
              ),

              // =======================================================
              //                     KOLOM KANAN
              // =======================================================
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "Pasuruan, 2 Januari 2025",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),
                  pw.Text(
                    data["jabatanPihakPertama"] ?? "",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.SizedBox(height: 8),

                  /// === TANDA TANGAN KANAN ===
                  pw.Container(
                    height: 90,
                    width: 160,
                    alignment: pw.Alignment.center,
                    // child: pw.Image(
                    //   pw.MemoryImage(
                    //     (await rootBundle.load("assets/images/ttd_kanan.png"))
                    //         .buffer
                    //         .asUint8List(),
                    //   ),
                    //   fit: pw.BoxFit.contain,
                    // ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    data["namaPihakPertama"] ?? "",
                    style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                  ),

                  pw.Text(
                    "Pembina",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),

                  pw.Text(
                    "NIP. ${data["nipPihakPertama"] ?? ""}",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          // === TABEL 2 ===
          if (table2.isNotEmpty)
            _buildTable2(table2, poppinsRegular, poppinsBold),
        ],
      ),
    );

    return pdf;
  }

  // =============================================================
  //                    TABLE GENERATOR
  // =============================================================
  /// ========== TABEL 1 KHUSUS INDIKATOR KINERJA ==========
  static pw.Widget _buildTable1(
    //String title,
    List<List<String>> rows,
    pw.Font regular,
    pw.Font bold,
  ) {
    final headers = ["NO", "SASARAN", "INDIKATOR KINERJA", "SATUAN", "TARGET"];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // ============================
        //           TABEL
        // ============================
        pw.Table(
          border: pw.TableBorder.all(width: 0.8),

          columnWidths: {
            0: const pw.FlexColumnWidth(1), // NO
            1: const pw.FlexColumnWidth(4), // SASARAN
            2: const pw.FlexColumnWidth(5), // INDIKATOR KINERJA (paling lebar)
            3: const pw.FlexColumnWidth(2), // SATUAN
            4: const pw.FlexColumnWidth(2), // TARGET
          },

          children: [
            // =======================
            //        HEADER
            // =======================
            pw.TableRow(
              //decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                for (final h in headers)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      h,
                      style: pw.TextStyle(font: bold, fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
              ],
            ),

            // =======================
            //         DATA
            // =======================
            for (int i = 0; i < rows.length; i++)
              pw.TableRow(
                children: [
                  // NO
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "${i + 1}",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: regular, fontSize: 11),
                    ),
                  ),

                  // SASARAN
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      rows[i][0],
                      style: pw.TextStyle(font: regular, fontSize: 11),
                    ),
                  ),

                  // INDIKATOR KINERJA
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      rows[i][1],
                      style: pw.TextStyle(font: regular, fontSize: 11),
                    ),
                  ),

                  // SATUAN
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      rows[i][2],
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: regular, fontSize: 11),
                    ),
                  ),

                  // TARGET
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      rows[i][3],
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: regular, fontSize: 11),
                    ),
                  ),
                ],
              ),
          ],
        ),

        //pw.SizedBox(height: 40),
      ],
    );
  }

  /// ========== TABEL 2 KHUSUS INDIKATOR KINERJA ==========
  static pw.Widget _buildTable2(
    List<List<String>> rows,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
      child: pw.Column(
        children: [
          // =========================
          // ROW HEADER UTAMA
          // =========================
          pw.Container(
            child: pw.Row(
              children: [
                // SASARAN
                _cellHeader("Sasaran", flex: 3, bold: bold),
                // INDIKATOR KINERJA
                _cellHeader("Indikator Kinerja", flex: 3, bold: bold),
                // TARGET
                _cellHeader("Target", flex: 2, bold: bold),
                // TARGET TRIWULANAN (colspan 4)
                pw.Expanded(
                  flex: 4,
                  child: pw.Container(
                    height: 25,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(width: 1),
                        bottom: pw.BorderSide(width: 1),
                      ),
                    ),
                    child: pw.Text(
                      "Target Triwulanan",
                      style: pw.TextStyle(font: bold, fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // SUB HEADER (I, II, III, IV)
          // =========================
          pw.Row(
            children: [
              _subHeaderEmpty(flex: 3),
              _subHeaderEmpty(flex: 3),
              _subHeaderEmpty(flex: 2),

              _cellHeaderSmall("I"),
              _cellHeaderSmall("II"),
              _cellHeaderSmall("III"),
              _cellHeaderSmall("IV"),
            ],
          ),

          // =========================
          // ISI DATA
          // =========================
          for (final row in rows)
            pw.Row(
              children: [
                _cellBody(row[0], flex: 3, font: regular),
                _cellBody(row[1], flex: 3, font: regular),
                _cellBody(row[2], flex: 2, font: regular),
                _cellBody(row[3], flex: 1, font: regular),
                _cellBody(row[4], flex: 1, font: regular),
                _cellBody(row[5], flex: 1, font: regular),
                _cellBody(row[6], flex: 1, font: regular),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget _cellHeader(
    String text, {
    required int flex,
    required pw.Font bold,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: 25,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: pw.BorderSide(width: 1),
            bottom: pw.BorderSide(width: 1),
          ),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(font: bold, fontSize: 11),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static pw.Widget _cellHeaderSmall(String text) {
    return pw.Expanded(
      flex: 1,
      child: pw.Container(
        height: 30,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: pw.BorderSide(width: 1),
            bottom: pw.BorderSide(width: 1),
          ),
        ),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 11)),
      ),
    );
  }

  static pw.Widget _subHeaderEmpty({required int flex}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: 30,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: pw.BorderSide(width: 1),
            bottom: pw.BorderSide(width: 1),
          ),
        ),
      ),
    );
  }

  static pw.Widget _cellBody(
    String text, {
    required int flex,
    required pw.Font font,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border(right: pw.BorderSide(width: 1)),
        ),
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 11)),
      ),
    );
  }

  /// ========== TABEL 3 KHUSUS PROGRAM ANGGARAN KETERANGAN ==========
  static pw.Widget _buildTable3(
    List<List<String>> rows,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.8),
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // NO
        1: const pw.FlexColumnWidth(5), // PROGRAM (lebar)
        2: const pw.FlexColumnWidth(3), // ANGGARAN
        3: const pw.FlexColumnWidth(3), // KETERANGAN
      },
      children: [
        // ==============================
        //            HEADER
        // ==============================
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _tblHeader("NO", bold),
            _tblHeader("PROGRAM", bold),
            _tblHeader("ANGGARAN", bold),
            _tblHeader("KETERANGAN", bold),
          ],
        ),

        // =================================
        //             ISI DATA
        // =================================
        for (int i = 0; i < rows.length; i++)
          pw.TableRow(
            children: [
              // NO
              _tblCell("${i + 1}", regular, align: pw.TextAlign.center),

              // PROGRAM (boleh multi-line)
              _tblCell(rows[i][0], regular),

              // ANGGARAN
              _tblCell(rows[i][1], regular, align: pw.TextAlign.center),

              // KETERANGAN
              _tblCell(rows[i][2], regular, align: pw.TextAlign.center),
            ],
          ),
      ],
    );
  }

  static pw.Widget _tblHeader(String text, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: bold, fontSize: 11),
      ),
    );
  }

  static pw.Widget _tblCell(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: 11),
      ),
    );
  }

  /// ========== Helper cell untuk header ==========
  // static pw.Widget _headerCell(String text, pw.Font bold) {
  //   return pw.Padding(
  //     padding: const pw.EdgeInsets.all(6),
  //     child: pw.Text(
  //       text,
  //       style: pw.TextStyle(font: bold, fontSize: 11),
  //       textAlign: pw.TextAlign.center,
  //     ),
  //   );
  // }

  /// ========== Helper cell untuk body ==========
  // static pw.Widget _cell(String text, pw.Font regular) {
  //   return pw.Padding(
  //     padding: const pw.EdgeInsets.all(6),
  //     child: pw.Text(text, style: pw.TextStyle(font: regular, fontSize: 11)),
  //   );
  // }

  static pw.Widget _buildTable(
    String title,
    List<List<String>> rows,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 13)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(width: 0.8),
          columnWidths: {
            for (int i = 0; i < (rows.isNotEmpty ? rows[0].length : 1); i++)
              i: const pw.FlexColumnWidth(),
          },
          children: [
            // Header row (optional) — contoh bila you want header dynamic:
            // pw.TableRow(children: [ pw.TableCell(...), ... ]),
            for (final row in rows)
              pw.TableRow(
                children: [
                  for (final cell in row)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        cell,
                        style: pw.TextStyle(font: regular, fontSize: 11),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
