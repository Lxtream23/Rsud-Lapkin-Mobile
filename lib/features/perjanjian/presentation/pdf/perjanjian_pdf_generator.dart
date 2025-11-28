import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PerjanjianPdfGenerator {
  static Future<pw.Document> generate({
    required Map<String, dynamic> data,
    required bool isTriwulan, // true → Landscape
  }) async {
    // LOAD FONT POPPINS
    final poppinsRegular = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Poppins-Regular.ttf"),
    );
    final poppinsBold = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Poppins-Bold.ttf"),
    );

    final pdf = pw.Document();

    final pageFormat = isTriwulan
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    final fungsiList = (data["fungsi"] as List).cast<String>();
    final table1 = (data["table1"] as List).cast<List<String>>();
    final table2 = (data["table2"] as List).cast<List<String>>();
    final table3 = (data["table3"] as List).cast<List<String>>();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          //
          // ============================
          //          HEADER TITLE
          // ============================
          pw.Center(
            child: pw.Text(
              "PERJANJIAN KINERJA TAHUN 2025\nUOBK RSUD BANGIL",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: poppinsBold, fontSize: 16),
            ),
          ),

          pw.SizedBox(height: 24),

          //
          // ============================
          //  DATA NAMA & JABATAN
          // ============================
          pw.Text(
            "PIHAK PERTAMA:",
            style: pw.TextStyle(font: poppinsBold, fontSize: 13),
          ),
          pw.Text(
            data["namaPihakPertama"] ?? "",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),
          pw.Text(
            data["jabatanPihakPertama"] ?? "",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),
          pw.SizedBox(height: 10),

          pw.Text(
            "PIHAK KEDUA:",
            style: pw.TextStyle(font: poppinsBold, fontSize: 13),
          ),
          pw.Text(
            data["namaPihakKedua"] ?? "",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),
          pw.Text(
            data["jabatan"] ?? "",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),

          pw.SizedBox(height: 20),

          //
          // ============================
          //   JABATAN, TUGAS, FUNGSI
          // ============================
          pw.Text(
            "Jabatan:",
            style: pw.TextStyle(font: poppinsBold, fontSize: 12),
          ),
          pw.Text(
            data["jabatan"] ?? "",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),

          pw.SizedBox(height: 12),

          pw.Text(
            "Tugas:",
            style: pw.TextStyle(font: poppinsBold, fontSize: 12),
          ),
          pw.Text(
            data["tugas"] ?? "",
            style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
          ),

          pw.SizedBox(height: 12),

          //
          // ======= FUNGSI (A, B, C...) =======
          pw.Text(
            "Fungsi:",
            style: pw.TextStyle(font: poppinsBold, fontSize: 12),
          ),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < fungsiList.length; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    "${String.fromCharCode(97 + i)}. ${fungsiList[i]}",
                    style: pw.TextStyle(font: poppinsRegular, fontSize: 12),
                  ),
                ),
            ],
          ),

          pw.SizedBox(height: 20),

          //
          // ============================
          //       TABLE 1
          // ============================
          if (table1.isNotEmpty)
            _buildTable("TABEL 1", table1, poppinsRegular, poppinsBold),

          pw.SizedBox(height: 20),

          //
          // ============================
          //       TABLE 2
          // ============================
          if (table2.isNotEmpty)
            _buildTable("TABEL 2", table2, poppinsRegular, poppinsBold),

          pw.SizedBox(height: 20),

          //
          // ============================
          //       TABLE 3
          // ============================
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
            for (int i = 0; i < rows[0].length; i++)
              i: const pw.FlexColumnWidth(),
          },
          children: [
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
