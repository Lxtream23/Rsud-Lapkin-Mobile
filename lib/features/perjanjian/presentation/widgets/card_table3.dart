import 'package:flutter/material.dart';

class CardTable3Widget extends StatefulWidget {
  const CardTable3Widget({super.key});

  @override
  State<CardTable3Widget> createState() => _CardTable3WidgetState();
}

class RowItem {
  String program = "";
  String anggaran = "";
  String keterangan = "";
  int level = 0; // 0 = induk, 1 = sublevel
  String nomor = ""; // auto generated
}

class _CardTable3WidgetState extends State<CardTable3Widget> {
  final List<RowItem> items = [];

  @override
  void initState() {
    super.initState();
    items.add(RowItem());
  }

  // ============================================================
  // AUTO NUMBERING MODEL C
  // ============================================================
  void generateNumbers() {
    int mainIndex = 0;
    int subIndex = 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.level == 0) {
        mainIndex++;
        subIndex = 0;
        item.nomor = "$mainIndex";
      } else {
        subIndex++;
        item.nomor = "$mainIndex.$subIndex";
      }
    }
  }

  // ============================================================
  // EXPORT KE PDF
  // ============================================================
  List<Map<String, dynamic>> getRowsForPdf() {
    generateNumbers();

    final list = <Map<String, dynamic>>[];
    double total = 0;

    for (final item in items) {
      final angka =
          double.tryParse(
            item.anggaran.replaceAll(".", "").replaceAll(",", ""),
          ) ??
          0;
      total += angka;

      list.add({
        "no": item.nomor,
        "program": item.program,
        "anggaran": item.anggaran,
        "keterangan": item.keterangan,
      });
    }

    list.add({
      "no": "",
      "program": "JUMLAH",
      "anggaran": total.toStringAsFixed(2),
      "keterangan": "",
      "isTotal": true,
    });

    return list;
  }

  // ============================================================
  // ADD ROW
  // ============================================================
  void addRow({bool asSub = false}) {
    setState(() {
      items.add(RowItem()..level = asSub ? 1 : 0);
      generateNumbers();
    });
  }

  // DELETE
  void deleteRow(int index) {
    if (items.length == 1) {
      setState(() {
        items.first
          ..program = ""
          ..anggaran = ""
          ..keterangan = ""
          ..level = 0;
      });
      return;
    }

    setState(() {
      items.removeAt(index);
      generateNumbers();
    });
  }

  // ============================================================
  // BUILD UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    generateNumbers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TABEL PROGRAM & ANGGARAN",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // ============================================================
        // REORDERABLE LIST (drag & sort)
        // ============================================================
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              generateNumbers();
            });
          },
          itemBuilder: (context, i) {
            final item = items[i];

            return Card(
              key: ValueKey(i),
              color: item.level == 0
                  ? const Color(0xFFBEF8FF)
                  : const Color(0xFFDDF7FF),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.nomor,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            item.program.isEmpty ? "— kosong —" : item.program,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => deleteRow(i),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // INPUT
                    inputField("Program", item.program, (v) {
                      setState(() => item.program = v);
                    }),
                    const SizedBox(height: 10),

                    inputField("Anggaran", item.anggaran, (v) {
                      setState(() => item.anggaran = v);
                    }),
                    const SizedBox(height: 10),

                    inputField("Keterangan", item.keterangan, (v) {
                      setState(() => item.keterangan = v);
                    }),

                    const SizedBox(height: 10),

                    // BUTTONS SUBLEVEL
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => addRow(asSub: true),
                          icon: const Icon(Icons.subdirectory_arrow_right),
                          label: const Text("Tambah Sub"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // ADD MAIN ROW
        TextButton.icon(
          onPressed: () => addRow(asSub: false),
          icon: Icon(Icons.add, color: theme.primary),
          label: Text(
            "Tambah Baris Utama",
            style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget inputField(String label, String value, Function(String) onChanged) {
    final theme = Theme.of(context).colorScheme;
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      minLines: 1,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      onChanged: onChanged,
    );
  }
}
