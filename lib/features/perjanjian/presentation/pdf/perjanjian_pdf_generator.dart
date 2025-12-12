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
  PdfFont poppins12, poppins12Bold, poppins14Bold;
  try {
    final reg = (await rootBundle.load(
      'assets/fonts/Poppins-Regular.ttf',
    )).buffer.asUint8List();
    final bold = (await rootBundle.load(
      'assets/fonts/Poppins-Bold.ttf',
    )).buffer.asUint8List();

    poppins12 = PdfTrueTypeFont(reg, 12);
    poppins12Bold = PdfTrueTypeFont(bold, 12);
    poppins14Bold = PdfTrueTypeFont(bold, 14);
  } catch (e) {
    // fallback ke standard font kalau gagal load
    poppins12 = PdfStandardFont(PdfFontFamily.helvetica, 12);
    poppins12Bold = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
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

  Future<double> _drawRowField({
    required PdfPage page,
    required double top,
    required String label,
    required String value,
    required PdfFont font,
  }) async {
    const double labelX = 16;
    const double colonX = 140;
    const double valueX = 150;

    // label
    await _drawTextElement(
      page: page,
      text: label,
      font: font,
      top: top,
      left: labelX,
    );

    // colon
    await _drawTextElement(
      page: page,
      text: ":",
      font: font,
      top: top,
      left: colonX,
    );

    // value
    final res = await _drawTextElement(
      page: page,
      text: value,
      font: font,
      top: top,
      left: valueX,
    );

    return res['y'] as double;
  }

  // ---------------------------
  // Create first page and variables
  // ---------------------------
  PdfPage currentPage = doc.pages.add();
  double y = 20; // posisi awal dari atas
  final pageSize = currentPage.getClientSize();

  // ---------------------------
  // LOGO
  // ---------------------------
  try {
    final logoBytes = (await rootBundle.load(
      'assets/images/logo_pemda.png',
    )).buffer.asUint8List();

    final logoBmp = PdfBitmap(logoBytes);
    final logoW = 80.0;

    // Gambar logo
    currentPage.graphics.drawImage(
      logoBmp,
      Rect.fromLTWH((pageSize.width - logoW) / 2, y, logoW, logoW),
    );

    // -------------------------------
    // JARAK LOGO → HEADER (atur disini)
    // -------------------------------
    const double spacingLogoToHeader = 10; // Ubah sesuka kamu (5/10/15/20)
    y += logoW + spacingLogoToHeader;
  } catch (_) {}

  // ---------------------------
  // HEADER / JUDUL (multi-line, tengah)
  // gunakan drawTextElement dan perbarui page & y
  // ---------------------------
  final headerText =
      'PEMERINTAH KABUPATEN PASURUAN\n PERJANJIAN KINERJA TAHUN ${DateTime.now().year}\nUOBK RSUD BANGIL';

  final headerRes = await _drawTextElement(
    page: currentPage,
    text: headerText,
    font: poppins14Bold,
    top: y,
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.top,
    ),
  );
  currentPage = headerRes['page'] as PdfPage;

  // agar jarak header → paragraf tidak melebar
  y = (headerRes['y'] as double) + 20;

  // ---------------------------
  // PARAGRAF PEMBUKA (justify)
  // ---------------------------
  final pembuka =
      'Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini:';
  final p1 = await _drawTextElement(
    page: currentPage,
    text: pembuka,
    font: poppins12,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = p1['page'] as PdfPage;
  y = p1['y'] as double;
  y += 10;

  // ---------------------------
  // PIHAK PERTAMA
  // ---------------------------

  // Nama
  y = await _drawRowField(
    page: currentPage,
    top: y,
    label: "Nama",
    value: namaPihak1,
    font: poppins12,
  );

  // Jabatan
  y = await _drawRowField(
    page: currentPage,
    top: y,
    label: "Jabatan",
    value: jabatanPihak1,
    font: poppins12,
  );

  // Kalimat lanjutan
  final r3 = await _drawTextElement(
    page: currentPage,
    text: 'Selanjutnya disebut pihak pertama.',
    font: poppins12,
    top: y,
  );
  currentPage = r3['page'] as PdfPage;
  y = (r3['y'] as double) + 10;

  // ---------------------------
  // PIHAK KEDUA
  // ---------------------------

  // Nama
  y = await _drawRowField(
    page: currentPage,
    top: y,
    label: "Nama",
    value: namaPihak2,
    font: poppins12,
  );

  // Jabatan
  y = await _drawRowField(
    page: currentPage,
    top: y,
    label: "Jabatan",
    value: jabatanPihak2,
    font: poppins12,
  );

  // Kalimat lanjutan
  final r6 = await _drawTextElement(
    page: currentPage,
    text: 'Selaku atasan pihak pertama, selanjutnya disebut pihak kedua.',
    font: poppins12,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = r6['page'] as PdfPage;
  y = (r6['y'] as double) + 10;

  // ---------------------------
  // Paragraf lanjutan
  // ---------------------------
  final par2 =
      'Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran perjanjian ini, dalam rangka mencapai target kinerja jangka menengah seperti yang telah ditetapkan dalam dokumen perencanaan.';
  final p2 = await _drawTextElement(
    page: currentPage,
    text: par2,
    font: poppins12,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = p2['page'] as PdfPage;
  y = (p2['y'] as double) + 10;

  final par3 =
      'Pihak kedua akan melakukan evaluasi terhadap capaian kinerja dari perjanjian ini dan mengambil tindakan yang diperlukan dalam rangka pemberian penghargaan dan sanksi.';
  final p3 = await _drawTextElement(
    page: currentPage,
    text: par3,
    font: poppins12,
    top: y,
    format: PdfStringFormat(alignment: PdfTextAlignment.justify),
  );
  currentPage = p3['page'] as PdfPage;
  y = (p3['y'] as double) + 20;

  // =============================
  //       TANGGAL + BLOK TTD
  // =============================

  // posisi dasar
  final double pageWidth = currentPage.getClientSize().width;
  // Sesuaikan dengan margin paragraf atas
  const double marginLeft = 20.0;
  const double marginRight = 40.0;
  const double colWidth = 180.0; // ukuran pas dan rapi

  final double rightX = pageWidth - marginRight - colWidth;

  // pastikan Y tidak terlalu dekat paragraf, tetapi JANGAN pakai if(y < 250)
  y += 12;

  // ======================================
  //               TANGGAL
  // ======================================
  final dateRes = await _drawTextElement(
    page: currentPage,
    text: "Pasuruan, $tanggal",
    font: poppins12,
    top: y,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );

  currentPage = dateRes['page'] as PdfPage;
  y = (dateRes['y'] as double) + 18;

  // ======================================
  //             SETUP KOORDINAT
  // ======================================
  double yKiri = y;
  double yKanan = y;

  // halaman final untuk tanda tangan (untuk cegah gambar muncul di halaman salah)
  PdfPage pageForSignature = currentPage;

  // ======================================
  //    KOLOM KIRI – PIHAK KEDUA
  // ======================================

  final kiriJabatan = await _drawTextElement(
    page: pageForSignature,
    text: "PIHAK KEDUA",
    font: poppins12Bold,
    top: yKiri,
    left: marginLeft,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  pageForSignature = kiriJabatan['page'] as PdfPage;
  yKiri = (kiriJabatan['y'] as double) + 60;

  final kiriNama = await _drawTextElement(
    page: pageForSignature,
    text: namaPihak2,
    font: poppins12Bold,
    top: yKiri,
    left: marginLeft,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  pageForSignature = kiriNama['page'] as PdfPage;
  yKiri = (kiriNama['y'] as double) + 4;

  final kiriNip = await _drawTextElement(
    page: pageForSignature,
    text: "NIP. -",
    font: poppins12,
    top: yKiri,
    left: marginLeft,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  pageForSignature = kiriNip['page'] as PdfPage;
  yKiri = (kiriNip['y'] as double) + 16;

  // ======================================
  //    KOLOM KANAN – PIHAK PERTAMA
  // ======================================

  final kananJabatan = await _drawTextElement(
    page: pageForSignature,
    text: "PIHAK PERTAMA",
    font: poppins12Bold,
    top: yKanan,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  pageForSignature = kananJabatan['page'] as PdfPage;
  yKanan = (kananJabatan['y'] as double) + 6;

  // gambar tanda tangan tepat di kolom kanan
  final bmp = _safeBitmap(signatureRightBytes);
  if (bmp != null) {
    pageForSignature.graphics.drawImage(
      bmp,
      Rect.fromLTWH(rightX + (colWidth - 120) / 2, yKanan, 120, 55),
    );
  }

  yKanan += 60;

  final kananNama = await _drawTextElement(
    page: pageForSignature,
    text: namaPihak1,
    font: poppins12Bold,
    top: yKanan,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  pageForSignature = kananNama['page'] as PdfPage;
  yKanan = (kananNama['y'] as double) + 4;

  final kananNip = await _drawTextElement(
    page: pageForSignature,
    text: "NIP. -",
    font: poppins12,
    top: yKanan,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  pageForSignature = kananNip['page'] as PdfPage;
  yKanan = (kananNip['y'] as double) + 16;

  // update Y akhir halaman
  y = (yKiri > yKanan ? yKiri : yKanan) + 10;

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
