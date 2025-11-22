import 'package:flutter/material.dart';

class CardTable3Widget extends StatelessWidget {
  final List<List<TextEditingController>> data;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  const CardTable3Widget({
    super.key,
    required this.data,
    required this.onAddRow,
    required this.onDeleteRow,
  });

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

        /// LIST CARD
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (_, index) => _buildCard(context, index),
        ),
      ],
    );
  }

  // ============================================================
  // CARD ITEM
  // ============================================================
  Widget _buildCard(BuildContext context, int index) {
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
                /// NO
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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

                /// DELETE
                if (index > 0)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 24,
                    ),
                    onPressed: () => onDeleteRow(index),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            /// FIELDS
            _field("Program", data[index][0]),
            _field("Anggaran", data[index][1]),
            _field("Keterangan", data[index][2]),

            const SizedBox(height: 6),

            /// AUTO ADD ROW
            _autoAddTrigger(index),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FIELD INPUT
  // ------------------------------------------------------------
  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // AUTO ADD TEXT
  // ------------------------------------------------------------
  Widget _autoAddTrigger(int index) {
    return TextField(
      decoration: const InputDecoration(border: InputBorder.none),
      onChanged: (v) {
        if (index == data.length - 1 && v.trim().isNotEmpty) {
          onAddRow();
        }
      },
    );
  }
}
