// lib/presentation/widgets/card_table3.dart
import 'package:flutter/material.dart';

class CardTable3Widget extends StatefulWidget {
  const CardTable3Widget({super.key});

  @override
  State<CardTable3Widget> createState() => _CardTable3WidgetState();
}

class _CardTable3WidgetState extends State<CardTable3Widget>
    with TickerProviderStateMixin {
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
  void _addRow() {
    setState(() {
      _rows.add(List.generate(3, (_) => TextEditingController()));
    });
  }

  void _deleteRow(int index) {
    debugPrint("[TABEL3] Request delete row index=$index");

    // --- Validasi Index ---
    if (index < 0 || index >= _rows.length) {
      debugPrint("[TABEL3] ❌ ERROR: index out of range. Tidak jadi hapus.");
      return;
    }

    // --- Kasus: hanya ada 1 baris, jangan hapus hanya kosongkan ---
    if (_rows.length == 1) {
      debugPrint("[TABEL3] Hanya satu baris. Membersihkan saja...");
      for (final c in _rows.first) {
        try {
          c.clear();
        } catch (e) {
          debugPrint("[TABEL3] ❌ Error clear controller: $e");
        }
      }
      setState(() {});
      return;
    }

    // --- Hapus baris normal ---
    final removed = _rows[index];

    debugPrint(
      "[TABEL3] Menghapus row ke-$index "
      "(kolom: ${removed.length} controller).",
    );

    // dispose tiap controller dengan aman
    for (final c in removed) {
      try {
        c.dispose(); // aman, tidak perlu isDisposed
      } catch (e) {
        debugPrint("[TABEL3] ❌ Error dispose controller: $e");
      }
    }

    setState(() {
      _rows.removeAt(index);

      // tutup card jika yang terbuka adalah index ini
      if (_openIndex == index) {
        debugPrint("[TABEL3] Menutup card karena baris dihapus.");
        _openIndex = null;
      }
      // Geser openIndex jika index card bergeser akibat penghapusan
      else if (_openIndex != null && _openIndex! > index) {
        _openIndex = _openIndex! - 1;
      }
    });

    debugPrint("[TABEL3] Row berhasil dihapus. Sisa baris: ${_rows.length}");
  }

  bool _rowIsEmpty(List<TextEditingController> row) =>
      row.every((c) => c.text.trim().isEmpty);

  String _summary(List<TextEditingController> row) {
    final s = row[0].text.trim();
    if (s.isEmpty) return '— kosong —';
    return s.length > 30 ? '${s.substring(0, 30)}…' : s;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    // LABEL CHIP
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            const Text(
              "TABEL 3 — PROGRAM & ANGGARAN",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            return _CardSmallAccordion(
              index: i,
              isOpen: _openIndex == i,
              isEmpty: _rowIsEmpty(row),
              headerSummary: _summary(row),
              onToggle: () => _toggleCard(i),
              onDelete: () => _deleteRow(i),
              child: Column(
                children: [
                  _input("Program", row[0]), // Program
                  const SizedBox(height: 10),
                  _input("Anggaran", row[1]), // Anggaran
                  const SizedBox(height: 10),
                  _input("Keterangan", row[2]), // Keterangan
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        TextButton.icon(
          onPressed: _addRow,
          icon: Icon(Icons.add, color: theme.primary),
          label: Text(
            "Tambah Baris",
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.primary),
          ),
        ),
      ],
    );
  }

  // modern input style
  Widget _input(String label, TextEditingController ctrl) {
    final theme = Theme.of(context).colorScheme;

    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
        ),
      ),
    );
  }
}

// ===================================================================
// CARD WIDGET
// ===================================================================
class _CardSmallAccordion extends StatefulWidget {
  final int index;
  final String headerSummary;
  final bool isEmpty;
  final bool isOpen;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final Widget child;

  const _CardSmallAccordion({
    required this.index,
    required this.headerSummary,
    required this.isEmpty,
    required this.isOpen,
    required this.onDelete,
    required this.onToggle,
    required this.child,
  });

  @override
  State<_CardSmallAccordion> createState() => _CardSmallAccordionState();
}

class _CardSmallAccordionState extends State<_CardSmallAccordion>
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
  void didUpdateWidget(covariant _CardSmallAccordion oldWidget) {
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
          children: [
            // HEADER & CHILDREN
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
                                      _CardTable3WidgetState
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
                    // Arrow icon
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_rotation),
                      child: const Icon(Icons.keyboard_arrow_down),
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
