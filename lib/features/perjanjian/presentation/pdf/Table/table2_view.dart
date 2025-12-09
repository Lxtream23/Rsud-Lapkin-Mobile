import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'table2_model.dart';
import 'table2_datasource.dart';

class Table2View extends StatelessWidget {
  final List<Table2Row> rows;

  const Table2View({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final ds = Table2DataSource(rows);

    return SfDataGrid(
      source: ds,
      headerRowHeight: 60,
      rowHeight: 48,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      columnWidthMode: ColumnWidthMode.fill,

      columns: [
        // ======== SASARAN (MERGED STYLE) ========
        GridColumn(
          columnName: "sasaran",
          label: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            child: const Text(
              "SASARAN",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // ======== INDIKATOR KINERJA ========
        GridColumn(
          columnName: "indikator",
          label: Container(
            alignment: Alignment.center,
            child: const Text(
              "INDIKATOR KINERJA",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // ======== SATUAN ========
        GridColumn(
          columnName: "satuan",
          width: 80,
          label: Container(
            alignment: Alignment.center,
            child: const Text(
              "SATUAN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // ================== TARGET TRI WULAN ==================
        GridColumn(columnName: "tw1", label: _targetHeader("I")),
        GridColumn(columnName: "tw2", label: _targetHeader("II")),
        GridColumn(columnName: "tw3", label: _targetHeader("III")),
        GridColumn(columnName: "tw4", label: _targetHeader("IV")),

        // ======== TOTAL ========
        GridColumn(
          columnName: "total",
          label: Container(
            alignment: Alignment.center,
            child: const Text(
              "TOTAL",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _targetHeader(String label) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
