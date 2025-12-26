import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/form_perjanjian_page.dart';

class PdfPreviewPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final Future<void> Function() onSave;
  final bool isSaved; // true = view only
  final String status;
  final String? perjanjianId;

  const PdfPreviewPage({
    super.key,
    required this.pdfBytes,
    required this.onSave,
    required this.status,
    this.isSaved = false,
    this.perjanjianId,
  });

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool _saving = false;
  bool _darkMode = false;
  bool _focusMode = false;
  bool _pdfReady = false;

  bool _zoomed = false;
  double _zoomLevel = 1.0;

  final TransformationController _transformController =
      TransformationController();

  ui.Image? _watermarkLogo;

  bool get _canEdit => widget.status == 'Proses' || widget.status == 'Ditolak';

  bool get _canDownload => widget.status == 'Disetujui';

  // ===================== INIT =====================
  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    _loadWatermarkLogo();

    // Skeleton delay (aman & smooth)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _pdfReady = true);
      }
    });
  }

  // ===================== DARK MODE =====================
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

  // ===================== FOCUS MODE =====================
  void _toggleFocusMode() {
    setState(() => _focusMode = !_focusMode);

    SystemChrome.setEnabledSystemUIMode(
      _focusMode ? SystemUiMode.immersive : SystemUiMode.edgeToEdge,
    );
  }

  // ===================== WATERMARK =====================
  Future<void> _loadWatermarkLogo() async {
    final data = await rootBundle.load('assets/images/logo_pemda.png');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 120,
    );
    final frame = await codec.getNextFrame();
    setState(() => _watermarkLogo = frame.image);
  }

  // ===================== EDIT =====================
  Future<void> _logEditAction() async {
    if (widget.perjanjianId == null) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('perjanjian_audit_log').insert({
      'perjanjian_id': widget.perjanjianId,
      'user_id': user.id,
      'aksi': 'EDIT_REQUEST',
      'keterangan': 'User membuka dokumen untuk diedit',
    });
  }

  Future<void> _confirmEdit() async {
    debugPrint('perjanjianId: ${widget.perjanjianId}');
    if (widget.perjanjianId == null) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Dokumen'),
        content: const Text(
          'Dokumen akan dibuka dalam mode edit.\n'
          'Pastikan data yang diubah sudah benar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _logEditAction();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FormPerjanjianPage(
            mode: FormMode.edit,
            perjanjianId: widget.perjanjianId!, // 🔥 ID kunci
          ),
        ),
      );
    }
  }

  // ===================== DOWNLOAD =====================
  Future<void> _showProgressDialog(String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf() async {
    await _showProgressDialog('Mengunduh PDF...');

    try {
      await Printing.sharePdf(
        bytes: widget.pdfBytes,
        filename: 'Perjanjian_Kinerja.pdf',
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;

    Navigator.pop(context); // tutup progress dialog

    await _showSuccessDialog('PDF berhasil diunduh');
  }

  // ===================== ZOOM =====================
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
    debugPrint('PREVIEW OPENED: ${widget.pdfBytes.length}');

    return Scaffold(
      backgroundColor: _darkMode ? Colors.black : Colors.grey.shade100,
      // ===== APP BAR =====
      appBar: _focusMode
          ? null
          : AppBar(
              backgroundColor: _darkMode ? Colors.black : Colors.white,
              foregroundColor: _darkMode ? Colors.white : Colors.black,
              elevation: 0.6,
              title: Text(
                'Preview Perjanjian',
                style: AppTextStyle.bold16.copyWith(
                  color: _darkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              actions: [
                // ===== EDIT ↔ DOWNLOAD (ANIMATED) =====
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: _canEdit
                      ? IconButton(
                          key: const ValueKey('edit'),
                          tooltip: 'Edit Perjanjian',
                          icon: const Icon(Icons.edit),
                          onPressed: _confirmEdit,
                        )
                      : _canDownload
                      ? IconButton(
                          key: const ValueKey('download'),
                          tooltip: 'Download PDF',
                          icon: const Icon(Icons.download),
                          onPressed: _downloadPdf,
                        )
                      : const SizedBox.shrink(),
                ),

                // ===== FOCUS MODE =====
                IconButton(
                  tooltip: 'Mode Fokus',
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFocusMode,
                ),

                // ===== DARK MODE =====
                IconButton(
                  tooltip: _darkMode ? 'Mode Terang' : 'Mode Gelap',
                  icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: _toggleDarkMode,
                ),
              ],
            ),
      // ===== BODY =====
      body: GestureDetector(
        onTap: _focusMode ? _toggleFocusMode : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            children: [
              if (!_focusMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _badge(widget.status, _statusColor()),
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

              Expanded(
                child: Stack(
                  children: [
                    // ===== SKELETON =====
                    if (!_pdfReady) const _PdfSkeleton(),

                    // ===== PDF =====
                    if (_pdfReady)
                      Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onDoubleTapDown: _onDoubleTap,
                          child: InteractiveViewer(
                            transformationController: _transformController,
                            minScale: 1,
                            maxScale: 4,
                            child: PdfPreview(
                              build: (_) => widget.pdfBytes,
                              useActions: false,
                              allowPrinting: false,
                              allowSharing: false,
                              canChangeOrientation: false,
                              canChangePageFormat: false,
                            ),
                          ),
                        ),
                      ),

                    // ===== WATERMARK =====
                    if (widget.isSaved && _watermarkLogo != null)
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: WatermarkPainter(
                            logo: _watermarkLogo!,
                            text: 'RSUD BANGIL',
                            darkMode: _darkMode,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: widget.isSaved
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          await widget.onSave();

                          if (!mounted) return;

                          Navigator.pop(context, {
                            'action': 'saved',
                            'perjanjianId': widget.perjanjianId,
                          });
                        },
                  child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                ),
              ),
            ),
    );
  }

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

// ===================== SKELETON =====================
class _PdfSkeleton extends StatelessWidget {
  const _PdfSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ===================== WATERMARK =====================
class WatermarkPainter extends CustomPainter {
  final ui.Image logo;
  final String text;
  final bool darkMode;

  WatermarkPainter({
    required this.logo,
    required this.text,
    required this.darkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double gap = 220;
    const double logoSize = 80;
    const double angle = -0.4;

    final paint = Paint()
      ..color = (darkMode ? Colors.white : Colors.black).withOpacity(0.08);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: (darkMode ? Colors.white : Colors.black).withOpacity(0.1),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    for (double x = -gap; x < size.width + gap; x += gap) {
      for (double y = -gap; y < size.height + gap; y += gap) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle);
        canvas.drawImageRect(
          logo,
          Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
          Rect.fromLTWH(0, 0, logoSize, logoSize),
          paint,
        );
        textPainter.paint(canvas, Offset(0, logoSize + 6));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
