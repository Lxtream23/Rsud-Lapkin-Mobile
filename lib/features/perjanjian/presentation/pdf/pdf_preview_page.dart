import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final Uint8List bytes;

  const PdfPreviewPage({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,

      appBar: AppBar(
        title: const Text(
          "Preview PDF",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),

      body: Container(
        color: Colors.grey.shade300, // background luar
        child: PdfPreview(
          build: (format) => bytes,

          // --- Setting rekomendasi preview modern ---
          canChangeOrientation: false,
          canChangePageFormat: false,
          allowPrinting: true,
          allowSharing: true,
          useActions: true,

          // --- Background area preview ---
          scrollViewDecoration: BoxDecoration(color: Colors.grey.shade300),

          // --- Background kertas PDF ---
          pdfPreviewPageDecoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
