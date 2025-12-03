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

  @override
  void initState() {
    super.initState();
    _addRow(); // minimal 1 program baris
  }

  /// Convert ke List<List<String>> (dipakai PDF collector)
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

  void _deleteSubRow(int parent, int index) async {
    if (parent < 0 || parent >= _rows.length) return;

    final subList = _rows[parent]['sub'] as List<TextEditingController>;
    if (index < 0 || index >= subList.length) return;

    final text = subList[index].text.trim();

    // -----------------------------------------------------
    // CASE 1 — Jika SUB masih kosong → langsung hapus
    // -----------------------------------------------------
    if (text.isEmpty) {
      // Jika hanya 1 sub, hapus semua agar kembali default
      if (subList.length == 1) {
        try {
          subList.first.dispose();
        } catch (_) {}
        subList.clear();
      } else {
        // hapus item
        try {
          subList[index].dispose();
        } catch (_) {}
        subList.removeAt(index);
      }

      setState(() {});
      _showDeleteSuccess("Sub-program dihapus (kosong)");
      return;
    }

    // -----------------------------------------------------
    // CASE 2 — Sub terisi → tampilkan dialog konfirmasi
    // -----------------------------------------------------
    final ok = await showConfirmDeleteDialog(context);

    if (ok) {
      // Jika hanya 1 sub → kosongkan
      if (subList.length == 1) {
        subList.first.clear();
        setState(() {});
        _showDeleteSuccess("Sub-program dikosongkan");
        return;
      }

      try {
        subList[index].dispose();
      } catch (_) {}
      subList.removeAt(index);

      setState(() {});
      _showDeleteSuccess("Sub-program dihapus");
    }
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
    final isNegative = v < 0;
    v = v.abs();

    final intPart = v.floor(); // angka tanpa desimal
    final decimals = ((v - intPart) * 100).round(); // ambil 2 desimal

    // format ribuan pakai titik
    final intStr = intPart.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < intStr.length; i++) {
      final pos = intStr.length - i;
      buffer.write(intStr[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write('.');
    }

    final formattedInt = buffer.toString();

    // jika desimal 0 → hilangkan ",00"
    if (decimals == 0) {
      return "Rp ${isNegative ? '-' : ''}$formattedInt";
    }

    // tampilkan desimal jika tidak nol
    final decimalStr = decimals.toString().padLeft(2, '0');
    return "Rp ${isNegative ? '-' : ''}$formattedInt,$decimalStr";
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
            const Expanded(
              child: Text(
                "TABEL PROGRAM & SUB-PROGRAM",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            // show total program & sub
            _labelChip("${_rows.length} program"),
            const SizedBox(width: 8),
            if (totalSubCount > 0) _labelChip("$totalSubCount sub"),
          ],
        ),

        const SizedBox(height: 12),

        // list program cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (context, i) {
            return _buildProgramCard(context, i, scheme);
          },
        ),

        const SizedBox(height: 12),

        // footer: add button (left) + totals (right)
        Row(
          children: [
            TextButton.icon(
              onPressed: _addRow,
              icon: Icon(Icons.add_circle, color: scheme.primary),
              label: Text(
                "Tambah Program",
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const Spacer(),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // -------------------------
  // Build Program Card
  // -------------------------
  Widget _buildProgramCard(BuildContext context, int i, ColorScheme scheme) {
    final programCtrl = _rows[i]['program'] as TextEditingController;
    final anggaranCtrl = _rows[i]['anggaran'] as TextEditingController;
    final ketCtrl = _rows[i]['keterangan'] as TextEditingController;
    final subList = _rows[i]['sub'] as List<TextEditingController>;

    return Card(
      color: const Color(0xFFBEF8FF),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row: number, title, sub-chip, expand, delete
              Row(
                children: [
                  // number circle
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // title preview
                  Expanded(
                    child: Text(
                      programCtrl.text.trim().isEmpty
                          ? "— kosong —"
                          : programCtrl.text.trim(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  // sub-count chip (only show when sub exists)
                  if (subList.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _labelChip("${subList.length} sub"),
                  ],

                  const SizedBox(width: 8),

                  // expand / collapse
                  IconButton(
                    icon: Icon(
                      openIndex == i
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      setState(() {
                        openIndex = (openIndex == i) ? null : i;
                      });
                    },
                  ),

                  // delete program
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFE74C3C),
                    ),
                    onPressed: () async {
                      final ok = await showConfirmDeleteDialog(context);
                      if (ok) _deleteRow(i);
                    },
                  ),
                ],
              ),

              // expanded content
              if (openIndex == i) ...[
                const SizedBox(height: 12),
                _input("Program", programCtrl),
                const SizedBox(height: 10),
                _input("Anggaran", anggaranCtrl),
                const SizedBox(height: 10),
                _input("Keterangan", ketCtrl),
                const SizedBox(height: 12),

                Divider(color: Colors.grey.shade300),

                // subprogram list (each has only text field + delete)
                const SizedBox(height: 8),
                Column(
                  children: [
                    for (int si = 0; si < subList.length; si++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                "${i + 1}.${si + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _input("Sub Program", subList[si])),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                final ok = await showConfirmDeleteDialog(
                                  context,
                                );
                                if (ok) _deleteSubRow(i, si);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),
                // add sub button
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _addSubRow(i),
                      icon: Icon(Icons.add, color: scheme.primary),
                      label: Text(
                        "Tambah Sub Program",
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // quick total for this program
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Sub: ${subList.length}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency(_parseCurrencySafe(anggaranCtrl.text)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => openIndex = null),
                    child: const Text("Tutup"),
                  ),
                ),
              ],
            ],
          ),
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
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(.12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      onChanged: (_) => setState(() {}),
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
                borderRadius: BorderRadius.circular(12),
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
                  ),
                  child: const Text("Hapus"),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
