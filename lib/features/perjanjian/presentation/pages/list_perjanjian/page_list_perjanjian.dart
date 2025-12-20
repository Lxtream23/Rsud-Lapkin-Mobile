import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/features/perjanjian/presentation/pdf/pdf_preview_page.dart';
import 'page_perjanjian_audit_log.dart';

import '/../../../config/app_colors.dart';
import '/../../../config/app_text_style.dart';

class PageListPerjanjian extends StatefulWidget {
  final String? status; // null = semua
  final bool showAppBar;

  const PageListPerjanjian({super.key, this.status, this.showAppBar = false});

  @override
  State<PageListPerjanjian> createState() => _PageListPerjanjianState();
}

class _PageListPerjanjianState extends State<PageListPerjanjian>
    with AutomaticKeepAliveClientMixin<PageListPerjanjian> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  // ===================== LOAD DATA =====================
  Future<List<Map<String, dynamic>>> _loadData() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    var query = supabase
        .from('perjanjian_kinerja')
        .select()
        .eq('user_id', user.id);

    if (widget.status != null) {
      query = query.eq('status', widget.status!);
    }

    final result = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  // ===================== LOAD PDF =====================
  Future<Uint8List> _loadPdf(Map<String, dynamic> item) async {
    final path = item['pdf_path'];
    if (path == null || path.toString().isEmpty) {
      throw Exception('Path PDF kosong');
    }

    final bytes = await supabase.storage.from('perjanjian-pdf').download(path);

    if (bytes.isEmpty) {
      throw Exception('File PDF kosong');
    }

    return bytes;
  }

  // ===================== AUDIT LOG =====================
  Future<void> _saveAuditLog({
    required String perjanjianId,
    required String aksi,
    String? keterangan,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('perjanjian_audit_log').insert({
      'perjanjian_id': perjanjianId,
      'user_id': user.id,
      'aksi': aksi,
      'keterangan': keterangan,
    });
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              title: Text(
                widget.status == null
                    ? 'Semua Perjanjian'
                    : 'Laporan: ${widget.status}',
                style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
              ),
            )
          : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('Data belum ada'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildItem(context, data[index]);
            },
          );
        },
      ),
    );
  }

  // ===================== ITEM =====================
  Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
    final user = supabase.auth.currentUser;
    final bool editable = user != null && item['user_id'] == user.id;

    final createdAt = item['created_at'] is DateTime
        ? item['created_at'] as DateTime
        : DateTime.tryParse(item['created_at'] ?? '');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
        title: const Text(
          'Perjanjian Kinerja',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item['nama_pihak_kedua']} • Versi ${item['version']}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusBg(item['status']),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item['status'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _statusText(item['status']),
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (createdAt != null)
              Text(
                'Dibuat: ${_formatDate(createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        // ===== TAP → PREVIEW PDF =====
        onTap: () async {
          try {
            final pdfBytes = await _loadPdf(item);

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfPreviewPage(
                  pdfBytes: pdfBytes,
                  onSave: editable
                      ? () async {
                          await _saveAuditLog(
                            perjanjianId: item['id'],
                            aksi: 'UPDATE',
                            keterangan:
                                'Dokumen dibuka & disimpan oleh pembuat',
                          );
                        }
                      : () async {},
                ),
              ),
            );

            setState(() {
              _future = _loadData();
            });
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },

        // ===== LONG PRESS → RIWAYAT =====
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PagePerjanjianAuditLog(perjanjianId: item['id']),
            ),
          );
        },
      ),
    );
  }

  // ===================== HELPERS =====================
  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.amber.shade100;
      case 'Ditolak':
        return Colors.red.shade100;
      case 'Proses':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusText(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.amber.shade900;
      case 'Ditolak':
        return Colors.red.shade900;
      case 'Proses':
        return Colors.blue.shade900;
      default:
        return Colors.black54;
    }
  }
}
