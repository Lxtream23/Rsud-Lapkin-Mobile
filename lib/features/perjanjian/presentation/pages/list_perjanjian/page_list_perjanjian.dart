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

  // ===================== SCROLL STATE =====================
  static const int _pageSize = 10;
  final List<Map<String, dynamic>> _items = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;

  final ScrollController _scrollController = ScrollController();

  late RealtimeChannel _realtimeChannel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // sinkron dengan status dari page sebelumnya
    if (widget.status != null) {
      _selectedStatus = widget.status!;
    }

    _loadData(reset: true); // 🔥 LOAD AWAL

    _listenRealtime(); // 🔥 INI

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  // ===================== LOAD DATA =====================
  Future<void> _loadData({bool reset = false}) async {
    if (_isLoadingMore) return; // 🔥 safet

    if (reset) {
      _items.clear();
      _page = 0;
      _hasMore = true;
    }

    if (!_hasMore) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoadingMore = true);

    final from = _page * _pageSize;
    final to = from + _pageSize - 1;

    var query = supabase
        .from('perjanjian_kinerja')
        .select()
        .eq('user_id', user.id);

    // SEARCH MULTI KOLOM
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

    // DATE FILTER
    if (_startDate != null) {
      query = query.gte('created_at', _startDate!.toIso8601String());
    }
    if (_endDate != null) {
      query = query.lte(
        'created_at',
        _endDate!.add(const Duration(days: 1)).toIso8601String(),
      );
    }

    final result = await query
        .order('created_at', ascending: !_sortDesc)
        .range(from, to);

    final newItems = List<Map<String, dynamic>>.from(result);

    setState(() {
      _items.addAll(newItems);
      _page++;
      _hasMore = newItems.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  Future<void> _loadMore() async {
    await _loadData();
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

  // ===================== REALTIME =====================
  void _listenRealtime() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _realtimeChannel = supabase
        .channel('perjanjian-realtime-${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'perjanjian_kinerja',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            debugPrint('🔥 Realtime change: ${payload.eventType}');

            // 🔥 SOLUSI AMAN
            _loadData(reset: true);
          },
        )
        .subscribe();
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
      });
      _loadData(reset: true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();

    try {
      supabase.removeChannel(_realtimeChannel);
    } catch (_) {}

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
      // 🔹 Footer
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
        ),
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
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
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
                    label: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedStatus == s
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    selected: _selectedStatus == s,
                    selectedColor: AppColors.primary,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = s;
                      });
                      _loadData(reset: true);
                    },
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              ChoiceChip(
                label: Text(
                  _sortDesc ? 'Terbaru' : 'Terlama',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                selected: true,
                selectedColor: AppColors.primary,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (_) {
                  setState(() {
                    _sortDesc = !_sortDesc;
                  });
                  _loadData(reset: true);
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.date_range, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
      });
      _loadData(reset: true);
    }
  }

  // ===================== LIST =====================
  Widget _buildList() {
    if (_items.isEmpty && _isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return Center(
        child: _animatedEmptyState(
          _searchQuery.isNotEmpty
              ? 'Data tidak ditemukan'
              : 'Belum ada perjanjian',
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildItem(context, _items[index]);
      },
    );
  }

  // ===================== ITEM (TIDAK DIUBAH) =====================
  Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
    final user = supabase.auth.currentUser;
    final String status = item['status'] as String;

    // 🔥 dari LIST → SELALU view only
    const bool viewOnly = true;

    // 🔥 hanya untuk watermark / info
    const bool isSaved = true;

    final bool canSave = status == 'Proses' || status == 'Ditolak';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Pihak Pertama
                _highlightTextFade(
                  text: item['nama_pihak_pertama'] ?? '-',
                  query: _searchQuery,
                  normalStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  highlightStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue, // ⬅ beda warna
                    backgroundColor: Color(0x332196F3),
                  ),
                ),
                const SizedBox(height: 2),
                // Nama Pihak Kedua + versi
                _highlightTextFade(
                  text:
                      '${item['nama_pihak_kedua']} • Versi ${item['version']}',
                  query: _searchQuery,
                  normalStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusBg(status),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _statusText(status),
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

        // ===================== TAP =====================
        onTap: () async {
          final messenger = ScaffoldMessenger.maybeOf(context);
          try {
            final pdfBytes = await _loadPdf(item);
            debugPrint(String.fromCharCodes(pdfBytes.take(10)));
            print('PDF bytes length: ${pdfBytes.length}');
            print('PDF header: ${String.fromCharCodes(pdfBytes.take(8))}');

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfPreviewPage(
                  pdfBytes: pdfBytes,
                  // 🔥 WAJIB
                  status: status,
                  // 🔥 read-only visual
                  isSaved: true,
                  perjanjianId: item['id'],
                  // 🔥 tidak pernah dipakai
                  onSave: () async {},
                ),
              ),
            );
            // ===================== REFRESH =====================
            if (result != null && result['action'] == 'deleted') {
              debugPrint('🔄 Refresh via Navigator result');

              await _loadData(reset: true);

              if (!mounted) return; // 🔥 PENTING

              if (messenger != null) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Dokumen berhasil dihapus')),
                );
              }
            }
          } catch (e) {
            messenger?.showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },

        // ===================== LONG PRESS =====================
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
