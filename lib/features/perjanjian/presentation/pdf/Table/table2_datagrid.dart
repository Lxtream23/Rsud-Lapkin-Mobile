import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'table2_datasource.dart';
import 'table2_model.dart';

class Table2DataGrid extends StatelessWidget {
  final List<Table2Row> tableData;

  const Table2DataGrid({super.key, required this.tableData});

  @override
  Widget build(BuildContext context) {
    final source = Table2DataSource(tableData);

    return SfDataGrid(
      source: source,
      columnWidthMode: ColumnWidthMode.fill,
      headerRowHeight: 50,
      rowHeight: 48,
      columns: [
        // header SASARAN — merge downward (gelombang seperti contoh)
        GridColumn(columnName: 'sasaran', label: _headerCell("SASARAN")),

        GridColumn(
          columnName: 'indikator',
          label: _headerCell("INDIKATOR KINERJA"),
        ),

        GridColumn(columnName: 'satuan', label: _headerCell("SATUAN")),

        // TRIWULAN
        GridColumn(columnName: 'i', label: _headerCell("I")),
        GridColumn(columnName: 'ii', label: _headerCell("II")),
        GridColumn(columnName: 'iii', label: _headerCell("III")),
        GridColumn(columnName: 'iv', label: _headerCell("IV")),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade300,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
