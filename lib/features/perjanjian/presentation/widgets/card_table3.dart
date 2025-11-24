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
    setState(() => _rows.add(List.generate(3, (_) => TextEditingController())));
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

  bool _rowEmpty(List<TextEditingController> row) =>
      row.every((c) => c.text.trim().isEmpty);

  String _summary(List<TextEditingController> row) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (context, i) {
            final r = _rows[i];
            r[0].addListener(() {
              final isLast = i == _rows.length - 1;
              if (isLast && r.any((c) => c.text.trim().isNotEmpty)) _addRow();
              setState(() {});
            });
            return _TableCardSmall(
              index: i,
              headerSummary: _summary(r),
              isEmpty: _rowEmpty(r),
              onDelete: () => _deleteRow(i),
              child: Column(
                children: [
                  _input("Program", r[0]),
                  const SizedBox(height: 8),
                  _input("Anggaran", r[1]),
                  const SizedBox(height: 8),
                  _input("Keterangan", r[2]),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) {},
    );
  }
}

class _TableCardSmall extends StatefulWidget {
  final int index;
  final String headerSummary;
  final Widget child;
  final VoidCallback onDelete;
  final bool isEmpty;

  const _TableCardSmall({
    required this.index,
    required this.headerSummary,
    required this.child,
    required this.onDelete,
    required this.isEmpty,
  });

  @override
  State<_TableCardSmall> createState() => _TableCardSmallState();
}

class _TableCardSmallState extends State<_TableCardSmall>
    with TickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _rot;

  @override
  void initState() {
    super.initState();
    _rot = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.5,
    );
  }

  @override
  void dispose() {
    _rot.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open)
        _rot.reverse();
      else
        _rot.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.8,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
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
                      turns: Tween(begin: 0.0, end: 0.5).animate(_rot),
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
