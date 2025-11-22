import 'package:flutter/material.dart';

class CardTable1Widget extends StatelessWidget {
  final List<List<TextEditingController>> data;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  const CardTable1Widget({
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
          "TABEL 1 — SASARAN & INDIKATOR",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (_, index) {
            return _buildCard(index, data[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCard(int index, List<TextEditingController> row) {
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

            _inputField("Sasaran", row[0]),
            _inputField("Indikator Kinerja", row[1]),
            _inputField("Target", row[2]),
            _inputField("Formulasi Hitung", row[3]),
            _inputField("Sumber Data", row[4]),

            const SizedBox(height: 6),

            _autoAddTrigger(index),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
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
      ),
    );
  }

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
