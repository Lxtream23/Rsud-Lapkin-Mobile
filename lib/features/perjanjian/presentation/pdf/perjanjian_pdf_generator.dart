// lib/pdf_builder/generate_perjanjian_pdf.dart
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:math';

// Pastikan file ini bisa memanggil fungsi buildTable1/buildTable2/buildTable3
// Jika Anda sudah modular: import tabel
import 'tables/table1.dart';
import 'tables/table2.dart';
import 'tables/table3.dart';

/// Generate PDF yang tahan terhadap layout dinamis.
/// signatureRightBytes: nullable — jika null, tidak ada gambar (tetap gambar garis & teks)
Future<Uint8List> generatePerjanjianPdf({
  required String namaPihak1,
  required String jabatanPihak1,
  required String namaPihak2,
  required String jabatanPihak2,
  required List<List<String>> tabel1,
  required List<List<String>> tabel2,
  required List<Map<String, dynamic>> tabel3,
  required Uint8List? signatureRightBytes,
}) async {
  final doc = PdfDocument();

  final tanggal = _formatDateShort(DateTime.now());
  // ---------------------------
  // Load Poppins fonts (TTF) dari assets
  // ---------------------------
  PdfFont poppins11, poppins11Bold, poppins14Bold;
  try {
    final reg = (await rootBundle.load(
      'assets/fonts/Poppins-Regular.ttf',
    )).buffer.asUint8List();
    final bold = (await rootBundle.load(
      'assets/fonts/Poppins-Bold.ttf',
    )).buffer.asUint8List();

    poppins11 = PdfTrueTypeFont(reg, 11);
    poppins11Bold = PdfTrueTypeFont(bold, 11);
    poppins14Bold = PdfTrueTypeFont(bold, 14);
  } catch (e) {
    // fallback ke standard font kalau gagal load
    poppins11 = PdfStandardFont(PdfFontFamily.helvetica, 11);
    poppins11Bold = PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    );
    poppins14Bold = PdfStandardFont(
      PdfFontFamily.helvetica,
      14,
      style: PdfFontStyle.bold,
    );
    print('❌ Warning: gagal load Poppins font, memakai fallback: $e');
  }

  // ---------------------------
  // Helper: buat PdfBitmap aman
  // ---------------------------
  PdfBitmap? _safeBitmap(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    try {
      return PdfBitmap(bytes);
    } catch (e) {
      print('❌ Invalid image bytes: $e');
      return null;
    }
  }

  // ---------------------------
  // Helper draw text yang mengembalikan page & y terbaru
  // selalu gunakan bounds height = 0 sehingga layout engine melakukan paginate otomatis
  // ---------------------------
  Future<Map<String, dynamic>> _drawTextElement({
    required PdfPage page,
    required String text,
    required PdfFont font,
    double left = 16,
    double top = 0,
    double width = 0, // 0 berarti full page width - 2*left
    PdfStringFormat? format,
  }) async {
    final pageWidth = page.getClientSize().width;
    final drawWidth = (width == 0) ? (pageWidth - left * 2) : width;
    final element = PdfTextElement(
      text: text,
      font: font,
      format: format ?? PdfStringFormat(),
    );
    final PdfLayoutResult? res = element.draw(
      page: page,
      bounds: Rect.fromLTWH(left, top, drawWidth, 0),
    );
    if (res == null) {
      // fallback: tidak terjadi draw (seharusnya jarang)
      return {'page': page, 'y': top};
    }
    return {'page': res.page, 'y': res.bounds.bottom};
  }

  // ---------------------------
  // Create first page and variables
  // ---------------------------
  PdfPage currentPage = doc.pages.add();
  double y = 20;
  final pageSize = currentPage.getClientSize();

  // Optional logo (cari di assets jika ada)
  try {
    final logoBytes = (await rootBundle.load(
      'assets/images/logo_pemda.png',
    )).buffer.asUint8List();
    final logoBmp = PdfBitmap(logoBytes);
    final logoW = 80.0;
    currentPage.graphics.drawImage(
      logoBmp,
      Rect.fromLTWH((pageSize.width - logoW) / 2, y, logoW, logoW),
    );
    y += 90;
  } catch (_) {
    // ignore if no logo
  }

  // ---------------------------
  // HEADER / JUDUL (multi-line, tengah)
  // gunakan drawTextElement dan perbarui page & y
  // ---------------------------
  final headerText =
      'PERJANJIAN KINERJA TAHUN ${DateTime.now().year}\n${jabatanPihak1.toUpperCase()}\nUOBK RSUD BANGIL\nKABUPATEN PASURUAN';

  final headerRes = await _drawTextElement(
    page: currentPage,
    text: headerText,
    font: poppins14Bold,
    top: y,
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );
  currentPage = headerRes['page'] as PdfPage;

  // agar jarak header → paragraf tidak melebar
  y = (headerRes['y'] as double) + 16;

  // ---------------------------
  // PARAGRAF PEMBUKA (justify)
  // ---------------------------
  final pembuka =
      'Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini:';
  final p1 = await _drawTextElement(
    page: currentPage,
    text: pembuka,
    font: poppins11,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = p1['page'] as PdfPage;
  y = p1['y'] as double;
  y += 8;

  // ---------------------------
  // PIHAK PERTAMA
  // ---------------------------
  final r1 = await _drawTextElement(
    page: currentPage,
    text: 'Nama    :  $namaPihak1',
    font: poppins11,
    top: y,
  );
  currentPage = r1['page'] as PdfPage;
  y = r1['y'] as double;
  final r2 = await _drawTextElement(
    page: currentPage,
    text: 'Jabatan :  $jabatanPihak1',
    font: poppins11,
    top: y,
  );
  currentPage = r2['page'] as PdfPage;
  y = r2['y'] as double;
  final r3 = await _drawTextElement(
    page: currentPage,
    text: 'Selanjutnya disebut pihak pertama.',
    font: poppins11,
    top: y,
  );
  currentPage = r3['page'] as PdfPage;
  y = (r3['y'] as double) + 8;

  // ---------------------------
  // PIHAK KEDUA
  // ---------------------------
  final r4 = await _drawTextElement(
    page: currentPage,
    text: 'Nama    :  $namaPihak2',
    font: poppins11,
    top: y,
  );
  currentPage = r4['page'] as PdfPage;
  y = r4['y'] as double;
  final r5 = await _drawTextElement(
    page: currentPage,
    text: 'Jabatan :  $jabatanPihak2',
    font: poppins11,
    top: y,
  );
  currentPage = r5['page'] as PdfPage;
  y = r5['y'] as double;
  final r6 = await _drawTextElement(
    page: currentPage,
    text: 'Selaku atasan pihak pertama, selanjutnya disebut pihak kedua.',
    font: poppins11,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = r6['page'] as PdfPage;
  y = (r6['y'] as double) + 8;

  // ---------------------------
  // Paragraf lanjutan
  // ---------------------------
  final par2 =
      'Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran perjanjian ini, dalam rangka mencapai target kinerja jangka menengah seperti yang telah ditetapkan dalam dokumen perencanaan.';
  final p2 = await _drawTextElement(
    page: currentPage,
    text: par2,
    font: poppins11,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = p2['page'] as PdfPage;
  y = (p2['y'] as double) + 8;

  final par3 =
      'Pihak kedua akan melakukan evaluasi terhadap capaian kinerja dari perjanjian ini dan mengambil tindakan yang diperlukan dalam rangka pemberian penghargaan dan sanksi.';
  final p3 = await _drawTextElement(
    page: currentPage,
    text: par3,
    font: poppins11,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = p3['page'] as PdfPage;
  y = (p3['y'] as double) + 18;

  // =============================
  // TANGGAL — sebelum blok TTD
  // =============================

  // ======= POSISI DASAR =======
  final pageWidth = currentPage.getClientSize().width;
  final rightX = pageWidth / 2 + 16;

  // ======= TANGGAL =======
  if (y < 250) y = 250;

  final dateResult = await _drawTextElement(
    page: currentPage,
    text: "Pasuruan, $tanggal",
    font: poppins11,
    top: y,
    left: rightX,
  );

  y = (dateResult['y'] as double) + 12;

  // Titik mulai TTD
  final double ySignatureStart = y;
  double yKiri = ySignatureStart;
  double yKanan = ySignatureStart;

  // ======================================
  //       TTD KIRI — PIHAK KEDUA
  // ======================================
  final kiriJabatan = await _drawTextElement(
    page: currentPage,
    text: jabatanPihak2,
    font: poppins11Bold,
    top: yKiri,
    left: 32,
  );

  yKiri = (kiriJabatan['y'] as double) + 60;

  final kiriNama = await _drawTextElement(
    page: currentPage,
    text: namaPihak2,
    font: poppins11Bold,
    top: yKiri,
    left: 32,
  );

  yKiri = (kiriNama['y'] as double) + 4;

  final kiriNip = await _drawTextElement(
    page: currentPage,
    text: "NIP. -",
    font: poppins11,
    top: yKiri,
    left: 32,
  );

  yKiri = (kiriNip['y'] as double) + 16;

  // ======================================
  //       TTD KANAN — PIHAK PERTAMA
  // ======================================
  final kananJabatan = await _drawTextElement(
    page: currentPage,
    text: jabatanPihak1,
    font: poppins11Bold,
    top: yKanan,
    left: rightX,
  );

  yKanan = (kananJabatan['y'] as double) + 6;

  // gambar tanda tangan jika ada
  final bmp = _safeBitmap(signatureRightBytes);
  if (bmp != null) {
    currentPage.graphics.drawImage(bmp, Rect.fromLTWH(rightX, yKanan, 120, 55));
  }

  yKanan += 60;

  final kananNama = await _drawTextElement(
    page: currentPage,
    text: namaPihak1,
    font: poppins11Bold,
    top: yKanan,
    left: rightX,
  );

  yKanan = (kananNama['y'] as double) + 4;

  final kananNip = await _drawTextElement(
    page: currentPage,
    text: "NIP. -",
    font: poppins11,
    top: yKanan,
    left: rightX,
  );

  yKanan = (kananNip['y'] as double) + 16;

  // ======= SETTING Y TERAKHIR ========
  y = max(yKiri, yKanan) + 10;

  // ---------------------------
  // HALAMAN BERIKUTNYA: gambar judul lagi lalu tabel (gunakan await buildTableX)
  // Untuk tiap tabel: draw grid and update page & y berdasarkan result
  // ---------------------------
  // PAGE untuk lampiran tabel 1 + 3
  PdfPage page2 = doc.pages.add();
  double yy = 16;
  // header page 2
  final h2res = await _drawTextElement(
    page: page2,
    text: headerText,
    font: poppins14Bold,
    top: yy,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  page2 = h2res['page'] as PdfPage;
  yy = (h2res['y'] as double) + 8;

  // build tables (builders may be async)
  final grid1 = await buildTable1(
    tabel1,
  ); // if your buildTable1 is synchronous, it's fine too
  final layout1 = grid1.draw(
    page: page2,
    bounds: Rect.fromLTWH(16, yy, page2.getClientSize().width - 32, 0),
  );
  if (layout1 != null) {
    page2 = layout1.page!;
    yy = layout1.bounds.bottom + 12;
  } else {
    yy += 12;
  }

  final grid3 = await buildTable3(tabel3);
  final layout3 = grid3.draw(
    page: page2,
    bounds: Rect.fromLTWH(16, yy, page2.getClientSize().width - 32, 0),
  );
  if (layout3 != null) {
    page2 = layout3.page!;
    yy = layout3.bounds.bottom + 12;
  }

  // PAGE berikut: tabel 2 (rencana aksi / triwulan) — buat page baru
  final page3 = doc.pages.add();
  double yy3 = 16;
  final h3res = await _drawTextElement(
    page: page3,
    text:
        'RENCANA AKSI\n${namaPihak1.toUpperCase()}\nUOBK RSUD BANGIL KABUPATEN PASURUAN\nTAHUN ${DateTime.now().year}',
    font: poppins14Bold,
    top: yy3,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  yy3 = (h3res['y'] as double) + 8;

  final grid2 = await buildTable2(tabel2);
  final layout2 = grid2.draw(
    page: page3,
    bounds: Rect.fromLTWH(16, yy3, page3.getClientSize().width - 32, 0),
  );
  if (layout2 != null) {
    yy3 = layout2.bounds.bottom + 12;
  }

  // ---------------------------
  // Finish
  // ---------------------------
  final bytes = await doc.save();
  doc.dispose();
  return Uint8List.fromList(bytes);
}

/// Simple helper format tanggal pendek
String _formatDateShort(DateTime dt) {
  // Format: 2 Januari 2025 (Indonesia)
  final months = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${dt.day} ${months[dt.month]} ${dt.year}';
}
