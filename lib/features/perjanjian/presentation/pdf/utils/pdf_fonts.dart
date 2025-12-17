import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

final Map<String, PdfFont> _fontCache = {};

Future<PdfFont> getPoppinsFont({double size = 11, bool bold = false}) async {
  final key = 'poppins_${size}_${bold ? "bold" : "regular"}';

  if (_fontCache.containsKey(key)) {
    return _fontCache[key]!;
  }

  final fontData = await rootBundle.load(
    bold ? 'assets/fonts/Poppins-Bold.ttf' : 'assets/fonts/Poppins-Regular.ttf',
  );

  final fontBytes = fontData.buffer.asUint8List(
    fontData.offsetInBytes,
    fontData.lengthInBytes,
  );

  final font = PdfTrueTypeFont(fontBytes, size);
  _fontCache[key] = font;

  return font;
}
