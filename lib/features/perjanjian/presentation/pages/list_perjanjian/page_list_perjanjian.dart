import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/features/perjanjian/presentation/pdf/pdf_preview_page.dart';
import 'page_perjanjian_audit_log.dart';

import '/../../../config/app_colors.dart';
import '/../../../config/app_text_style.dart';

import 'dart:async';

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

  // ===================== FILTER STATE (BARU) =====================
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Semua';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _sortDesc = true;
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // sinkron dengan status dari page sebelumnya
    if (widget.status != null) {
      _selectedStatus = widget.status!;
    }

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

    // SEARCH (Supabase)
    if (_searchQuery.isNotEmpty) {
      query = query.or(
        'nama_pihak_kedua.ilike.%$_searchQuery%,'
        'status.ilike.%$_searchQuery%',
      );
    }

    // STATUS
    if (_selectedStatus != 'Semua') {
      query = query.eq('status', _selectedStatus);
    }

    // FILTER TANGGAL
    if (_startDate != null) {
      query = query.gte('created_at', _startDate!.toIso8601String());
    }
    if (_endDate != null) {
      query = query.lte(
        'created_at',
        _endDate!.add(const Duration(days: 1)).toIso8601String(),
      );
    }

    final result = await query.order('created_at', ascending: !_sortDesc);

    return List<Map<String, dynamic>>.from(result);
  }

  // ===================== LOAD PDF =====================
  Future<Uint8List> _loadPdf(Map<String, dynamic> item) async {
    final path = item['pdf_path'];
    if (path == null || path.toString().isEmpty) {
      throw Exception('Path PDF kosong');
    }

    final bytes = await supabase.storage.from('perjanjian-pdf').download(path);
    if (bytes.isEmpty) throw Exception('File PDF kosong');

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

  void _onSearchChanged(String value) {
    // Batalkan timer sebelumnya
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
        _future = _loadData();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
                    ? 'Semua Laporan Perjanjian'
                    : 'Laporan: ${widget.status}',
                style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
              ),
            )
          : null,
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ===================== FILTER UI (BARU) =====================
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // SEARCH
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama pihak kedua / status...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 10),

          // CHIP STATUS
          Wrap(
            spacing: 8,
            children: ['Semua', 'Proses', 'Disetujui', 'Ditolak']
                .map(
                  (s) => ChoiceChip(
                    label: Text(s),
                    selected: _selectedStatus == s,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = s;
                        _future = _loadData();
                      });
                    },
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              ChoiceChip(
                label: Text(_sortDesc ? 'Terbaru' : 'Terlama'),
                selected: true,
                onSelected: (_) {
                  setState(() {
                    _sortDesc = !_sortDesc;
                    _future = _loadData();
                  });
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: _pickDateRange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _highlightTextFade({
    required String text,
    required String query,
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    if (query.isEmpty) {
      return Text(text, style: normalStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: normalStyle);
    }

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: normalStyle),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style:
              highlightStyle ??
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      );

      start = index + query.length;
    }

    return AnimatedOpacity(
      key: ValueKey(query), // 🔥 trigger animasi saat search berubah
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: RichText(text: TextSpan(children: spans)),
    );
  }

  Widget _animatedEmptyState(String message) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
        _future = _loadData();
      });
    }
  }

  // ===================== LIST =====================
  Widget _buildList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
          return Center(
            child: _animatedEmptyState(
              _searchQuery.isNotEmpty
                  ? 'Data tidak ditemukan'
                  : 'Belum ada perjanjian',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildItem(context, data[index]),
        );
      },
    );
  }

  // ===================== ITEM (TIDAK DIUBAH) =====================
  Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
    final user = supabase.auth.currentUser;
    final bool editable = user != null && item['user_id'] == user.id;

    final createdAtUtc = item['created_at'] is DateTime
        ? item['created_at'] as DateTime
        : DateTime.parse(item['created_at']);

    final createdAtWib = createdAtUtc.toLocal();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
        title: _highlightTextFade(
          text: 'Perjanjian Kinerja',
          query: _searchQuery,
          normalStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _highlightTextFade(
              text: '${item['nama_pihak_kedua']} • Versi ${item['version']}',
              query: _searchQuery,
              normalStyle: const TextStyle(fontSize: 13, color: Colors.black54),
              highlightStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusBg(item['status']),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _highlightTextFade(
                text: item['status'],
                query: _searchQuery,
                normalStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _statusText(item['status']),
                ),
                highlightStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  backgroundColor: Colors.yellow,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Dibuat: ${_formatDate(createdAtWib)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        '${d.minute.toString().padLeft(2, '0')} WIB';
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
