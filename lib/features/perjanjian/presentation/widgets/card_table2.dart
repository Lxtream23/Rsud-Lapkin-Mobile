import 'package:flutter/material.dart';

class CardTable2Widget extends StatefulWidget {
  const CardTable2Widget({super.key});

  @override
  State<CardTable2Widget> createState() => _CardTable2WidgetState();
}

class _CardTable2WidgetState extends State<CardTable2Widget> {
  List<List<TextEditingController>> rows = [];

  final labels = [
    "Sasaran",
    "Indikator Kinerja",
    "Target",
    "Triwulan I",
    "Triwulan II",
    "Triwulan III",
    "Triwulan IV",
  ];

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

  void _addRow() {
    setState(() {
      rows.add(List.generate(7, (_) => TextEditingController()));
    });
  }

  void _deleteRow(int index) {
    if (index == 0) return;
    setState(() {
      for (var c in rows[index]) c.dispose();
      rows.removeAt(index);
    });
  }

  List<List<String>> getRowsAsStrings() {
    return rows.map((r) => r.map((c) => c.text.trim()).toList()).toList();
  }

  // ========================
  // BUILD UI
  // ========================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TABEL 2 — TARGET TRIWULAN",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          itemBuilder: (_, i) => _buildCard(i),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.teal.shade50,
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteRow(index),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            for (int i = 0; i < 7; i++)
              _input(labels[i], rows[index][i], index),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (_) {
          if (index == rows.length - 1 &&
              rows[index].every((c) => c.text.trim().isNotEmpty)) {
            _addRow();
          }
        },
      ),
    );
  }
}
