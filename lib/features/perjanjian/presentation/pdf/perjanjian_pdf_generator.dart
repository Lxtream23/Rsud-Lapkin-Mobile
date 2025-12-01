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
      (await rootBundle.load("assets/images/logo1.png")).buffer.asUint8List(),
    );

    final pdf = pw.Document();

    final pageFormat = isTriwulan
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    final fungsiList = (data["fungsi"] as List).cast<String>();
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
          pw.Center(child: pw.Image(logo, width: 90)),

          pw.SizedBox(height: 12),

          // ===========================
          // HEADER TITLE
          // ===========================
          pw.Center(
            child: pw.Text(
              "PERJANJIAN KINERJA TAHUN 2025\n"
              "${data["jabatan"]?.toUpperCase() ?? ""}\n"
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
              // ======= KIRI =========
              pw.Column(
                children: [
                  pw.Text(
                    "Direktur",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
                  ),
                  pw.SizedBox(height: 70),
                  pw.Text(
                    data["namaPihakKedua"] ?? "",
                    style: pw.TextStyle(font: poppinsBold, fontSize: 12),
                  ),
                  pw.Text(
                    "NIP. ${data["nipPihakKedua"] ?? ""}",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
                  ),
                ],
              ),

              // ======= KANAN =========
              pw.Column(
                children: [
                  pw.Text(
                    "Pasuruan, 2 Januari 2025",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
                  ),
                  pw.Text(
                    "Wadir Pelayanan",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
                  ),
                  pw.SizedBox(height: 70),
                  pw.Text(
                    data["namaPihakPertama"] ?? "",
                    style: pw.TextStyle(font: poppinsBold, fontSize: 12),
                  ),
                  pw.Text(
                    "NIP. ${data["nipPihakPertama"] ?? ""}",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 40),

          // ============================================================
          //              TABEL TAMBAHAN (opsional)
          // ============================================================
          if (table1.isNotEmpty)
            _buildTable1("TABEL 1", table1, poppinsRegular, poppinsBold),

          if (table2.isNotEmpty) pw.SizedBox(height: 20),
          if (table2.isNotEmpty)
            _buildTable("TABEL 2", table2, poppinsRegular, poppinsBold),

          if (table3.isNotEmpty) pw.SizedBox(height: 20),
          if (table3.isNotEmpty)
            _buildTable("TABEL 3", table3, poppinsRegular, poppinsBold),
        ],
      ),
    );

    return pdf;
  }

  // =============================================================
  //                    TABLE GENERATOR
  // =============================================================
  static pw.Widget _buildTable1(
    String title,
    List<List<String>> rows,
    pw.Font regular,
    pw.Font bold,
  ) {
    // Jika tidak ada data, jangan tampilkan tabel
    if (rows.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 13)),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(width: 0.8),
          columnWidths: const {
            0: pw.FixedColumnWidth(30), // NO
            1: pw.FlexColumnWidth(), // SASARAN
            2: pw.FlexColumnWidth(), // INDIKATOR KINERJA
            3: pw.FlexColumnWidth(), // SATUAN
            4: pw.FlexColumnWidth(), // TARGET
          },

          children: [
            // ====================================
            // HEADER TABEL (FIXED)
            // ====================================
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _headerCell("NO", bold),
                _headerCell("SASARAN", bold),
                _headerCell("INDIKATOR KINERJA", bold),
                _headerCell("SATUAN", bold),
                _headerCell("TARGET", bold),
              ],
            ),

            // ====================================
            // ISI TABEL
            // rows[i] = [sasaran, indikator, satuan, target]
            // ====================================
            for (int i = 0; i < rows.length; i++)
              pw.TableRow(
                children: [
                  _cell((i + 1).toString(), regular),
                  _cell(rows[i].length > 0 ? rows[i][0] : "", regular),
                  _cell(rows[i].length > 1 ? rows[i][1] : "", regular),
                  _cell(rows[i].length > 2 ? rows[i][2] : "", regular),
                  _cell(rows[i].length > 3 ? rows[i][3] : "", regular),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// ========== Helper cell untuk header ==========
  static pw.Widget _headerCell(String text, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: bold, fontSize: 11),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// ========== Helper cell untuk body ==========
  static pw.Widget _cell(String text, pw.Font regular) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(font: regular, fontSize: 11)),
    );
  }

  static pw.Widget _buildTable(
    String title,
    List<List<String>> rows,
    pw.Font regular,
    pw.Font bold,
  ) {
    if (rows.isEmpty) return pw.SizedBox();

    final header = rows.first; // <- baris pertama = header
    final dataRows = rows.skip(1).toList(); // <- sisanya = data

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 13)),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(width: 0.8),
          columnWidths: {
            for (int i = 0; i < header.length; i++)
              i: const pw.FlexColumnWidth(),
          },
          children: [
            // =======================
            //      HEADER TABLE
            // =======================
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFE0E0E0), // abu-abu header
              ),
              children: [
                for (final h in header)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      h,
                      style: pw.TextStyle(font: bold, fontSize: 11),
                    ),
                  ),
              ],
            ),

            // =======================
            //      DATA TABLE
            // =======================
            for (final row in dataRows)
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
