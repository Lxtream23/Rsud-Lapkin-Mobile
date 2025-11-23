import 'package:flutter/material.dart';

class CardTable3Widget extends StatefulWidget {
  const CardTable3Widget({super.key});

  @override
  State<CardTable3Widget> createState() => _CardTable3WidgetState();
}

class _CardTable3WidgetState extends State<CardTable3Widget> {
  List<List<TextEditingController>> rows = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (var r in rows) {
      for (var c in r) c.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // ROW MANAGEMENT
  // ============================================================
  void _addRow() {
    setState(() {
      rows.add(List.generate(3, (_) => TextEditingController()));
    });
  }

  void _deleteRow(int index) {
    if (index == 0) return;
    setState(() {
      for (var ctrl in rows[index]) ctrl.dispose();
      rows.removeAt(index);
    });
  }

  List<List<String>> getRowsAsStrings() {
    return rows.map((row) => row.map((c) => c.text.trim()).toList()).toList();
  }

  // ============================================================
  // BUILD WIDGET
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TABEL 3 — PROGRAM & ANGGARAN",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          itemBuilder: (_, index) => _buildCard(index),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // NO
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                if (index > 0)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () => _deleteRow(index),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            _input("Program", rows[index][0], index),
            _input("Anggaran", rows[index][1], index),
            _input("Keterangan", rows[index][2], index),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, int rowIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (_) {
          if (rowIndex == rows.length - 1 &&
              rows[rowIndex].every((c) => c.text.trim().isNotEmpty)) {
            _addRow();
          }
        },
      ),
    );
  }
}
