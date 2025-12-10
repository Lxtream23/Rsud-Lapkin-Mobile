import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfAssetsLoader {
  static Future<PdfBitmap> loadLogo() async {
    final data = await rootBundle.load("assets/images/logo.png");
    return PdfBitmap(data.buffer.asUint8List());
  }

  static Future<PdfBitmap> loadTtdKiri() async {
    final data = await rootBundle.load("assets/images/ttd_kiri.png");
    return PdfBitmap(data.buffer.asUint8List());
  }

  static Future<PdfBitmap> loadTtdKanan() async {
    final data = await rootBundle.load("assets/images/ttd_kanan.png");
    return PdfBitmap(data.buffer.asUint8List());
  }
}
