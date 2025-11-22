import 'package:flutter/material.dart';

// ============================
// CARD TABLE 1 (SASARAN / INDIKATOR / TARGET / FORMULASI / SUMBER)
// ============================
class CardTable1Widget extends StatelessWidget {
  final List<List<TextEditingController>> rows;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  const CardTable1Widget({
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
        // header label
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "TABEL 1 — INDIKATOR",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // each row as a Card
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
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NO
                        SizedBox(
                          width: 40,
                          child: Center(child: Text('${i + 1}')),
                        ),

                        const SizedBox(width: 8),

                        // SASARAN
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: rows[i][0],
                            decoration: const InputDecoration(
                              labelText: "SASARAN",
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

                        // delete button (appears if row empty & not the only one)
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

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // indikator
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: rows[i][1],
                            decoration: const InputDecoration(
                              labelText: "INDIKATOR KINERJA",
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
                        // target
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: rows[i][2],
                            decoration: const InputDecoration(
                              labelText: "TARGET",
                              isDense: true,
                            ),
                            onChanged: (_) {
                              if (i == rows.length - 1 &&
                                  rows[i].any((c) => c.text.trim().isNotEmpty))
                                onAddRow();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // formulasi
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: rows[i][3],
                            decoration: const InputDecoration(
                              labelText: "FORMULASI HITUNG",
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
                        // sumber data
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: rows[i][4],
                            decoration: const InputDecoration(
                              labelText: "SUMBER DATA",
                              isDense: true,
                            ),
                            onChanged: (_) {
                              if (i == rows.length - 1 &&
                                  rows[i].any((c) => c.text.trim().isNotEmpty))
                                onAddRow();
                            },
                          ),
                        ),
                      ],
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
