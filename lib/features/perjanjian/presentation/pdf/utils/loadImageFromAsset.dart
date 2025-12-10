import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Load image bytes from assets and convert to PdfBitmap
Future<PdfBitmap?> loadImageFromAsset(String assetPath) async {
  try {
    final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
    return PdfBitmap(bytes);
  } catch (e) {
    // return null jika gagal load (caller harus cek)
    return null;
  }
}

Future<Uint8List?> loadSignatureFromSupabase(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
  } catch (e) {
    print("❌ Gagal load TTD dari Supabase: $e");
  }
  return null;
}
