import 'package:flutter/material.dart';

// ============================
// CARD TRI WULAN (special layout simulating merged header)
// ============================
class CardTable2Widget extends StatelessWidget {
  final List<List<TextEditingController>> rows;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  const CardTable2Widget({
    required this.rows,
    required this.onAddRow,
    required this.onDeleteRow,
    Key? key,
  }) : super(key: key);

  bool _isRowEmpty(List<TextEditingController> r) =>
      r.every((c) => c.text.trim().isEmpty);

  @override
  Widget build(BuildContext context) {
    // fixed widths per column (approximate) — on small screens they'll wrap horizontally via SingleChildScrollView in parent
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "TABEL 3 - TRIWULAN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // header card (visual merged)
        Card(
          color: Colors.grey.shade100,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      "SASARAN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      "INDIKATOR KINERJA",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "TARGET",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      "TARGET TRIWULAN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),

        // rows as cards
        for (int i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // main row
                    Row(
                      children: [
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
                        // INDIKATOR
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: rows[i][1],
                            decoration: const InputDecoration(
                              labelText: "INDIKATOR",
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
                        // TARGET
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
                        const SizedBox(width: 8),
                        // FOUR small quarter fields I..IV
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: rows[i][3],
                                  decoration: const InputDecoration(
                                    labelText: "I",
                                    isDense: true,
                                  ),
                                  onChanged: (_) {
                                    if (i == rows.length - 1 &&
                                        rows[i].any(
                                          (c) => c.text.trim().isNotEmpty,
                                        ))
                                      onAddRow();
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: rows[i][4],
                                  decoration: const InputDecoration(
                                    labelText: "II",
                                    isDense: true,
                                  ),
                                  onChanged: (_) {
                                    if (i == rows.length - 1 &&
                                        rows[i].any(
                                          (c) => c.text.trim().isNotEmpty,
                                        ))
                                      onAddRow();
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: rows[i][5],
                                  decoration: const InputDecoration(
                                    labelText: "III",
                                    isDense: true,
                                  ),
                                  onChanged: (_) {
                                    if (i == rows.length - 1 &&
                                        rows[i].any(
                                          (c) => c.text.trim().isNotEmpty,
                                        ))
                                      onAddRow();
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: rows[i][6],
                                  decoration: const InputDecoration(
                                    labelText: "IV",
                                    isDense: true,
                                  ),
                                  onChanged: (_) {
                                    if (i == rows.length - 1 &&
                                        rows[i].any(
                                          (c) => c.text.trim().isNotEmpty,
                                        ))
                                      onAddRow();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // delete icon (when row empty and >1 row)
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
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
