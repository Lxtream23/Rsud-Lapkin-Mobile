// lib/presentation/widgets/card_table1.dart
import 'package:flutter/material.dart';

class CardTable1Widget extends StatefulWidget {
  const CardTable1Widget({super.key});

  @override
  State<CardTable1Widget> createState() => _CardTable1WidgetState();
}

class _CardTable1WidgetState extends State<CardTable1Widget>
    with TickerProviderStateMixin {
  // tiap baris punya 5 kolom: Sasaran, Indikator, Target, Formulasi, Sumber
  final List<List<TextEditingController>> _rows = [];

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

  // -------------------------------------------------------------------
  // ROW MANAGEMENT
  // -------------------------------------------------------------------
  void _addRow() {
    setState(() {
      _rows.add(List.generate(5, (_) => TextEditingController()));
    });
  }

  void _deleteRow(int index) {
    if (index == 0 && _rows.length == 1) {
      // jangan hapus baris terakhir jika cuma satu; cukup clear
      for (final c in _rows.first) c.clear();
      setState(() {});
      return;
    }
    for (final c in _rows[index]) c.dispose();
    setState(() {
      _rows.removeAt(index);
    });
  }

  List<List<String>> getRowsAsStrings() {
    return _rows.map((r) => r.map((c) => c.text.trim()).toList()).toList();
  }

  bool _rowIsEmpty(List<TextEditingController> row) =>
      row.every((c) => c.text.trim().isEmpty);

  // ringkasan: ambil teks kolom pertama, potong jika panjang
  String _summaryForRow(List<TextEditingController> row) {
    final s = row[0].text.trim();
    if (s.isEmpty) return '— kosong —';
    return s.length > 30 ? '${s.substring(0, 30)}…' : s;
  }

  Widget _labelChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- HEADER ----------
        Row(
          children: [
            const Text(
              "TABEL 1 — SASARAN & INDIKATOR",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _labelChip("${_rows.length} baris"),
          ],
        ),
        const SizedBox(height: 12),

        // ---------- LIST CARD ----------
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (context, i) {
            final row = _rows[i];
            final controller = row[0];
            // controller listener untuk auto-add
            controller.addListener(() {
              final isLast = i == _rows.length - 1;
              if (isLast && row.any((c) => c.text.trim().isNotEmpty)) {
                // tambahkan baris baru (safe: hanya sekali)
                final anyNotEmpty = _rows.last.any(
                  (c) => c.text.trim().isNotEmpty,
                );
                if (anyNotEmpty) _addRow();
              }
              // rebuild so summary updates
              setState(() {});
            });

            return _TableCard(
              index: i,
              headerSummary: _summaryForRow(row),
              isEmpty: _rowIsEmpty(row),
              onDelete: () => _deleteRow(i),
              child: Column(
                children: [
                  _inputField("Sasaran", row[0]),
                  const SizedBox(height: 8),
                  _inputField("Indikator Kinerja", row[1]),
                  const SizedBox(height: 8),
                  _inputField("Target", row[2]),
                  const SizedBox(height: 8),
                  _inputField("Formulasi Hitung", row[3]),
                  const SizedBox(height: 8),
                  _inputField("Sumber Data", row[4]),
                ],
              ),
            );
          },
        ),

        // ---------- BUTTON TAMBAH BARIS ----------
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addRow,
            icon: Icon(Icons.add, color: theme.primary),
            label: Text(
              "Tambah Baris",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

// *********************************************************************
// *                           CARD WIDGET                             *
// *********************************************************************
class _TableCard extends StatefulWidget {
  final int index;
  final String headerSummary;
  final Widget child;
  final VoidCallback onDelete;
  final bool isEmpty;

  const _TableCard({
    required this.index,
    required this.headerSummary,
    required this.child,
    required this.onDelete,
    required this.isEmpty,
  });

  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard> with TickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.5,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _rotationController.reverse();
      } else {
        _rotationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
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
                    // delete icon: tampilkan hanya jika row empty and more than one
                    if (widget.isEmpty)
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                        ),
                        splashRadius: 20,
                      ),
                    RotationTransition(
                      turns: Tween(
                        begin: 0.0,
                        end: 0.5,
                      ).animate(_rotationController),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),
            if (_open)
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
