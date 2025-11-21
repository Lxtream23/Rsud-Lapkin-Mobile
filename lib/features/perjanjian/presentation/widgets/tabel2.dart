import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Table2Widget extends StatefulWidget {
  const Table2Widget({super.key});

  @override
  State<Table2Widget> createState() => _Table2WidgetState();
}

class _Table2WidgetState extends State<Table2Widget> {
  // data = list baris; tiap baris = 3 kolom (PROGRAM, ANGGARAN, KETERANGAN)
  final List<List<TextEditingController>> rows = [];

  @override
  void initState() {
    super.initState();
    _addRow(); // mulai dengan 1 baris kosong
  }

  @override
  void dispose() {
    for (var row in rows) {
      for (var c in row) c.dispose();
    }
    super.dispose();
  }

  // tambah baris baru
  void _addRow() {
    setState(() {
      rows.add(List.generate(3, (_) => TextEditingController()));
    });
  }

  // hapus baris (hanya jika baris masih kosong)
  void _removeRow(int index) {
    setState(() {
      for (var c in rows[index]) c.dispose();
      rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade400;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(60),
            1: FixedColumnWidth(180),
            2: FixedColumnWidth(150),
            3: FixedColumnWidth(200),
            4: FixedColumnWidth(50), // tombol hapus
          },
          border: TableBorder.all(color: borderColor, width: 0.8),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // ---------------- HEADER ----------------
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                _Header("NO"),
                _Header("PROGRAM"),
                _Header("ANGGARAN"),
                _Header("KETERANGAN"),
                SizedBox(),
              ],
            ),

            // ---------------- DATA ----------------
            for (int r = 0; r < rows.length; r++)
              TableRow(
                children: [
                  _Body(center: Text("${r + 1}")),

                  // PROGRAM
                  _Body(field: _makeField(rows[r][0], r)),

                  // ANGGARAN
                  _Body(field: _makeField(rows[r][1], r)),

                  // KETERANGAN
                  _Body(field: _makeField(rows[r][2], r)),

                  // tombol hapus → hanya muncul jika baris kosong
                  _Body(
                    center: _isRowEmpty(rows[r])
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 22,
                            ),
                            onPressed: () => _removeRow(r),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // apakah seluruh kolom di baris kosong?
  bool _isRowEmpty(List<TextEditingController> row) {
    return row.every((c) => c.text.trim().isEmpty);
  }

  // textfield dengan logika auto-add row
  Widget _makeField(TextEditingController c, int rowIndex) {
    return TextField(
      controller: c,
      onChanged: (v) {
        // jika mengetik di baris terakhir → otomatis tambah baris
        if (rowIndex == rows.length - 1 && v.trim().isNotEmpty) {
          _addRow();
        }
      },
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }
}

// --------------------------------------------------------
// ---------------- SMALL UI HELPERS ----------------------
// --------------------------------------------------------

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AutoSizeText(
        text,
        maxLines: 2,
        minFontSize: 10,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Widget? field;
  final Widget? center;

  const _Body({this.field, this.center});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(height: 44, child: field ?? Center(child: center)),
    );
  }
}
