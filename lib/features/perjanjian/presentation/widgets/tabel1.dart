// lib/widgets/table1.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Table1Widget extends StatefulWidget {
  const Table1Widget({Key? key}) : super(key: key);

  @override
  State<Table1Widget> createState() => _Table1WidgetState();
}

class _Table1WidgetState extends State<Table1Widget> {
  // number of columns excluding NO
  static const int _cols = 5;

  // visible column widths (adjust if needed / match overall layout)
  final double _colWidth = 160;

  // controllers store
  final List<List<TextEditingController>> _rows = [];

  // helper to create a new empty row (with controllers)
  List<TextEditingController> _newRow() =>
      List.generate(_cols, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _ensureAtLeastOneRow();
  }

  void _ensureAtLeastOneRow() {
    if (_rows.isEmpty) {
      _rows.add(_newRow());
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    for (final r in _rows) {
      for (final c in r) {
        c.dispose();
      }
    }
    super.dispose();
  }

  // check if a row is completely empty (all cells empty or whitespace)
  bool _isRowEmpty(List<TextEditingController> row) {
    for (final c in row) {
      if (c.text.trim().isNotEmpty) return false;
    }
    return true;
  }

  // called when a cell changed — if editing last row then add new blank row
  void _onCellChanged(int rowIndex) {
    // if last row and has any non-empty cell, add a new row
    if (rowIndex == _rows.length - 1) {
      final anyNotEmpty = _rows[rowIndex].any((c) => c.text.trim().isNotEmpty);
      if (anyNotEmpty) {
        setState(() {
          _rows.add(_newRow());
        });
      }
    } else {
      // optional: if row becomes empty, show delete icon (UI will rebuild)
      setState(() {});
    }
  }

  // remove a row safely
  void _removeRow(int index) {
    if (index < 0 || index >= _rows.length) return;
    // don't remove last row if it's the only one — keep at least one row
    if (_rows.length == 1) {
      // clear it instead
      for (final c in _rows.first) c.clear();
      setState(() {});
      return;
    }

    // dispose controllers and remove
    for (final c in _rows[index]) c.dispose();
    setState(() {
      _rows.removeAt(index);
    });
  }

  Widget _tableHeaderCell(String text) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: AutoSizeText(
        text,
        maxLines: 2,
        minFontSize: 9,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRow(int rowIndex) {
    final row = _rows[rowIndex];
    final bool showDelete = _isRowEmpty(row) && _rows.length > 1;

    // cells for the row (NO + 5 input cells + optional delete icon cell)
    final List<Widget> cells = [];

    // NO
    cells.add(
      Container(
        width: 56,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey.shade400),
            right: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
          color: Colors.white,
        ),
        child: Text(
          '${rowIndex + 1}',
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );

    // input columns
    for (int c = 0; c < _cols; c++) {
      cells.add(
        Container(
          width: _colWidth,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade400),
              bottom: BorderSide(color: Colors.grey.shade400),
            ),
            color: Colors.white,
          ),
          child: TextField(
            controller: row[c],
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => _onCellChanged(rowIndex),
          ),
        ),
      );
    }

    // trailing delete icon - shown only when row empty and more than one row exists
    cells.add(
      Container(
        width: 48,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
          color: Colors.white,
        ),
        child: showDelete
            ? IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: () => _removeRow(rowIndex),
              )
            : const SizedBox.shrink(),
      ),
    );

    return Row(children: cells);
  }

  @override
  Widget build(BuildContext context) {
    _ensureAtLeastOneRow();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // NO header
                Container(
                  width: 56,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade400),
                      left: BorderSide(color: Colors.grey.shade400),
                      right: BorderSide(color: Colors.grey.shade400),
                      bottom: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  child: const AutoSizeText(
                    "NO",
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // The 5 headers
                _headerBox("SASARAN"),
                _headerBox("INDIKATOR KINERJA"),
                _headerBox("TARGET"),
                _headerBox("FORMULASI HITUNG"),
                _headerBox("SUMBER DATA"),

                // Empty header for delete column (no title)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade400),
                      right: BorderSide(color: Colors.grey.shade400),
                      bottom: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ],
            ),

            // Data rows
            for (int i = 0; i < _rows.length; i++) _buildRow(i),
          ],
        ),
      ),
    );
  }

  Widget _headerBox(String text) {
    return Container(
      width: _colWidth,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
          right: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: AutoSizeText(
        text,
        maxLines: 2,
        minFontSize: 9,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
