import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generatePerjanjianPdf({
  required String namaPihak1,
  required String jabatanPihak1,
  required String namaPihak2,
  required String jabatanPihak2,
  required List<List<String>> tabel1,
  required List<List<String>> tabel2,
  required List<List<String>> tabel3,
  bool isTriwulan = false, // Added parameter with default value
}) async {
  final pdf = pw.Document();
  final f4 = PdfPageFormat(210 * PdfPageFormat.mm, 330 * PdfPageFormat.mm);

  final pageFormat = isTriwulan
      ? PdfPageFormat(
          330 * PdfPageFormat.mm,
          210 * PdfPageFormat.mm,
        ) // F4 landscape
      : f4; // F4 portrait

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
  // ===========================
  final ttd_kanan = pw.MemoryImage(
    (await rootBundle.load("assets/images/ttd_kanan.jpg")).buffer.asUint8List(),
  );

  final ttd_kiri = pw.MemoryImage(
    (await rootBundle.load("assets/images/ttd_kiri.jpg")).buffer.asUint8List(),
  );

  // ===========================
  pw.Widget buildTable(List<List<String>> data) {
    if (data.isEmpty) {
      return pw.Text(
        "Tabel kosong",
        style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.8),
      columnWidths: {
        for (int i = 0; i < data.first.length; i++)
          i: const pw.FlexColumnWidth(),
      },
      children: [
        for (int r = 0; r < data.length; r++)
          pw.TableRow(
            decoration: r == 0
                ? pw.BoxDecoration(color: PdfColors.grey300)
                : null,
            children: [
              for (int c = 0; c < data[r].length; c++)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    data[r][c],
                    textAlign: c == 0 ? pw.TextAlign.center : pw.TextAlign.left,
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // Helper cell builder
  pw.Widget buildCenteredCell(String text, pw.TextStyle style) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
    );
  }

  // ===========================
  // TABEL 1
  // ===========================
  pw.Widget buildTable1(List<List<String>> rows) {
    pw.TextStyle headerStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      font: poppinsBold,
    );

    pw.TextStyle cellStyle = pw.TextStyle(fontSize: 12, font: poppinsRegular);

    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // NO
        1: const pw.FlexColumnWidth(), // SASARAN
        2: const pw.FlexColumnWidth(), // INDIKATOR
        3: const pw.FixedColumnWidth(60), // SATUAN
        4: const pw.FixedColumnWidth(60), // TARGET
      },
      children: [
        // ---------- HEADER ----------
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            buildCenteredCell("NO", headerStyle),
            buildCenteredCell("SASARAN", headerStyle),
            buildCenteredCell("INDIKATOR KINERJA", headerStyle),
            buildCenteredCell("SATUAN", headerStyle),
            buildCenteredCell("TARGET", headerStyle),
          ],
        ),

        // ---------- DATA ROWS ----------
        ...List.generate(rows.length, (i) {
          final r = rows[i];

          return pw.TableRow(
            children: [
              buildCenteredCell("${i + 1}", cellStyle),
              buildCenteredCell(r[0], cellStyle),
              buildCenteredCell(r[1], cellStyle),
              buildCenteredCell(r[2], cellStyle),
              buildCenteredCell(r[3], cellStyle),
            ],
          );
        }),
      ],
    );
  }

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
            "${jabatanPihak1.toUpperCase()}\n"
            "UOBK RSUD BANGIL\n"
            "KABUPATEN PASURUAN",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: poppinsBold, fontSize: 14),
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
              namaPihak1,
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
              jabatanPihak1,
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
              namaPihak2,
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
              jabatanPihak2,
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
                  jabatanPihak2,
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.SizedBox(height: 8),

                /// === TANDA TANGAN KIRI ===
                pw.Container(
                  height: 90,
                  width: 160,
                  alignment: pw.Alignment.center,
                  // Use the preloaded ttd_kanan image instead of loading it again with await
                  child: pw.Image(ttd_kiri, fit: pw.BoxFit.contain),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  namaPihak2,
                  style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                ),

                pw.Text(
                  "Pembina",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.Text(
                  "NIP. ",
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
                  jabatanPihak1,
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.SizedBox(height: 8),

                /// === TANDA TANGAN KANAN ===
                pw.Container(
                  height: 90,
                  width: 160,
                  alignment: pw.Alignment.center,
                  // Use the preloaded ttd_kanan image instead of loading it again with await
                  child: pw.Image(ttd_kanan, fit: pw.BoxFit.contain),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  namaPihak1,
                  style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                ),

                pw.Text(
                  "Pembina",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.Text(
                  "NIP.",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 40),
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
            "PERJANJIAN KINERJA TAHUN 2025\n"
            "${jabatanPihak1.toUpperCase()}\n"
            "UOBK RSUD BANGIL\n"
            "KABUPATEN PASURUAN",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: poppinsBold, fontSize: 15),
          ),
        ),

        pw.SizedBox(height: 24),

        // ===========================
        // TABEL 1
        // ===========================
        pw.Text("TABEL SASARAN", style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 8),
        buildTable1(tabel1),
        pw.SizedBox(height: 20),

        // ===========================
        // TABEL 3
        // ===========================
        pw.Text("TABEL PROGRAM & ANGGARAN", style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 8),
        buildTable(tabel3),
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
                  jabatanPihak2,
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.SizedBox(height: 8),

                /// === TANDA TANGAN KIRI ===
                pw.Container(
                  height: 90,
                  width: 160,
                  alignment: pw.Alignment.center,
                  // Use the preloaded ttd_kanan image instead of loading it again with await
                  child: pw.Image(ttd_kiri, fit: pw.BoxFit.contain),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  namaPihak2,
                  style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                ),

                pw.Text(
                  "Pembina",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.Text(
                  "NIP. ",
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
                  jabatanPihak1,
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.SizedBox(height: 8),

                /// === TANDA TANGAN KANAN ===
                pw.Container(
                  height: 90,
                  width: 160,
                  alignment: pw.Alignment.center,
                  // Use the preloaded ttd_kanan image instead of loading it again with await
                  child: pw.Image(ttd_kanan, fit: pw.BoxFit.contain),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  namaPihak1,
                  style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                ),

                pw.Text(
                  "Pembina",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.Text(
                  "NIP.",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  // =============================================================
  //               HALAMAN KETIGA
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
            "RENCANA AKSI\n"
            "${namaPihak1.toUpperCase()}\n"
            "UOBK RSUD BANGIL KABUPATEN PASURUAN\n"
            "TAHUN 2025",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: poppinsBold, fontSize: 15),
          ),
        ),
        pw.SizedBox(height: 24),
        // ===========================
        // TABEL 3
        // ===========================
        pw.Text("TABEL TRIWULAN", style: pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 8),
        buildTable(tabel2),
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
                  jabatanPihak2,
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.SizedBox(height: 8),

                /// === TANDA TANGAN KIRI ===
                pw.Container(
                  height: 90,
                  width: 160,
                  alignment: pw.Alignment.center,
                  // Use the preloaded ttd_kanan image instead of loading it again with await
                  child: pw.Image(ttd_kiri, fit: pw.BoxFit.contain),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  namaPihak2,
                  style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                ),

                pw.Text(
                  "Pembina",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.Text(
                  "NIP. ",
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
                  jabatanPihak1,
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.SizedBox(height: 8),

                /// === TANDA TANGAN KANAN ===
                pw.Container(
                  height: 90,
                  width: 160,
                  alignment: pw.Alignment.center,
                  // Use the preloaded ttd_kanan image instead of loading it again with await
                  child: pw.Image(ttd_kanan, fit: pw.BoxFit.contain),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  namaPihak1,
                  style: pw.TextStyle(font: poppinsBold, fontSize: 11),
                ),

                pw.Text(
                  "Pembina",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),

                pw.Text(
                  "NIP.",
                  style: pw.TextStyle(font: poppinsRegular, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
  return pdf.save();
}

  // pw.Widget buildHeader() {
  //   return pw.Column(
  //     children: [
  //       pw.Image(logo, height: 70),
  //       pw.SizedBox(height: 8),
  //       pw.Text(
  //         "PERJANJIAN KINERJA TAHUN 2025",
  //         style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
  //       ),
  //       pw.Text(
  //         "KEPALA BIDANG PELAYANAN MEDIK\nUOBK RSUD BANGIL\nKABUPATEN PASURUAN",
  //         textAlign: pw.TextAlign.center,
  //         style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
  //       ),
  //     ],
  //   );
  // }

  // --------------------------------------------------------
  // PAGE 1
  // --------------------------------------------------------
  // pdf.addPage(
  //   pw.Page(
  //     pageFormat: PdfPageFormat.a4,
  //     build: (ctx) => pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         buildHeader(),
  //         pw.SizedBox(height: 20),

  //         pw.Text(
  //           "Dalam rangka mewujudkan manajemen pemerintahan yang efektif...",
  //           textAlign: pw.TextAlign.justify,
  //           style: pw.TextStyle(fontSize: 11),
  //         ),
  //         pw.SizedBox(height: 15),

  //         pw.Text("Nama : $namaPihak1", style: pw.TextStyle(fontSize: 11)),
  //         pw.Text(
  //           "Jabatan : $jabatanPihak1",
  //           style: pw.TextStyle(fontSize: 11),
  //         ),
  //         pw.Text("Selanjutnya disebut pihak pertama.\n"),

  //         pw.Text("Nama : $namaPihak2", style: pw.TextStyle(fontSize: 11)),
  //         pw.Text(
  //           "Jabatan : $jabatanPihak2",
  //           style: pw.TextStyle(fontSize: 11),
  //         ),
  //         pw.Text(
  //           "Selaku atasan pihak pertama, selanjutnya disebut pihak kedua.\n",
  //         ),

  //         pw.Text(
  //           "Pihak pertama berjanji akan mewujudkan target kinerja...",
  //           textAlign: pw.TextAlign.justify,
  //           style: pw.TextStyle(fontSize: 11),
  //         ),

  //         pw.Spacer(),

  //         pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //           children: [
  //             pw.Column(
  //               children: [
  //                 pw.Text("Wadir Pelayanan"),
  //                 pw.SizedBox(height: 40),
  //                 pw.Text(namaPihak2),
  //                 pw.Text("NIP."),
  //               ],
  //             ),
  //             pw.Column(
  //               children: [
  //                 pw.Text("Pasuruan, 2 Januari 2025\nKabid Pelayanan Medik"),
  //                 pw.SizedBox(height: 40),
  //                 pw.Text(namaPihak1),
  //                 pw.Text("NIP."),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   ),
  // );

  // // --------------------------------------------------------
  // // PAGE 2 (TABEL 1 & 2)
  // // --------------------------------------------------------
  // pdf.addPage(
  //   pw.Page(
  //     pageFormat: PdfPageFormat.a4,
  //     build: (ctx) => pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         buildHeader(),
  //         pw.SizedBox(height: 10),

  //         pw.Text("TABEL SASARAN", style: pw.TextStyle(fontSize: 12)),
  //         pw.SizedBox(height: 8),
  //         buildTable(tabel1),
  //         pw.SizedBox(height: 18),

  //         pw.Text(
  //           "TABEL PROGRAM & ANGGARAN",
  //           style: pw.TextStyle(fontSize: 12),
  //         ),
  //         pw.SizedBox(height: 8),
  //         buildTable(tabel3),
  //         pw.SizedBox(height: 18),

  //         pw.Text("TABEL TRIWULAN", style: pw.TextStyle(fontSize: 12)),
  //         pw.SizedBox(height: 8),
  //         buildTable(tabel2),
  //         pw.SizedBox(height: 20),

  //         pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //           children: [
  //             pw.Column(
  //               children: [
  //                 pw.Text("Wadir Pelayanan"),
  //                 pw.SizedBox(height: 40),
  //                 pw.Text(namaPihak2),
  //                 pw.Text("NIP."),
  //               ],
  //             ),
  //             pw.Column(
  //               children: [
  //                 pw.Text("Pasuruan, 2 Januari 2025\nKabid Pelayanan Medik"),
  //                 pw.SizedBox(height: 40),
  //                 pw.Text(namaPihak1),
  //                 pw.Text("NIP."),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   ),
  // );

  // // --------------------------------------------------------
  // // PAGE 3 (TABEL 3)
  // // --------------------------------------------------------
  // pdf.addPage(
  //   pw.Page(
  //     pageFormat: PdfPageFormat.a4,
  //     build: (ctx) => pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         pw.Text(
  //           "RENCANA AKSI\n$namaPihak1\n$jabatanPihak1\nTAHUN 2025",
  //           textAlign: pw.TextAlign.center,
  //           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
  //         ),
  //         pw.SizedBox(height: 20),

  //         buildTable(tabel3),

  //         pw.Spacer(),

  //         pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //           children: [
  //             pw.Column(
  //               children: [
  //                 pw.Text("Wadir Pelayanan"),
  //                 pw.SizedBox(height: 40),
  //                 pw.Text(namaPihak2),
  //                 pw.Text("NIP."),
  //               ],
  //             ),
  //             pw.Column(
  //               children: [
  //                 pw.Text("Pasuruan, 2 Januari 2025\nKabid Pelayanan Medik"),
  //                 pw.SizedBox(height: 40),
  //                 pw.Text(namaPihak1),
  //                 pw.Text("NIP."),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   ),
  // );

