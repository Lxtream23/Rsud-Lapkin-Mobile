import 'package:flutter/material.dart';

class CardTable1Widget extends StatefulWidget {
  const CardTable1Widget({super.key});

  @override
  State<CardTable1Widget> createState() => _CardTable1WidgetState();
}

class _CardTable1WidgetState extends State<CardTable1Widget> {
  List<List<TextEditingController>> rows = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (final r in rows) {
      for (final c in r) c.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // ROW MANAGEMENT
  // ============================================================
  void _addRow() {
    setState(() {
      rows.add(List.generate(5, (_) => TextEditingController()));
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
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TABEL 1 — SASARAN & INDIKATOR",
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

  // ============================================================
  // CARD ROW
  // ============================================================
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
                // Number
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

                // Delete button
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

            _input("Sasaran", rows[index][0], index),
            _input("Indikator Kinerja", rows[index][1], index),
            _input("Target", rows[index][2], index),
            _input("Formulasi Hitung", rows[index][3], index),
            _input("Sumber Data", rows[index][4], index),
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
