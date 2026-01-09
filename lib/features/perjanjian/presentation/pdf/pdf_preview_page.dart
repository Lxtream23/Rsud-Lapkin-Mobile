import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/widgets/ui_helpers/app_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/form_perjanjian_page.dart';
import '..//controllers/services/perjanjian_service.dart';

class PdfPreviewPage extends StatefulWidget {
  //final Uint8List pdfBytes;
  final Uint8List? pdfBytes;
  final Future<void> Function() onSave;
  final bool isSaved; // true = view only
  final String status;
  final String? perjanjianId;
  final String? pdfPath;
  final bool isPimpinan;
  final Map<String, dynamic>? pimpinanProfile;

  const PdfPreviewPage({
    super.key,
    //required this.pdfBytes,
    this.pdfBytes,
    required this.onSave,
    required this.status,
    this.isSaved = false,
    this.perjanjianId,
    this.pdfPath,
    this.isPimpinan = false,
    this.pimpinanProfile,
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

  bool get _canEdit =>
      _currentStatus == 'Proses' ||
      (_currentStatus == 'Ditolak' && _rejectReasonRead);

  bool get _canDownload => _currentStatus == 'Disetujui';

  bool get _canDelete =>
      widget.perjanjianId != null &&
      (_currentStatus == 'Proses' || _currentStatus == 'Ditolak');

  bool get _viewOnlyForPimpinan =>
      widget.isPimpinan && _currentStatus == 'Proses';

  bool get _canApprove =>
      widget.isPimpinan && _currentStatus == 'Proses' && !_approving;

  final PerjanjianService _perjanjianService = PerjanjianService();

  Uint8List? _currentPdfBytes;
  late String _currentStatus;

  bool _approving = false;

  bool _forceReloadFromStorage = false;

  String? _rejectionReason;
  bool _rejectReasonRead = false;
  String? _rejectedByName;
  String? _rejectedAt;

  bool get _showRejectionBell =>
      _currentStatus == 'Ditolak' && widget.perjanjianId != null;

  // ===================== INIT =====================
  @override
  void initState() {
    super.initState();
    _loadDarkMode();
    _loadWatermarkLogo();
    _initPdf();
    _currentStatus = widget.status;

    if (_currentStatus == 'Ditolak') {
      _loadRejectionReason();
    }

    // Skeleton delay (aman & smooth)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _pdfReady = true);
      }
    });
  }

  // ===================== SHORT REJECT REASON =====================
  String _shortRejectReason({int maxLength = 80}) {
    final reason = _rejectionReason?.trim();

    if (reason == null || reason.isEmpty) {
      return 'Dokumen ditolak. Klik ikon lonceng untuk detail.';
    }

    if (reason.length <= maxLength) {
      return 'Ditolak: $reason';
    }

    return 'Ditolak: ${reason.substring(0, maxLength)}…';
  }

  Future<void> _initPdf() async {
    final bytes = await _loadPdfBytes();
    if (!mounted) return;
    setState(() => _currentPdfBytes = bytes);
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
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== ICON =====
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              // ===== TITLE =====
              const Text(
                'Berhasil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // ===== MESSAGE =====
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // ===== BUTTON =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    // 1️⃣ tampilkan loading
    _showProgressDialog('Mengunduh PDF...');

    // 2️⃣ beri 1 frame supaya dialog benar-benar tampil
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    try {
      // 🔥 AMBIL PDF (AMAN UNTUK NULL)
      final bytes = await _loadPdfBytes();

      // 3️⃣ tutup loading SEBELUM share
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      await Printing.sharePdf(
        bytes: bytes, // 🔥 PASTI Uint8List
        filename: 'Perjanjian_Kinerja.pdf',
      );

      if (!mounted) return;
      AppSnackbar.success(context, 'PDF Berhasil Diunduh.');
    } catch (e) {
      // 🔥 tutup loading jika error
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('DOWNLOAD ERROR: $e');
      AppSnackbar.error(context, 'Gagal mengunduh PDF.');
    }
  }

  // ===================== DELETE =====================
  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Dokumen'),
        content: const Text(
          'Dokumen ini akan dihapus permanen.\n'
          'Tindakan ini tidak dapat dibatalkan.\n\n'
          'Apakah Anda yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deletePerjanjian();
      if (!context.mounted) return;

      AppSnackbar.success(context, 'Dokumen berhasil dihapus.');
    }
  }

  Future<void> _deletePerjanjian() async {
    if (widget.perjanjianId == null) return;

    // ❗ JANGAN AWAIT
    _showProgressDialog('Menghapus dokumen...');

    final supabase = Supabase.instance.client;

    try {
      // 🔥 DELETE DB
      await supabase
          .from('perjanjian_kinerja')
          .delete()
          .eq('id', widget.perjanjianId!);

      if (!mounted) return;

      // 🔥 TUTUP LOADING
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 🔥 KELUAR DARI PREVIEW
      if (Navigator.canPop(context)) {
        Navigator.pop(context, {
          'action': 'deleted',
          'perjanjianId': widget.perjanjianId!,
        });
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('DELETE ERROR: $e');

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Gagal menghapus dokumen')));
      if (!context.mounted) return;

      AppSnackbar.error(context, 'Gagal menghapus dokumen.');
    }
  }

  Future<Uint8List> _loadPdfBytes() async {
    // ❗ HANYA pakai memory jika TIDAK dipaksa reload
    if (widget.pdfBytes != null && !_forceReloadFromStorage) {
      debugPrint('PDF SOURCE: MEMORY');
      return widget.pdfBytes!;
    }

    final supabase = Supabase.instance.client;

    debugPrint('PDF SOURCE: SUPABASE STORAGE');

    final data = await supabase
        .from('perjanjian_kinerja')
        .select('pdf_path')
        .eq('id', widget.perjanjianId!)
        .single();

    final String pdfPath = data['pdf_path'];

    final bytes = await supabase.storage
        .from('perjanjian-pdf')
        .download(pdfPath);

    return bytes;
  }

  // ===================== REJECTION REASON =====================
  Future<void> _loadRejectionReason() async {
    if (widget.perjanjianId == null) return;

    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('perjanjian_kinerja')
        .select(
          'rejection_reason, rejected_at, rejected_by_name, rejection_read_at',
        )
        .eq('id', widget.perjanjianId!)
        .maybeSingle(); // 🔥 bukan single()

    if (data == null || !mounted) return;

    debugPrint('REJECTION DATA: $data');

    setState(() {
      _rejectionReason = data['rejection_reason'] as String?;
      _rejectedAt = data['rejected_at'] as String?;
      _rejectedByName = data['rejected_by_name'] as String?;
      _rejectReasonRead = data['rejection_read_at'] != null;
    });
  }

  // ===================== REJECTION REASON DIALOG =====================
  Future<void> _showRejectReasonDialog() async {
    final supabase = Supabase.instance.client;

    // ===== MARK AS READ (DB FIRST) =====
    try {
      await supabase
          .from('perjanjian_kinerja')
          .update({'rejection_read_at': DateTime.now().toIso8601String()})
          .eq('id', widget.perjanjianId!);

      if (!mounted) return;

      setState(() {
        _rejectReasonRead = true;
      });
    } catch (e) {
      debugPrint('FAILED TO UPDATE rejection_read_at: $e');
      // optional: snackbar/log audit
    }

    if (!mounted) return;

    // ===== SHOW DIALOG =====
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Dokumen Ditolak',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ===== META INFO =====
              _infoRow(
                Icons.person_outline,
                'Ditolak oleh',
                _rejectedByName ?? '-',
              ),
              const SizedBox(height: 6),
              _infoRow(
                Icons.calendar_today_outlined,
                'Tanggal',
                _rejectedAt != null
                    ? DateTime.parse(
                        _rejectedAt!,
                      ).toLocal().toString().substring(0, 16)
                    : '-',
              ),

              const SizedBox(height: 14),

              // ===== REJECTION REASON (SCROLL SAFE) =====
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _rejectionReason?.trim().isNotEmpty == true
                          ? _rejectionReason!
                          : '-',
                      style: const TextStyle(height: 1.5, fontSize: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== ACTIONS =====
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Ajukan Ulang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _handleResubmit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== INFO ROW WIDGET =====
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ===================== RESUBMIT =====================
  Future<void> _handleResubmit() async {
    Navigator.pop(context); // tutup dialog

    final supabase = Supabase.instance.client;

    await supabase
        .from('perjanjian_kinerja')
        .update({
          'status': 'Proses',
          'rejection_read_at': null,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', widget.perjanjianId!);

    if (!mounted) return;

    AppSnackbar.success(context, 'Silakan perbaiki dokumen dan ajukan kembali');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FormPerjanjianPage(
          mode: FormMode.edit,
          perjanjianId: widget.perjanjianId!,
        ),
      ),
    );
  }

  // Future<Uint8List> _loadPdfBytes() async {
  //   // 1️⃣ Jika PDF sudah dikirim (misalnya status Proses)
  //   if (widget.pdfBytes != null) {
  //     debugPrint('PDF SOURCE: MEMORY');
  //     return widget.pdfBytes!;
  //   }

  //   // 2️⃣ Ambil dari database
  //   final supabase = Supabase.instance.client;

  //   debugPrint('PDF SOURCE: SUPABASE STORAGE');
  //   debugPrint('PERJANJIAN ID: ${widget.perjanjianId}');

  //   final data = await supabase
  //       .from('perjanjian_kinerja')
  //       .select('pdf_path')
  //       .eq('id', widget.perjanjianId!)
  //       .single();

  //   final String pdfPath = data['pdf_path'];

  //   debugPrint('PDF PATH FROM DB: $pdfPath');

  //   final bytes = await supabase.storage
  //       .from('perjanjian-pdf')
  //       .download(pdfPath);

  //   debugPrint('PDF DOWNLOADED: ${bytes.length} bytes');

  //   return bytes;
  // }

  // ===================== APPROVE =====================
  Future<void> _onApprovePressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Setujui Dokumen'),
        content: const Text('Apakah Anda yakin ingin menyetujui dokumen ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _approveDocument();
    }
  }

  // ===================== APPROVE DOCUMENT =====================
  Future<void> _approveDocument() async {
    if (widget.perjanjianId == null ||
        widget.pimpinanProfile == null ||
        _approving)
      return;

    setState(() => _approving = true);
    _showProgressDialog('Menyetujui & memperbarui PDF...');

    try {
      /// 1️⃣ approve + overwrite pdf (SUPABASE)
      await _perjanjianService.approvePerjanjian(
        perjanjianId: widget.perjanjianId!,
        pimpinanProfile: widget.pimpinanProfile!,
      );

      /// 2️⃣ reload pdf terbaru
      _forceReloadFromStorage = true;
      await _reloadPdf();

      /// 3️⃣ update status lokal (🔥 PENTING)
      setState(() {
        _currentStatus = 'Disetujui';
      });

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // tutup loading
      }

      AppSnackbar.success(context, 'Dokumen disetujui & PDF diperbarui');
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('APPROVE ERROR: $e');
      AppSnackbar.error(context, 'Gagal menyetujui dokumen');
    } finally {
      if (mounted) {
        setState(() => _approving = false);
      }
    }
  }

  Future<void> _reloadPdf() async {
    final bytes = await _loadPdfBytes();

    if (!mounted) return;

    setState(() {
      _currentPdfBytes = bytes;
    });
  }

  Future<void> _onRejectPressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak Dokumen'),
        content: const Text('Apakah Anda yakin ingin menolak dokumen ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _showRejectReasonDialog();
    }
  }

  // Future<void> _rejectDocument(String reason) async {
  //   final supabase = Supabase.instance.client;
  //   final user = supabase.auth.currentUser;
  //   if (user == null) return;

  //   await supabase
  //       .from('perjanjian_kinerja')
  //       .update({
  //         'status': 'Ditolak',
  //         'rejection_reason': reason,
  //         'rejected_at': DateTime.now().toIso8601String(),
  //         'rejected_by': user.id,
  //       })
  //       .eq('id', widget.perjanjianId!);

  //   if (mounted) {
  //     setState(() {
  //       _currentStatus = 'Ditolak';
  //       _rejectionReason = reason; // 🔥 langsung update
  //     });
  //   }
  // }

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
    switch (_currentStatus) {
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
    debugPrint('PREVIEW OPENED: ${widget.pdfBytes?.length ?? 0}');

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
                // ===== REJECTION REASON (HANYA JIKA DITOLAK) =====
                if (_showRejectionBell)
                  IconButton(
                    tooltip: 'Alasan Penolakan',
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined),
                        if (!_rejectReasonRead)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showRejectReasonDialog,
                  ),

                // ================= PIMPINAN MODE =================
                if (_canApprove) ...[
                  IconButton(
                    tooltip: 'Tolak',
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: _onRejectPressed,
                  ),
                  IconButton(
                    tooltip: 'Setujui',
                    icon: _approving
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: _approving ? null : _onApprovePressed,
                  ),
                ]
                // ================= NORMAL MODE =================
                else ...[
                  if (_canDelete)
                    IconButton(
                      tooltip: 'Hapus Dokumen',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _confirmDelete,
                    ),

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
                ],

                // ===== FOCUS MODE (SELALU ADA) =====
                IconButton(
                  tooltip: 'Mode Fokus',
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFocusMode,
                ),

                // ===== DARK MODE (SELALU ADA) =====
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
                    _badge(_currentStatus, _statusColor()),
                    Text(
                      'Zoom ${(_zoomLevel * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: _darkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              if (_currentStatus == 'Ditolak')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    !_rejectReasonRead
                        ? _shortRejectReason()
                        : 'Dokumen ini telah ditolak.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      height: 1.4,
                    ),
                  ),
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
                            child: _currentPdfBytes == null
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : PdfPreview(
                                    build: (_) => _currentPdfBytes!,
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
                            //text: 'RSUD BANGIL',
                            text: _currentStatus == 'Ditolak'
                                ? 'DITOLAK'
                                : 'RSUD BANGIL',

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
