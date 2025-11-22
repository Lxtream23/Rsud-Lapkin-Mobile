import 'package:flutter/material.dart';

class CardTable2Widget extends StatelessWidget {
  final List<List<TextEditingController>> data;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  const CardTable2Widget({
    super.key,
    required this.data,
    required this.onAddRow,
    required this.onDeleteRow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildHeader(),
        const SizedBox(height: 8),

        // =============================
        // LIST CARD PER BARIS
        // =============================
        for (int i = 0; i < data.length; i++)
          _buildCardRow(context, i, data[i]),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return Card(
      color: Colors.blueGrey.shade50,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "TABEL 2 — TARGET TRIWULAN",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Sasaran • Indikator Kinerja • Target • Triwulan I–IV",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD PER BARIS
  // ============================================================
  Widget _buildCardRow(
    BuildContext context,
    int index,
    List<TextEditingController> row,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================
            // ROW TITLE + BUTTON DELETE
            // ============================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Baris ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                // tombol hapus kecuali baris pertama
                if (index > 0)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 22,
                    ),
                    onPressed: () => onDeleteRow(index),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            _field("Sasaran", row[0], index),
            _field("Indikator Kinerja", row[1], index),
            _field("Target", row[2], index),

            const Divider(height: 20),

            const Text(
              "Target Tiap Triwulan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _field("Triwulan I", row[3], index),
            _field("Triwulan II", row[4], index),
            _field("Triwulan III", row[5], index),
            _field("Triwulan IV", row[6], index),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE FIELD
  // ============================================================
  Widget _field(String title, TextEditingController controller, int rowIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (v) {
          if (rowIndex == data.length - 1 && v.trim().isNotEmpty) {
            onAddRow();
          }
        },
      ),
    );
  }
}
