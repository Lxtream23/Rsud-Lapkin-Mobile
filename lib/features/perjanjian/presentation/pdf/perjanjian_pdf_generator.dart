import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;

import 'tables/table1.dart';
import 'tables/table2.dart';
import 'tables/table3.dart';

Future<Uint8List> generatePerjanjianPdf({
  required String namaPihak1,
  required String jabatanPihak1,
  required String namaPihak2,
  required String jabatanPihak2,
  required List<List<String>> tabel1,
  required List<List<String>> tabel2,
  required List<Map<String, dynamic>> tabel3,
  required Uint8List? signatureRightBytes, // ← hanya tanda tangan kanan
  bool isTriwulan = false,
}) async {
  final doc = PdfDocument();

  // Load logo (optional)
  PdfBitmap? logo;
  try {
    final bytes = (await rootBundle.load(
      'assets/images/logo_pemda.png',
    )).buffer.asUint8List();
    logo = PdfBitmap(bytes);
  } catch (_) {
    logo = null;
  }

  final titleFont = PdfStandardFont(
    PdfFontFamily.helvetica,
    14,
    style: PdfFontStyle.bold,
  );
  final normalFont = PdfStandardFont(PdfFontFamily.helvetica, 11);

  PdfBitmap? safeBitmap(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    try {
      return PdfBitmap(bytes);
    } catch (e) {
      print("❌ Invalid signature image: $e");
      return null;
    }
  }

  // ============================
  // PAGE 1
  // ============================
  final page1 = doc.pages.add();
  final pageBounds = page1.getClientSize();
  double y = 0;

  // Logo
  if (logo != null) {
    final logoWidth = 80.0;
    page1.graphics.drawImage(
      logo,
      Rect.fromLTWH(
        (pageBounds.width - logoWidth) / 2,
        y + 8,
        logoWidth,
        logoWidth,
      ),
    );
    y += 90;
  } else {
    y += 20;
  }

  // Title
  final title =
      'PERJANJIAN KINERJA TAHUN 2025\n${jabatanPihak1.toUpperCase()}\nUOBK RSUD BANGIL\nKABUPATEN PASURUAN';

  PdfTextElement(
    text: title,
    font: titleFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(
    page: page1,
    bounds: Rect.fromLTWH(0, y, pageBounds.width, double.infinity),
  );

  y += 70;

  // ========== PARAGRAF PEMBUKA ==========
  y = _drawParagraph(
    page: page1,
    text:
        'Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini:',
    y: y,
    font: normalFont,
    width: pageBounds.width,
  );

  // ========== PIHAK PERTAMA ==========
  y = _drawLine(page1, 'Nama                :  $namaPihak1', y, normalFont);
  y = _drawLine(page1, 'Jabatan             :  $jabatanPihak1', y, normalFont);
  y = _drawLine(page1, 'Selanjutnya disebut pihak pertama.', y, normalFont) + 8;

  // ========== PIHAK KEDUA ==========
  y = _drawLine(page1, 'Nama                :  $namaPihak2', y, normalFont);
  y = _drawLine(page1, 'Jabatan             :  $jabatanPihak2', y, normalFont);
  y =
      _drawLine(
        page1,
        'Selaku atasan pihak pertama, selanjutnya disebut pihak kedua.',
        y,
        normalFont,
      ) +
      20;

  // ========== PARAGRAF 2 ==========
  y = _drawParagraph(
    page: page1,
    text:
        'Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran perjanjian ini, dalam rangka mencapai target kinerja jangka menengah seperti yang telah ditetapkan dalam dokumen perencanaan. Keberhasilan dan kegagalan pencapaian target kinerja tersebut menjadi tanggung jawab kami. ',
    y: y,
    font: normalFont,
    width: pageBounds.width,
  );

  // ========== PARAGRAF 3 ==========
  y = _drawParagraph(
    page: page1,
    text:
        'Pihak kedua akan melakukan evaluasi terhadap capaian kinerja dari perjanjian ini dan mengambil tindakan yang diperlukan dalam rangka pemberian penghargaan dan sanksi. ',
    y: y,
    font: normalFont,
    width: pageBounds.width,
  );

  // ============================
  // TANDA TANGAN
  // ============================
  final colWidth = (pageBounds.width - 40) / 2;
  final leftX = 20.0;
  final rightX = leftX + colWidth;

  final signY = y + 20;

  // ===============================
  // KOLOM KIRI (PIHAK KEDUA)
  // = TIDAK ADA GAMBAR (TTD KOSONG)
  // ===============================
  PdfTextElement(
    text: jabatanPihak2,
    font: normalFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(page: page1, bounds: Rect.fromLTWH(leftX, signY, colWidth, 20));

  // TTD KOSONG
  PdfTextElement(
    text: "TTD KOSONG",
    font: PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.italic,
    ),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(page: page1, bounds: Rect.fromLTWH(leftX, signY + 40, colWidth, 20));

  // Garis tanda tangan kiri
  final lineYLeft = signY + 40 + 26;
  page1.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(leftX + 20, lineYLeft),
    Offset(leftX + colWidth - 20, lineYLeft),
  );

  // Nama pejabat kiri
  PdfTextElement(
    text: namaPihak2,
    font: PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    ),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(
    page: page1,
    bounds: Rect.fromLTWH(leftX, lineYLeft + 6, colWidth, 20),
  );

  PdfTextElement(
    text: "Pembina",
    font: normalFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(
    page: page1,
    bounds: Rect.fromLTWH(leftX, lineYLeft + 22, colWidth, 20),
  );

  // ===============================
  // KOLOM KANAN (PIHAK PERTAMA)
  // = AMBIL TTD SUPABASE
  // ===============================

  // Tanggal + jabatan
  PdfTextElement(
    text: "Pasuruan, 2 Januari 2025",
    font: normalFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(page: page1, bounds: Rect.fromLTWH(rightX, signY, colWidth, 20));

  PdfTextElement(
    text: jabatanPihak1,
    font: normalFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(page: page1, bounds: Rect.fromLTWH(rightX, signY + 18, colWidth, 20));

  final sigW = 140.0;
  final sigH = 70.0;

  // GAMBAR SUPABASE (AMAN)
  final rightBmp = safeBitmap(signatureRightBytes);

  // Jika tersedia, gambar
  if (rightBmp != null) {
    page1.graphics.drawImage(
      rightBmp,
      Rect.fromLTWH(rightX + (colWidth - sigW) / 2, signY + 44, sigW, sigH),
    );
  }

  // Garis tanda tangan kanan
  final lineYRight = signY + 44 + sigH + 8;
  page1.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(rightX + 20, lineYRight),
    Offset(rightX + colWidth - 20, lineYRight),
  );

  // Nama pejabat kanan
  PdfTextElement(
    text: namaPihak1,
    font: PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    ),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(
    page: page1,
    bounds: Rect.fromLTWH(rightX, lineYRight + 6, colWidth, 20),
  );

  PdfTextElement(
    text: "Pembina",
    font: normalFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(
    page: page1,
    bounds: Rect.fromLTWH(rightX, lineYRight + 22, colWidth, 20),
  );

  // ============================
  // PAGE 2 – TABLE 1 + TABLE 3
  // ============================
  final page2 = doc.pages.add();
  final size2 = page2.getClientSize();
  double yy = 16;

  PdfTextElement(
    text:
        'PERJANJIAN KINERJA TAHUN 2025\n${jabatanPihak1.toUpperCase()}\nUOBK RSUD BANGIL\nKABUPATEN PASURUAN',
    font: titleFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(page: page2, bounds: Rect.fromLTWH(0, yy, size2.width, 20));

  yy += 30;

  final g1 = await buildTable1(tabel1);
  final r1 = g1.draw(
    page: page2,
    bounds: Rect.fromLTWH(16, yy, size2.width - 32, 0),
  );
  yy += (r1?.bounds?.height ?? 0) + 16;

  final g3 = await buildTable3(tabel3); // ✔ perlu await
  final r3 = g3.draw(
    page: page2,
    bounds: Rect.fromLTWH(16, yy, size2.width - 32, 0),
  );
  yy += (r3?.bounds?.height ?? 0) + 16;

  // ============================
  // PAGE 3 – TABLE 2
  // ============================
  final page3 = doc.pages.add();
  final size3 = page3.getClientSize();
  double yy3 = 16;

  PdfTextElement(
    text:
        'RENCANA AKSI \n${namaPihak1.toUpperCase()}\nUOBK RSUD BANGIL KABUPATEN PASURUAN \nTAHUN 2025',
    font: titleFont,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  ).draw(page: page3, bounds: Rect.fromLTWH(0, yy3, size3.width, 20));

  yy3 += 30;

  final g2 = await buildTable2(tabel2);
  g2.draw(page: page3, bounds: Rect.fromLTWH(16, yy3, size3.width - 32, 0));

  final bytes = await doc.save();
  doc.dispose();
  return Uint8List.fromList(bytes);
}

/// Helper untuk menggambar paragraf justify + auto height
double _drawParagraph({
  required PdfPage page,
  required String text,
  required double y,
  required PdfFont font,
  required double width,
}) {
  final element = PdfTextElement(
    text: text,
    font: font,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  final result = element.draw(
    page: page,
    bounds: Rect.fromLTWH(0, y, width, double.infinity),
  );
  return result!.bounds.bottom + 12;
}

/// Helper untuk menggambar single line teks
double _drawLine(PdfPage page, String text, double y, PdfFont font) {
  PdfTextElement(text: text, font: font).draw(
    page: page,
    bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20),
  );
  return y + 18;
}
