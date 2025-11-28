import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final Uint8List bytes;

  const PdfPreviewPage({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview PDF")),
      body: PdfPreview(
        build: (format) => bytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
        scrollViewDecoration: BoxDecoration(color: Colors.grey.shade200),
      ),
    );
  }
}
