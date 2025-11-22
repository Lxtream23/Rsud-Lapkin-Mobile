import 'package:flutter/material.dart';

// ============================
// CARD TABLE 3 (PROGRAM / ANGGARAN / KETERANGAN)
// ============================
class CardTable3Widget extends StatelessWidget {
  final List<List<TextEditingController>> rows;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  const CardTable3Widget({
    required this.rows,
    required this.onAddRow,
    required this.onDeleteRow,
    Key? key,
  }) : super(key: key);

  bool _isRowEmpty(List<TextEditingController> r) =>
      r.every((c) => c.text.trim().isEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "TABEL 3 — PROGRAM",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        for (int i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0,
                ),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Center(child: Text('${i + 1}'))),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: rows[i][0],
                        decoration: const InputDecoration(
                          labelText: "PROGRAM",
                          isDense: true,
                        ),
                        onChanged: (_) {
                          if (i == rows.length - 1 &&
                              rows[i].any((c) => c.text.trim().isNotEmpty))
                            onAddRow();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: rows[i][1],
                        decoration: const InputDecoration(
                          labelText: "ANGGARAN",
                          isDense: true,
                        ),
                        onChanged: (_) {
                          if (i == rows.length - 1 &&
                              rows[i].any((c) => c.text.trim().isNotEmpty))
                            onAddRow();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: rows[i][2],
                        decoration: const InputDecoration(
                          labelText: "KETERANGAN",
                          isDense: true,
                        ),
                        onChanged: (_) {
                          if (i == rows.length - 1 &&
                              rows[i].any((c) => c.text.trim().isNotEmpty))
                            onAddRow();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isRowEmpty(rows[i]) && rows.length > 1)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () => onDeleteRow(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
