// lib/presentation/widgets/card_table3.dart
import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/widgets/ui_helpers/app_snackbar.dart';

class CardTable3Widget extends StatefulWidget {
  const CardTable3Widget({super.key});

  @override
  State<CardTable3Widget> createState() => _CardTable3WidgetState();
}

class _CardTable3WidgetState extends State<CardTable3Widget>
    with TickerProviderStateMixin {
  /// Struktur per baris (program):
  /// {
  ///   "program": TextEditingController(),
  ///   "anggaran": TextEditingController(),
  ///   "keterangan": TextEditingController(),
  ///   "sub": List<TextEditingController>() // sub program — hanya teks, tanpa anggaran
  /// }
  final List<Map<String, dynamic>> _rows = [];

  /// index panel yang terbuka (expand/collapse)
  int? openIndex;

  /// threshold untuk "daftar panjang" — saat list melebihi ini,
  /// membuka panel akan memastikan hanya satu panel terbuka.
  final int _longListThreshold = 8;

  @override
  void initState() {
    super.initState();
    _addRow(); // minimal 1 program baris
  }

  /// Convert ke List<List<String>> (dipakai PDF collector jika perlu)
  List<List<String>> getRowsAsStrings() {
    final result = <List<String>>[];
    for (final r in _rows) {
      final p = (r['program'] as TextEditingController).text.trim();
      final a = (r['anggaran'] as TextEditingController).text.trim();
      final k = (r['keterangan'] as TextEditingController).text.trim();
      result.add([p, a, k]);
      // NOTE: sub-programs tidak dimasukkan ke tabel 3 biasa; kalau perlu tambahkan sesuai kebutuhan
    }
    return result;
  }

  @override
  void dispose() {
    for (final r in _rows) {
      try {
        (r['program'] as TextEditingController).dispose();
      } catch (_) {}
      try {
        (r['anggaran'] as TextEditingController).dispose();
      } catch (_) {}
      try {
        (r['keterangan'] as TextEditingController).dispose();
      } catch (_) {}
      if (r['sub'] is List) {
        for (final s in (r['sub'] as List<TextEditingController>)) {
          try {
            s.dispose();
          } catch (_) {}
        }
      }
    }
    super.dispose();
  }

  // -------------------------
  // Row management (program)
  // -------------------------
  void _addRow() {
    final map = {
      "program": TextEditingController(),
      "anggaran": TextEditingController(),
      "keterangan": TextEditingController(),
      "sub": <TextEditingController>[],
    };
    setState(() => _rows.add(map));
  }

  void _deleteRow(int index) {
    if (index < 0 || index >= _rows.length) return;

    // Jika hanya 1, clear saja
    if (_rows.length == 1) {
      (_rows.first['program'] as TextEditingController).clear();
      (_rows.first['anggaran'] as TextEditingController).clear();
      (_rows.first['keterangan'] as TextEditingController).clear();
      (_rows.first['sub'] as List<TextEditingController>).clear();
      setState(() {});
      _showDeleteSuccess("Baris program dikosongkan");
      return;
    }

    // dispose controllers
    for (final s in (_rows[index]['sub'] as List<TextEditingController>)) {
      try {
        s.dispose();
      } catch (_) {}
    }
    try {
      (_rows[index]['program'] as TextEditingController).dispose();
      (_rows[index]['anggaran'] as TextEditingController).dispose();
      (_rows[index]['keterangan'] as TextEditingController).dispose();
    } catch (_) {}

    final removedSummary = (_rows[index]['program'] as TextEditingController)
        .text
        .trim();
    _rows.removeAt(index);

    // adjust openIndex
    if (openIndex != null) {
      if (openIndex == index) {
        openIndex = null;
      } else if (openIndex! > index) {
        openIndex = openIndex! - 1;
      }
    }

    setState(() {});
    _showDeleteSuccess(
      'Program "${removedSummary.isEmpty ? "— kosong —" : removedSummary}" dihapus',
    );
  }

  // -------------------------
  // Sub-row management
  // -------------------------
  void _addSubRow(int parentIndex) {
    if (parentIndex < 0 || parentIndex >= _rows.length) return;

    final subList = _rows[parentIndex]['sub'] as List<TextEditingController>;
    final ctrl = TextEditingController();
    subList.add(ctrl);

    // buka panel jika belum terbuka
    setState(() {
      openIndex = parentIndex;
    });
  }

  void _deleteSubRow(int parent, int index) {
    if (parent < 0 || parent >= _rows.length) return;
    final subList = _rows[parent]['sub'] as List<TextEditingController>;
    if (index < 0 || index >= subList.length) return;

    // Jika sub ini kosong -> langsung hapus dan kembalikan tampilan default
    final text = subList[index].text.trim();
    if (text.isEmpty) {
      // hapus controller
      try {
        subList[index].dispose();
      } catch (_) {}
      subList.removeAt(index);
      setState(() {});
      _showDeleteSuccess("Sub-program dihapus");
      return;
    }

    // jika tidak kosong, tanyakan konfirmasi dulu
    showConfirmDeleteDialog(context).then((ok) {
      if (ok) {
        try {
          subList[index].dispose();
        } catch (_) {}
        subList.removeAt(index);
        setState(() {});
        _showDeleteSuccess("Sub-program dihapus");
      }
    });
  }

  // -------------------------
  // Helpers: totals
  // -------------------------
  /// jumlah total sub across all program
  int get totalSubCount {
    return _rows.fold<int>(0, (sum, r) {
      final list = r['sub'] as List<TextEditingController>;
      return sum + list.length;
    });
  }

  /// jumlah total anggaran (parse numeric, toleran terhadap format "1.000.000,00" or "1000000")
  double get totalAnggaran {
    double sum = 0.0;
    for (final r in _rows) {
      final text = (r['anggaran'] as TextEditingController).text.trim();
      if (text.isEmpty) continue;
      // remove non-digit except comma and dot
      final cleaned = text.replaceAll(RegExp(r'[^0-9\.,-]'), '');
      // Try to determine decimal separator: if contains ',' and also '.', assume '.' thousands, ',' decimal
      String normalized = cleaned;
      if (cleaned.contains(',') && cleaned.contains('.')) {
        normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else if (cleaned.contains(',') && !cleaned.contains('.')) {
        // if only comma, treat comma as decimal separator -> replace with dot
        normalized = cleaned.replaceAll(',', '.');
      } else {
        // only dots or only digits -> remove dots as thousand separators
        normalized = cleaned.replaceAll(',', '').replaceAll('.', '');
      }
      // Now try parse
      final val = double.tryParse(normalized) ?? 0.0;
      sum += val;
    }
    return sum;
  }

  String formatCurrency(double v) {
    // Simple Indonesian formatted currency: Rp 1.234.567 (no decimals if zeros)
    final isNegative = v < 0;
    v = v.abs();
    final intPart = v.floor();
    final decimals = ((v - intPart) * 100).round();
    final intStr = intPart.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intStr.length; i++) {
      final pos = intStr.length - i;
      buffer.write(intStr[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write('.');
    }

    // If decimals are zero, don't show ,00
    final decimalPart = decimals == 0
        ? ''
        : ',${decimals.toString().padLeft(2, '0')}';
    final result =
        'Rp ${isNegative ? '-' : ''}${buffer.toString()}$decimalPart';
    return result;
  }

  // -------------------------
  // UI helpers
  // -------------------------
  Widget _labelChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFBEF8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // Snackbars (preserve your existing helpers)
  void _showDeleteSuccess(String msg) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx == null) {
      debugPrint("Overlay NULL → Snackbar gagal ditampilkan");
      return;
    }
    AppSnackbar.success(ctx, msg);
  }

  void _showDeleteError(String msg) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx == null) return;
    AppSnackbar.error(ctx, msg);
  }

  // -------------------------
  // BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header + count
        Row(
          children: [
            const Text(
              "TABEL PROGRAM & ANGGARAN",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // show total program & sub
            _labelChip("${_rows.length} baris"),
            //const SizedBox(width: 8),
            //if (totalSubCount > 0) _labelChip("$totalSubCount sub"),
          ],
        ),

        const SizedBox(height: 8),

        // list program cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (context, i) {
            return _buildProgramCard(context, i, scheme);
          },
        ),

        const SizedBox(height: 8),

        // footer: add button (left) + totals (right)
        Row(
          children: [
            TextButton.icon(
              onPressed: _addRow,
              icon: Icon(Icons.add_circle, color: scheme.primary),
              label: Text(
                "Tambah Baris",
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // total anggaran preview
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Total Anggaran",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(totalAnggaran),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // notes
        Row(
          children: [
            Expanded(
              child: Text(
                "Catatan: Silakan tambahkan program dan sub-program sesuai kebutuhan. Anggaran total akan dihitung otomatis.",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------
  // Build Program Card
  // -------------------------
  Widget _buildProgramCard(BuildContext context, int i, ColorScheme scheme) {
    final theme = Theme.of(context).colorScheme;

    final programCtrl = _rows[i]['program'] as TextEditingController;
    final anggaranCtrl = _rows[i]['anggaran'] as TextEditingController;
    final ketCtrl = _rows[i]['keterangan'] as TextEditingController;
    final subList = _rows[i]['sub'] as List<TextEditingController>;

    return Card(
      color: const Color(0xFFBEF8FF),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            // ======= HEADER (InkWell clickable seluruh card header) =======
            InkWell(
              onTap: () {
                setState(() {
                  openIndex = (openIndex == i) ? null : i;
                });
              },
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Number chip
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Program title
                    Expanded(
                      child: Text(
                        programCtrl.text.trim().isEmpty
                            ? "— kosong —"
                            : programCtrl.text.trim(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    if (subList.isNotEmpty) ...[
                      _labelChip("${subList.length} sub"),
                      const SizedBox(width: 8),
                    ],

                    // Delete program
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE74C3C),
                      ),
                      splashRadius: 20,
                      onPressed: () async {
                        final ok = await showConfirmDeleteDialog(context);
                        if (ok) _deleteRow(i);
                      },
                    ),

                    // Expand arrow
                    AnimatedRotation(
                      turns: openIndex == i ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 260),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),

            // ======= EXPANDED CONTENT =======
            if (openIndex == i)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _input("Program", programCtrl),
                    const SizedBox(height: 10),

                    _input("Anggaran", anggaranCtrl),
                    const SizedBox(height: 10),

                    _input("Keterangan", ketCtrl),
                    const SizedBox(height: 12),

                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 8),

                    // ==== SUB PROGRAM LIST ====
                    Column(
                      children: [
                        for (int si = 0; si < subList.length; si++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${i + 1}.${si + 1}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                Expanded(
                                  child: _input("Sub Program", subList[si]),
                                ),

                                const SizedBox(width: 8),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    final txt = subList[si].text.trim();
                                    if (txt.isEmpty) {
                                      _deleteSubRow(i, si);
                                    } else {
                                      showConfirmDeleteDialog(context).then((
                                        ok,
                                      ) {
                                        if (ok) _deleteSubRow(i, si);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Add sub program
                    TextButton.icon(
                      onPressed: () => _addSubRow(i),
                      icon: Icon(Icons.add_circle, color: scheme.primary),
                      label: Text(
                        "Tambah Sub Baris",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Anggaran preview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(_parseCurrencySafe(anggaranCtrl.text)),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Text(
                      "Isi detail program, anggaran, dan keterangan. Tambahkan sub-program jika diperlukan.",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // simple parser for UI preview of single anggaran
  double _parseCurrencySafe(String text) {
    if (text.trim().isEmpty) return 0.0;
    final cleaned = text.replaceAll(RegExp(r'[^0-9\.,-]'), '');
    String normalized = cleaned;
    if (cleaned.contains(',') && cleaned.contains('.')) {
      normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (cleaned.contains(',') && !cleaned.contains('.')) {
      normalized = cleaned.replaceAll(',', '.');
    } else {
      normalized = cleaned.replaceAll(',', '').replaceAll('.', '');
    }
    return double.tryParse(normalized) ?? 0.0;
  }

  // Input widget reused
  Widget _input(String label, TextEditingController ctrl) {
    final theme = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: TextField(
        controller: ctrl,
        minLines: 1,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14),
          filled: true,
          fillColor: theme.surfaceContainerLowest,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // Confirm delete dialog (reused)
  Future<bool> showConfirmDeleteDialog(BuildContext context) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                "Hapus?",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Text(
                "Apakah Anda yakin ingin menghapus item ini?",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Batal",
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
