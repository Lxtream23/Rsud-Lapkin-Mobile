import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

// PdfFont baseFont() => PdfStandardFont(PdfFontFamily.helvetica, 10);
// PdfFont boldFont() =>
//     PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
// PdfFont headerFont() =>
//     PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
/// Load font for Syncfusion Pdf (standard font used, but we may want custom)
PdfStandardFont getStandardFontDouble({double size = 11, bool bold = false}) {
  if (bold) {
    return PdfStandardFont(
      PdfFontFamily.helvetica,
      size,
      style: PdfFontStyle.bold,
    );
  } else {
    return PdfStandardFont(PdfFontFamily.helvetica, size);
  }
}

Future<PdfFont> getPoppinsFont({double size = 11, bool bold = false}) async {
  final fontData = await rootBundle.load(
    bold ? 'assets/fonts/Poppins-Bold.ttf' : 'assets/fonts/Poppins-Regular.ttf',
  );

  List<int> fontBytes = fontData.buffer.asUint8List(
    fontData.offsetInBytes,
    fontData.lengthInBytes,
  );

  return PdfTrueTypeFont(fontBytes, size);
}
