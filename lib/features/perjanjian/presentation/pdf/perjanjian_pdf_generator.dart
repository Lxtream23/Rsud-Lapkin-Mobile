// lib/pdf_builder/generate_perjanjian_pdf.dart
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:math';

// Pastikan file ini bisa memanggil fungsi buildTable1/buildTable2/buildTable3
// Jika Anda sudah modular: import tabel
import 'tables_view/table1.dart';
import 'tables_view/table2.dart';
import 'tables_view/table3.dart';
import 'tables_view/table4.dart';

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
  required List<Map<String, dynamic>> tabel4,
  required Uint8List? signatureRightBytes,

  String? pangkatPihak1,
  String? pangkatPihak2,
  required String tugasDetail,
  required List<String> fungsiList,
  required nipPihak1,

  //required nipPihak2,
}) async {
  final doc = PdfDocument();
  // Set ukuran F4 / Folio
  //doc.pageSettings.size = const Size(609.45, 935.43);

  final tanggal = _formatDateShort(DateTime.now());
  // ---------------------------
  // Load Poppins fonts (TTF) dari assets
  // ---------------------------
  PdfFont poppins12, poppins12Bold, poppins14Bold;
  PdfFont poppins10, poppins10Bold;
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

    poppins10 = PdfTrueTypeFont(reg, 10);
    poppins10Bold = PdfTrueTypeFont(bold, 10);
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
    poppins10 = PdfStandardFont(PdfFontFamily.helvetica, 10);
    poppins10Bold = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
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
    double width = 0, // 0 = full width (page - left - rightMargin)
    double rightMargin = 16, // 🔥 baru
    PdfStringFormat? format,
  }) async {
    final pageWidth = page.getClientSize().width;

    final drawWidth = (width == 0) ? (pageWidth - left - rightMargin) : width;

    final element = PdfTextElement(
      text: text,
      font: font,
      format:
          format ??
          PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.top,
            wordWrap: PdfWordWrapType.word,
          ),
    );

    final PdfLayoutResult? res = element.draw(
      page: page,
      bounds: Rect.fromLTWH(left, top, drawWidth, 0),
    );

    if (res == null) {
      return {'page': page, 'y': top};
    }

    return {'page': res.page, 'y': res.bounds.bottom};
  }

  void _drawTextStatic({
    required PdfPage page,
    required String text,
    required PdfFont font,
    required double top,
    double left = 0,
  }) {
    page.graphics.drawString(
      text,
      font,
      bounds: Rect.fromLTWH(left, top, 400, 20),
    );
  }

  // helper: gambar satu bullet dengan hanging indent
  Future<double> _drawBulletParagraph({
    required PdfPage page,
    required double top,
    required double markerX, // posisi "a."
    required double textX, // posisi awal teks (setelah marker)
    required double pageRightMargin, // margin kanan halaman (mis. 40)
    required String marker, // "a."
    required String text, // isi bullet
    required PdfFont font,
  }) async {
    // Lebar area teks = dari textX sampai pageWidth - rightMargin
    final pageWidth = page.getClientSize().width;
    final double textWidth = pageWidth - pageRightMargin - textX;

    // gambar marker (a.)
    await _drawTextElement(
      page: page,
      text: marker,
      font: font,
      top: top,
      left: markerX,
      // beri sedikit width agar method tidak crash, tapi marker kecil
      width: 30,
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );

    // gambar isi paragraf di kolom teks dengan width yang jelas
    final res = await _drawTextElement(
      page: page,
      text: text,
      font: font,
      top: top,
      left: textX,
      width: textWidth,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        wordWrap: PdfWordWrapType.word,
      ),
    );

    // kembalikan Y akhir
    return res['y'] as double;
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

  //===========================================================================
  // === SECTION 1 : PORTRAIT (Halaman 1 dan Halaman 2) ===
  final sectionPortrait = doc.sections!.add();
  sectionPortrait.pageSettings.size = const Size(609.45, 935.43); // F4 / Folio
  sectionPortrait.pageSettings.orientation = PdfPageOrientation.portrait;

  //===========================================================================
  // Halaman 1
  //===========================================================================
  PdfPage currentPage = sectionPortrait.pages.add();

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
  // CEK RUANG UNTUK BLOK TTD (HALAMAN 1)
  // =============================
  const double ttdBlockHeight = 190; // estimasi aman (judul + nama + ttd)
  final double pageHeight = currentPage.getClientSize().height;

  // beri jarak aman dari paragraf terakhir
  y += 12;

  // jika tidak cukup ruang → pindah halaman
  if (y + ttdBlockHeight > pageHeight - 20) {
    currentPage = sectionPortrait.pages.add();
    y = 20;
  }

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
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  currentPage = dateRes['page'] as PdfPage;
  y = (dateRes['y'] as double) + 6;

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
    font: poppins12,
    top: yKiri,
    left: marginLeft,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
  pageForSignature = kiriJabatan['page'] as PdfPage;
  yKiri = (kiriJabatan['y'] as double) + 60;

  final kiriNama = await _drawTextElement(
    page: pageForSignature,
    text: namaPihak2,
    font: poppins12,
    top: yKiri,
    left: marginLeft,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  pageForSignature = kiriNama['page'] as PdfPage;
  yKiri = (kiriNama['y'] as double) + 4;

  // --- Garis bawah mengikuti panjang nama pihak kedua ---
  final double namaWidthKiri = poppins12.measureString(namaPihak2).width;

  // garis PAS di bawah teks
  pageForSignature.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(marginLeft, yKiri - 2),
    Offset(marginLeft + namaWidthKiri, yKiri - 2),
  );

  // --- Tambahkan PANGKAT Pihak Kedua
  final kiriPangkat = await _drawTextElement(
    page: pageForSignature,
    text: pangkatPihak2 ?? "-",
    font: poppins12,
    top: yKiri,
    left: marginLeft,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
  pageForSignature = kiriPangkat['page'] as PdfPage;
  yKiri = (kiriPangkat['y'] as double) + 6;

  // --- NIP
  final kiriNip = await _drawTextElement(
    page: pageForSignature,
    text: "NIP. -",
    font: poppins12,
    top: yKiri,
    left: marginLeft,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
  pageForSignature = kiriNip['page'] as PdfPage;
  yKiri = (kiriNip['y'] as double) + 16;

  // ======================================
  //    KOLOM KANAN – PIHAK PERTAMA
  // ======================================

  final kananJabatan = await _drawTextElement(
    page: pageForSignature,
    text: "PIHAK PERTAMA",
    font: poppins12,
    top: yKanan,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
  pageForSignature = kananJabatan['page'] as PdfPage;
  yKanan = (kananJabatan['y'] as double) + 6;

  // Gambar tanda tangan
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
    font: poppins12,
    top: yKanan,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  pageForSignature = kananNama['page'] as PdfPage;
  yKanan = (kananNama['y'] as double) + 4;

  // --- Garis bawah mengikuti panjang nama pihak pertama ---
  final double namaWidthKanan = poppins12.measureString(namaPihak1).width;

  // garis PAS mengikuti teks
  pageForSignature.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(rightX, yKanan - 2),
    Offset(rightX + namaWidthKanan, yKanan - 2),
  );

  // --- PANGKAT PIHAK PERTAMA
  final kananPangkat = await _drawTextElement(
    page: pageForSignature,
    text: pangkatPihak1 ?? "-",
    font: poppins12,
    top: yKanan,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
  pageForSignature = kananPangkat['page'] as PdfPage;
  yKanan = (kananPangkat['y'] as double) + 4;

  // --- NIP
  final kananNip = await _drawTextElement(
    page: pageForSignature,
    text: 'NIP : ${nipPihak1 ?? '-'}',
    font: poppins12,
    top: yKanan,
    left: rightX,
    width: colWidth,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  pageForSignature = kananNip['page'] as PdfPage;
  yKanan = (kananNip['y'] as double) + 16;

  // update Y akhir halaman
  y = (yKiri > yKanan ? yKiri : yKanan) + 10;

  //===========================================================================
  //       HALAMAN 2
  //===========================================================================

  final PdfPage page2 = sectionPortrait.pages.add();

  double yy = 16;
  double Right2 = 16;
  const double tableSpacing = 32;

  // ================= HEADER =================
  final h2res = await _drawTextElement(
    page: page2,
    text:
        "INDIKATOR KINERJA INDIVIDU\nUOBK RSUD BANGIL\nTAHUN ${DateTime.now().year}",
    font: poppins14Bold,
    top: yy,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );

  yy = (h2res['y'] as double) + 20;

  // ================= BLOK INFO =================
  final double labelLeft = 16.0;
  final double colonX = 110.0;
  final double valueX = 125.0;

  // Jabatan
  await _drawTextElement(
    page: page2,
    text: "Jabatan",
    font: poppins12,
    top: yy,
    left: labelLeft,
  );

  _drawTextStatic(
    page: page2,
    text: ":",
    font: poppins12,
    top: yy,
    left: colonX,
  );

  final jabVal = await _drawTextElement(
    page: page2,
    text: jabatanPihak1,
    font: poppins12,
    top: yy,
    left: valueX,
  );

  yy = jabVal['y'] + 2;

  // Tugas
  await _drawTextElement(
    page: page2,
    text: "Tugas",
    font: poppins12,
    top: yy,
    left: labelLeft,
  );

  _drawTextStatic(
    page: page2,
    text: ":",
    font: poppins12,
    top: yy,
    left: colonX,
  );

  final tgVal = await _drawTextElement(
    page: page2,
    text: tugasDetail,
    font: poppins12,
    top: yy,
    left: valueX,
    rightMargin: Right2,
    format: PdfStringFormat(
      alignment: PdfTextAlignment.left,
      wordWrap: PdfWordWrapType.word,
    ),
  );

  yy = tgVal['y'] + 2;

  // ================= FUNGSI =================
  await _drawTextElement(
    page: page2,
    text: "Fungsi",
    font: poppins12,
    top: yy,
    left: labelLeft,
  );

  await _drawTextElement(
    page: page2,
    text: ":",
    font: poppins12,
    top: yy,
    left: colonX,
  );

  final double pageWidth2 = page2.getClientSize().width;
  final double contentRight2 = pageWidth2 - 16;

  final double markerX2 = valueX;
  final double markerWidth2 = 20;
  final double textX2 = markerX2 + markerWidth2;
  final double textWidth2 = contentRight2 - textX2;

  for (int i = 0; i < fungsiList.length; i++) {
    final huruf = String.fromCharCode(97 + i);

    final markerRes = PdfTextElement(text: "$huruf.", font: poppins12).draw(
      page: page2,
      bounds: Rect.fromLTWH(markerX2, yy, markerWidth2, double.infinity),
    )!;

    final isiRes =
        PdfTextElement(
          text: fungsiList[i],
          font: poppins12,
          format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            wordWrap: PdfWordWrapType.word,
          ),
        ).draw(
          page: page2,
          bounds: Rect.fromLTWH(
            textX2,
            markerRes.bounds.top,
            textWidth2,
            double.infinity,
          ),
        )!;

    yy = max(markerRes.bounds.bottom, isiRes.bounds.bottom) + 6;
  }

  yy += 20;

  // ================= TABEL =================
  final grid1 = buildTable1(tabel1, poppins10, poppins10Bold);
  final layout1 = grid1.draw(
    page: page2,
    bounds: Rect.fromLTWH(16, yy, pageWidth - 32, 0),
  );

  if (layout1 != null) {
    yy = layout1.bounds.bottom + tableSpacing;
  }

  final grid3 = buildTable3(tabel3, poppins10, poppins10Bold);
  final layout3 = grid3.draw(
    page: page2,
    bounds: Rect.fromLTWH(16, yy, pageWidth - 32, 0),
  );

  PdfPage lastTablePage2 = page2;

  if (layout3 != null) {
    lastTablePage2 = layout3.page; // ✅ HALAMAN AKHIR TABEL
    yy = layout3.bounds.bottom + tableSpacing;
  }

  //===========================================================================
  //       FINAL BLOK TTD (AUTO FOLLOW TABEL) — FINAL FIX
  //===========================================================================

  PdfPage ttdPage2 = lastTablePage2;
  double yTTD2 = yy + 24;

  const double ttdHeight2 = 240;
  final double pageHeight2 = ttdPage2.getClientSize().height;

  // jika tidak muat → halaman baru
  if (yTTD2 + ttdHeight2 > pageHeight2 - 20) {
    ttdPage2 = sectionPortrait.pages.add();
    yTTD2 = 20;
  }

  // ================= SETUP =================
  final double pageW2 = ttdPage2.getClientSize().width;
  const double colW2 = 180;
  const double leftX2 = 20;
  final double rightX2 = pageW2 - 40 - colW2;

  // ================= TANGGAL =================
  final dateRes2 = await _drawTextElement(
    page: ttdPage2,
    text: "Pasuruan, $tanggal",
    font: poppins12,
    top: yTTD2,
    left: rightX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  double yKiri2 = (dateRes2['y'] as double) + 8;
  double yKanan2 = yKiri2;

  // ===================================================
  // PIHAK KEDUA (KIRI)
  // ===================================================
  final kiriLabel2 = await _drawTextElement(
    page: ttdPage2,
    text: "PIHAK KEDUA",
    font: poppins12,
    top: yKiri2,
    left: leftX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKiri2 = (kiriLabel2['y'] as double) + 60;

  final kiriNama2 = await _drawTextElement(
    page: ttdPage2,
    text: namaPihak2,
    font: poppins12,
    top: yKiri2,
    left: leftX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKiri2 = (kiriNama2['y'] as double) + 4;

  // --- Garis bawah mengikuti panjang nama (LEFT ALIGN) ---
  final double namaWidthKiri2 = poppins12.measureString(namaPihak2).width;

  ttdPage2.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(leftX2, yKiri2 - 2),
    Offset(leftX2 + namaWidthKiri2, yKiri2 - 2),
  );

  // pangkat
  final kiriPangkat2 = await _drawTextElement(
    page: ttdPage2,
    text: pangkatPihak2 ?? "-",
    font: poppins12,
    top: yKiri2,
    left: leftX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKiri2 = (kiriPangkat2['y'] as double) + 4;

  // nip
  final kiriNip2 = await _drawTextElement(
    page: ttdPage2,
    text: "NIP. -",
    font: poppins12,
    top: yKiri2,
    left: leftX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKiri2 = (kiriNip2['y'] as double) + 16;

  // ===================================================
  // PIHAK PERTAMA (KANAN)
  // ===================================================
  final kananLabel2 = await _drawTextElement(
    page: ttdPage2,
    text: "PIHAK PERTAMA",
    font: poppins12,
    top: yKanan2,
    left: rightX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKanan2 = (kananLabel2['y'] as double) + 8;

  // tanda tangan
  final bmp2 = _safeBitmap(signatureRightBytes);
  if (bmp2 != null) {
    ttdPage2.graphics.drawImage(
      bmp2,
      Rect.fromLTWH(rightX2 + (colW2 - 120) / 2, yKanan2, 120, 55),
    );
  }

  yKanan2 += 60;

  final kananNama2 = await _drawTextElement(
    page: ttdPage2,
    text: namaPihak1,
    font: poppins12,
    top: yKanan2,
    left: rightX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKanan2 = (kananNama2['y'] as double) + 4;

  // --- Garis bawah mengikuti panjang nama (LEFT ALIGN) ---
  final double namaWidthKanan2 = poppins12.measureString(namaPihak1).width;

  ttdPage2.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(rightX2, yKanan2 - 2),
    Offset(rightX2 + namaWidthKanan2, yKanan2 - 2),
  );

  // pangkat
  final kananPangkat2 = await _drawTextElement(
    page: ttdPage2,
    text: pangkatPihak1 ?? "-",
    font: poppins12,
    top: yKanan2,
    left: rightX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKanan2 = (kananPangkat2['y'] as double) + 4;

  // nip
  await _drawTextElement(
    page: ttdPage2,
    text: 'NIP : ${nipPihak1 ?? '-'}',
    font: poppins12,
    top: yKanan2,
    left: rightX2,
    width: colW2,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );
  // update yy akhir halaman
  yy = (yKiri2 > yKanan2 ? yKiri2 : yKanan2) + 10;

  //===========================================================================
  // SECTION 2: Landscape
  final sectionLandscape = doc.sections!.add();
  sectionLandscape.pageSettings.size = const Size(609.45, 935.43);
  sectionLandscape.pageSettings.orientation = PdfPageOrientation.landscape;
  //===========================================================================
  // Halaman 3
  //===========================================================================
  final PdfPage page3 = sectionLandscape.pages.add();

  double yy3 = 16;

  //const double tableSpacing = 32; // mengatur jarak antar tabel

  final h3res = await _drawTextElement(
    page: page3,
    text:
        'RENCANA AKSI\n${namaPihak1.toUpperCase()}\nUOBK RSUD BANGIL KABUPATEN PASURUAN\nTAHUN ${DateTime.now().year}',
    font: poppins14Bold,
    top: yy3,
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );

  yy3 = (h3res['y'] as double) + 8;

  // --- TABEL 2 ---
  final grid2 = buildTable2(tabel2, poppins10, poppins10Bold);

  final layout2 = grid2.draw(
    page: page3,
    bounds: Rect.fromLTWH(16, yy3, page3.getClientSize().width - 32, 0),
  );

  if (layout2 != null) {
    yy3 = layout2.bounds.bottom + tableSpacing;
  } else {
    yy3 += tableSpacing;
  }

  // --- TABEL 4 ---
  final grid4 = buildTable4(tabel4, poppins10, poppins10Bold);

  final layout4 = grid4.draw(
    page: page3,
    bounds: Rect.fromLTWH(16, yy3, page3.getClientSize().width - 32, 0),
  );

  PdfPage lastTablePage3 = page3;

  if (layout4 != null) {
    lastTablePage3 = layout4.page;
    yy3 = layout4.bounds.bottom + tableSpacing;
  }

  //===========================================================================
  //       FINAL BLOK TTD (AUTO FOLLOW TABEL) — FINAL FIX
  //===========================================================================

  PdfPage ttdPage3 = lastTablePage3;
  double yTTD3 = yy3 + 24;

  const double ttdHeight3 = 240;
  final double pageHeight3 = ttdPage3.getClientSize().height;

  // jika tidak muat → halaman baru
  if (yTTD3 + ttdHeight3 > pageHeight3 - 20) {
    ttdPage3 = sectionLandscape.pages.add();
    yTTD3 = 20;
  }

  // ================= SETUP =================
  final double pageW3 = ttdPage3.getClientSize().width;
  const double colW3 = 180;
  const double leftX3 = 20;
  final double rightX3 = pageW3 - 40 - colW3;
  // =============================
  // TANGGAL
  // =============================
  final dateRes3 = await _drawTextElement(
    page: ttdPage3,
    text: "Pasuruan, $tanggal",
    font: poppins12,
    top: yTTD3,
    left: leftX3,
    width: colW3,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  double yKiri3 = (dateRes3['y'] as double) + 8;
  double yKanan3 = yKiri3;
  // =============================

  // tanda tangan
  final bmp3 = _safeBitmap(signatureRightBytes);
  if (bmp3 != null) {
    ttdPage3.graphics.drawImage(
      bmp3,
      Rect.fromLTWH(leftX3 + (colW3 - 120) / 2, yKiri3, 120, 55),
    );
  }

  yKiri3 += 60;

  final kiriNama3 = await _drawTextElement(
    page: ttdPage3,
    text: namaPihak1,
    font: poppins12,
    top: yKiri3,
    left: leftX3,
    width: colW3,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKiri3 = (kiriNama3['y'] as double) + 4;

  // ukur lebar nama (PASTI SAMA)
  final double namaWidthKiri3 = poppins12.measureString(namaPihak1).width;

  // garis bawah PERSIS di bawah teks
  ttdPage3.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(leftX3, yKiri3 - 2),
    Offset(leftX3 + namaWidthKiri3, yKiri3 - 2),
  );

  // pangkat
  final kiriPangkat3 = await _drawTextElement(
    page: ttdPage3,
    text: pangkatPihak1 ?? "-",
    font: poppins12,
    top: yKiri3,
    left: leftX3,
    width: colW3,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKiri3 = (kiriPangkat3['y'] as double) + 4;

  // nip
  final kiriNip3 = await _drawTextElement(
    page: ttdPage3,
    text: 'NIP : ${nipPihak1 ?? '-'}',
    font: poppins12,
    top: yKiri3,
    left: leftX3,
    width: colW3,
    format: PdfStringFormat(alignment: PdfTextAlignment.left),
  );

  yKiri3 = (kiriNip3['y'] as double) + 16;
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
