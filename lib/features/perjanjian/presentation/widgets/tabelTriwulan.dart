import 'package:flutter/material.dart';

class TabelTriwulanWidgets extends StatelessWidget {
  final List<List<TextEditingController>> data;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  const TabelTriwulanWidgets({
    super.key,
    required this.data,
    required this.onAddRow,
    required this.onDeleteRow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final fixed = [
          200, // SASARAN
          200, // INDIKATOR
          120, // TARGET
          90, // I
          90, // II
          90, // III
          90, // IV
          50, // DELETE BUTTON
        ];

        final totalFixed = fixed.reduce((a, b) => a + b);
        final scale = (availableWidth > totalFixed)
            ? (availableWidth / totalFixed)
            : 1.0;

        final col = fixed.map((w) => w * scale).toList();
        final minWidth = col.reduce((a, b) => a + b);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow1(col),
                _buildHeaderRow2(col),
                for (int r = 0; r < data.length; r++)
                  _buildDataRow(r, data[r], col),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER ROW 1
  // ============================================================
  Widget _buildHeaderRow1(List<double> col) {
    return Row(
      children: [
        _headerCell("SASARAN", col[0], 60, bottom: false),
        _headerCell("INDIKATOR KINERJA", col[1], 60, bottom: false),
        _headerCell("TARGET", col[2], 60, bottom: false),
        Container(
          width: col[3] + col[4] + col[5] + col[6],
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border(
              top: BorderSide(color: Colors.grey.shade400, width: 1),
              left: BorderSide(color: Colors.grey.shade400, width: 1),
              right: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
          ),
          child: const Text(
            "TARGET TRIWULAN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: col[7],
          height: 60,
          decoration: const BoxDecoration(
            // color: Colors.grey, // boleh diganti jika mau
            border: Border(), // TANPA BORDER
          ),
        ),
        // kolom delete
      ],
    );
  }

  // ============================================================
  // HEADER ROW 2
  // ============================================================
  Widget _buildHeaderRow2(List<double> col) {
    return Row(
      children: [
        _emptyCell(col[0], 30),
        _emptyCell(col[1], 30),
        _emptyCell(col[2], 30),
        for (final label in ["I", "II", "III", "IV"])
          _headerCell(label, col[3], 30),
        Container(
          width: col[7],
          height: 30,
          decoration: const BoxDecoration(
            // color: Colors.grey, // sama dengan header lainnya
            border: Border(), // TANPA BORDER
          ),
        ),
        // kolom delete
      ],
    );
  }

  // ============================================================
  // DATA ROW
  // ============================================================
  Widget _buildDataRow(
    int r,
    List<TextEditingController> row,
    List<double> col,
  ) {
    return Row(
      children: [
        for (int c = 0; c < 7; c++)
          Container(
            width: col[c],
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade400, width: 1),
                right: BorderSide(color: Colors.grey.shade400, width: 1),
                bottom: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
            ),
            child: TextField(
              controller: row[c],
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) {
                if (r == data.length - 1 && v.trim().isNotEmpty) {
                  onAddRow();
                }
              },
            ),
          ),

        // ==================================================
        // KOLOM DELETE BUTTON
        // ==================================================
        Container(
          width: col[7],
          height: 50,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide.none,
              right: BorderSide.none,
              top: BorderSide.none,
              bottom: BorderSide.none,
            ),
          ),
          child: r == 0
              ? const SizedBox()
              : IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 22),
                  onPressed: () => onDeleteRow(r),
                ),
        ),
      ],
    );
  }

  // ============================================================
  // REUSABLE WIDGETS
  // ============================================================

  Widget _headerCell(String text, double w, double h, {bool bottom = true}) {
    return Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(
          top: BorderSide(color: Colors.grey.shade400, width: 1),
          left: BorderSide(color: Colors.grey.shade400, width: 1),
          right: BorderSide(color: Colors.grey.shade400, width: 1),
          bottom: bottom
              ? BorderSide(color: Colors.grey.shade400, width: 1)
              : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _emptyCell(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(
          left: BorderSide(color: Colors.grey.shade400, width: 1),
          right: BorderSide(color: Colors.grey.shade400, width: 1),
          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
    );
  }
}
