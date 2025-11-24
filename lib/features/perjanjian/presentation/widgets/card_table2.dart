// lib/presentation/widgets/card_table2.dart
import 'package:flutter/material.dart';

class CardTable2Widget extends StatefulWidget {
  const CardTable2Widget({super.key});

  @override
  State<CardTable2Widget> createState() => _CardTable2WidgetState();
}

class _CardTable2WidgetState extends State<CardTable2Widget>
    with TickerProviderStateMixin {
  // masing-masing baris: 7 kolom (Sasaran, Indikator, Target, I, II, III, IV)
  final List<List<TextEditingController>> _rows = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (final r in _rows) for (final c in r) c.dispose();
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(List.generate(7, (_) => TextEditingController()));
    });
  }

  void _deleteRow(int index) {
    if (index == 0 && _rows.length == 1) {
      for (final c in _rows.first) c.clear();
      setState(() {});
      return;
    }
    for (final c in _rows[index]) c.dispose();
    setState(() => _rows.removeAt(index));
  }

  List<List<String>> getRowsAsStrings() {
    return _rows.map((r) => r.map((c) => c.text.trim()).toList()).toList();
  }

  bool _rowEmpty(List<TextEditingController> r) =>
      r.every((c) => c.text.trim().isEmpty);

  String _summary(List<TextEditingController> r) {
    final s = r[0].text.trim();
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

  @override
  Widget build(BuildContext context) {
    final labels = [
      'Sasaran',
      'Indikator Kinerja',
      'Target',
      'Triwulan I',
      'Triwulan II',
      'Triwulan III',
      'Triwulan IV',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "TABEL 2 — TARGET TRIWULAN",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _labelChip("${_rows.length} baris"),
          ],
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (context, i) {
            final row = _rows[i];

            // attach listener on first column to update summary and auto-add
            row[0].addListener(() {
              final isLast = i == _rows.length - 1;
              if (isLast && row.any((c) => c.text.trim().isNotEmpty)) _addRow();
              setState(() {});
            });

            return _TableCardTriwulan(
              index: i,
              headerSummary: _summary(row),
              isEmpty: _rowEmpty(row),
              onDelete: () => _deleteRow(i),
              labels: labels,
              rowControllers: row,
              onAnyFieldChanged: () {
                // jika mengetik di baris terakhir pada salah satu field, auto add
                if (i == _rows.length - 1 &&
                    row.any((c) => c.text.trim().isNotEmpty)) {
                  _addRow();
                }
              },
            );
          },
        ),
      ],
    );
  }
}

// Card khusus untuk triwulan
class _TableCardTriwulan extends StatefulWidget {
  final int index;
  final String headerSummary;
  final bool isEmpty;
  final VoidCallback onDelete;
  final List<String> labels;
  final List<TextEditingController> rowControllers;
  final VoidCallback onAnyFieldChanged;

  const _TableCardTriwulan({
    required this.index,
    required this.headerSummary,
    required this.isEmpty,
    required this.onDelete,
    required this.labels,
    required this.rowControllers,
    required this.onAnyFieldChanged,
  });

  @override
  State<_TableCardTriwulan> createState() => _TableCardTriwulanState();
}

class _TableCardTriwulanState extends State<_TableCardTriwulan>
    with TickerProviderStateMixin {
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

  void _toggleOpen() {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            InkWell(
              onTap: _toggleOpen,
              borderRadius: BorderRadius.circular(14),
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
                        borderRadius: BorderRadius.circular(8),
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
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
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
                child: Column(
                  children: [
                    for (int i = 0; i < widget.labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: widget.rowControllers[i],
                          decoration: InputDecoration(
                            labelText: widget.labels[i],
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => widget.onAnyFieldChanged(),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
