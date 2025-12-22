import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfPreviewPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final Future<void> Function() onSave;
  final bool isSaved;
  final String status; // Proses / Disetujui / Ditolak

  const PdfPreviewPage({
    super.key,
    required this.pdfBytes,
    required this.onSave,
    required this.status,
    this.isSaved = false,
  });

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool _saving = false;
  bool _darkMode = false;

  bool _zoomed = false;
  double _zoomLevel = 1.0;

  final TransformationController _transformController =
      TransformationController();

  // ===================== INIT =====================
  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('pdf_dark_mode') ?? false;
    });
  }

  Future<void> _toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _darkMode = !_darkMode);
    await prefs.setBool('pdf_dark_mode', _darkMode);
  }

  // ===================== DOUBLE TAP ZOOM =====================
  void _onDoubleTap(TapDownDetails details) {
    final position = details.localPosition;

    setState(() {
      if (_zoomed) {
        _transformController.value = Matrix4.identity();
        _zoomLevel = 1.0;
      } else {
        _transformController.value = Matrix4.identity()
          ..translate(-position.dx * 1.5, -position.dy * 1.5)
          ..scale(2.5);
        _zoomLevel = 2.5;
      }
      _zoomed = !_zoomed;
    });
  }

  // ===================== STATUS COLOR =====================
  Color _statusColor() {
    switch (widget.status) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _darkMode ? Colors.black : Colors.grey.shade100,

      // ===================== APP BAR =====================
      appBar: AppBar(
        backgroundColor: _darkMode ? Colors.black : Colors.white,
        foregroundColor: _darkMode ? Colors.white : Colors.black,
        elevation: 0.6,
        centerTitle: true,
        title: const Text(
          'Preview Perjanjian',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),

      // ===================== BODY =====================
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Column(
          children: [
            // ===== STATUS + PAGE + ZOOM =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge(widget.status, _statusColor()),
                Text(
                  'Halaman PDF',
                  style: TextStyle(
                    fontSize: 12,
                    color: _darkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  'Zoom ${(_zoomLevel * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _darkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ===== INFO READ ONLY =====
            if (widget.isSaved)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, size: 18, color: Colors.orange),
                    SizedBox(width: 6),
                    Text(
                      'Dokumen bersifat read-only',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

            // ===== PDF VIEW =====
            Expanded(
              child: Stack(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GestureDetector(
                      onDoubleTapDown: _onDoubleTap,
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 1,
                        maxScale: 4,
                        child: PdfPreview(
                          build: (format) => widget.pdfBytes,
                          allowPrinting: true,
                          allowSharing: false,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                        ),
                      ),
                    ),
                  ),

                  // ===== WATERMARK READ ONLY =====
                  if (widget.isSaved)
                    IgnorePointer(
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.4,
                          child: Text(
                            'READ ONLY',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ===================== ACTION =====================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: widget.isSaved
                ? const Icon(Icons.check)
                : _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              widget.isSaved
                  ? 'Sudah disimpan'
                  : _saving
                  ? 'Menyimpan...'
                  : 'Simpan',
            ),
            onPressed: widget.isSaved || _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    try {
                      await widget.onSave();
                      if (context.mounted) Navigator.pop(context);
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== BADGE =====================
  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
