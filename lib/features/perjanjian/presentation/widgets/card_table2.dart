// lib/presentation/widgets/card_table2.dart
import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/widgets/ui_helpers/app_snackbar.dart';

class CardTable2Widget extends StatefulWidget {
  const CardTable2Widget({super.key});

  @override
  State<CardTable2Widget> createState() => _CardTable2WidgetState();
}

class _CardTable2WidgetState extends State<CardTable2Widget>
    with TickerProviderStateMixin {
  /// setiap baris: 7 kolom
  final List<List<TextEditingController>> _rows = [];

  /// index card yang terbuka (accordion mode)
  int? _openIndex;

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      for (final c in r) c.dispose();
    }
    super.dispose();
  }

  // ===================================================================
  // ROW MANAGEMENT
  // ===================================================================
  // ADD ROW
  void _addRow() {
    setState(() {
      _rows.add(List.generate(7, (_) => TextEditingController()));
    });
  }

  // DELETE ROW
  void _deleteRow(int index) {
    debugPrint(
      "🗑 DELETE REQUEST [TABEL2] → index: $index, total rows: ${_rows.length}",
    );

    // --- Validasi Index ---
    if (index < 0 || index >= _rows.length) {
      debugPrint(
        "❌ DELETE FAILED [TABEL2] → index out of range. Tidak jadi hapus.",
      );
      _showDeleteError("Gagal menghapus: index tidak valid");
      return;
    }

    // ---- Ambil summary row untuk pesan snackbar ----
    final deletedSummary = _summary(_rows[index]);

    // --- Kasus: hanya ada 1 baris, jangan hapus hanya kosongkan ---
    if (_rows.length == 1) {
      debugPrint("🗑 DELETE [TABEL2] → Hanya satu baris. Membersihkan saja...");
      for (final c in _rows.first) {
        if (!c.isClosed)
          c.clear();
        else {
          debugPrint("⚠ Controller [TABEL2] sudah closed, skip clear");
        }
      }

      setState(() {});

      debugPrint(
        "🗑 DELETE [TABEL2] → Menghapus row ke-$index "
        "(kolom: ${_rows.first.length} controller).",
      );

      _showDeleteSuccess("Baris 1 telah dikosongkan");
      return;
    }

    // ---- Hapus controller dengan aman ----
    for (final c in _rows[index]) {
      if (!c.isClosed) {
        c.dispose();
      } else {
        debugPrint("⚠ [TABEL2]Controller sudah closed, skip dispose");
      }
    }

    // ---- Update UI ----
    setState(() {
      _rows.removeAt(index);

      // Tutup accordion jika row yang dihapus adalah row terbuka
      if (_openIndex == index) {
        _openIndex = null;
      }

      // Jika openIndex melebihi panjang list setelah delete → geser
      if (_openIndex != null && _openIndex! >= _rows.length) {
        _openIndex = _rows.length - 1;
      }
    });

    debugPrint("✅ DELETE SUCCESS [TABEL2] → removed row index: $index");

    // ---- Snackbar sukses ----
    _showDeleteSuccess("Baris ${index + 1} dihapus: \"$deletedSummary\"");
  }

  // CEK APAKAH ROW KOSONG
  bool _rowIsEmpty(List<TextEditingController> row) =>
      row.every((c) => c.text.trim().isEmpty);

  // SUMMARY TEXT
  String _summary(List<TextEditingController> row) {
    final s = row[0].text.trim();
    if (s.isEmpty) return "— kosong —";
    return s.length > 24 ? "${s.substring(0, 24)}…" : s;
  }

  // TOGGLE CARD
  void _toggleCard(int index) {
    final current = _openIndex;

    // Jika sedang buka card lain
    if (current != null && current != index) {
      final isOtherEmpty = _rowIsEmpty(_rows[current]);

      if (isOtherEmpty) {
        // tutup otomatis
        setState(() => _openIndex = index);
      } else {
        // jangan tutup card berisi data
        setState(() => _openIndex = index);
      }
      return;
    }

    // Jika buka/tutup card yang sama
    setState(() {
      _openIndex = (_openIndex == index) ? null : index;
    });
  }

  // LABEL CHIP
  Widget _labelChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFBEF8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // CONFIRM DELETE DIALOG
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
                "Hapus Baris?",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Text(
                "Apakah Anda yakin ingin menghapus baris ini?",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
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

  // SHOW DELETE SUCCESS SNACKBAR
  void _showDeleteSuccess(String msg) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx == null) {
      debugPrint("Overlay NULL → Snackbar gagal ditampilkan");
      return;
    }

    AppSnackbar.success(ctx, msg);
  }

  // SHOW DELETE ERROR SNACKBAR
  void _showDeleteError(String msg) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx == null) return;

    AppSnackbar.error(ctx, msg);
  }

  // ===================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    // LABELS
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            const Text(
              "TABEL 2 — TARGET TRIWULAN",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _labelChip("${_rows.length} baris"),
          ],
        ),

        const SizedBox(height: 12),

        // LIST OF CARDS
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (context, i) {
            final row = _rows[i];
            final ctrl = row[0];

            // AUTO ADD ROW WHEN LAST ROW TYPED
            ctrl.addListener(() {
              final isLast = i == _rows.length - 1;
              if (isLast && row.any((c) => c.text.trim().isNotEmpty)) {
                if (_rows.last.any((c) => c.text.trim().isNotEmpty)) {
                  _addRow();
                }
              }
              setState(() {}); // refresh summary
            });
            // TOGGLE CARD
            return _TriwulanCardItem(
              index: i,
              isOpen: _openIndex == i,
              isEmpty: _rowIsEmpty(row),
              headerSummary: _summary(row),
              onToggle: () => _toggleCard(i),
              onDelete: () => _deleteRow(i),
              child: Column(
                children: [
                  _input("Sasaran", row[0]), // Sasaran
                  const SizedBox(height: 8),
                  _input("Indikator", row[1]), // Indikator
                  const SizedBox(height: 8),
                  _input("Target", row[2]), // Target
                  const SizedBox(height: 8),
                  _input("Triwulan I", row[3]), // Triwulan I
                  const SizedBox(height: 8),
                  _input("Triwulan II", row[4]), // Triwulan II
                  const SizedBox(height: 8),
                  _input("Triwulan III", row[5]), // Triwulan III
                  const SizedBox(height: 8),
                  _input("Triwulan IV", row[6]), // Triwulan IV
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // ADD ROW BUTTON
        TextButton.icon(
          onPressed: _addRow,
          icon: Icon(Icons.add, color: theme.primary),
          label: Text(
            "Tambah Baris",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // modern input style
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
          filled: true,
          fillColor: theme.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

//
extension ControllerSafeDispose on TextEditingController {
  bool get isClosed {
    try {
      // akses apapun yang memerlukan controller hidup
      text;
      return false; // tidak error → belum disposed
    } catch (_) {
      return true; // error → sudah disposed
    }
  }
}

// ===================================================================
// CARD WIDGET
// ===================================================================
class _TriwulanCardItem extends StatefulWidget {
  final int index;
  final String headerSummary;
  final bool isOpen;
  final bool isEmpty;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Widget child;

  const _TriwulanCardItem({
    required this.index,
    required this.headerSummary,
    required this.isOpen,
    required this.isEmpty,
    required this.onToggle,
    required this.onDelete,
    required this.child,
  });

  @override
  State<_TriwulanCardItem> createState() => _TriwulanCardItemState();
}

class _TriwulanCardItemState extends State<_TriwulanCardItem>
    with TickerProviderStateMixin {
  late final AnimationController _rotation;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.isOpen ? 0.0 : 0.5,
    );
  }

  @override
  void didUpdateWidget(covariant _TriwulanCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      widget.isOpen ? _rotation.reverse() : _rotation.forward();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  // ===================================================================
  @override
  Widget build(BuildContext context) {
    // CARD
    return Card(
      color: Color(0xFFBEF8FF),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        child: Column(
          // HEADER & CHILDREN
          children: [
            InkWell(
              onTap: widget.onToggle,
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
                    // NUMBER CHIP
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${widget.index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(width: 12),
                    // SUMMARY TEXT
                    Expanded(
                      child: Text(
                        widget.headerSummary,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // DELETE BUTTON
                    // if (widget.isEmpty)
                    IconButton(
                      onPressed: () async {
                        final ok =
                            await (context
                                    .findAncestorStateOfType<
                                      _CardTable2WidgetState
                                    >()
                                    ?.showConfirmDeleteDialog(context) ??
                                Future.value(false));

                        if (ok) widget.onDelete();
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE74C3C),
                      ),
                      splashRadius: 20,
                    ),

                    // ARROW ICON
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_rotation),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),

            // CHILD CONTENT
            if (widget.isOpen)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: widget.child,
              ),
          ],
        ),
      ),
    );
  }
}
