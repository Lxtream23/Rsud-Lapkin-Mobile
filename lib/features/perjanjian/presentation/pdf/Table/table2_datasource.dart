import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'table2_model.dart';

class Table2DataSource extends DataGridSource {
  final List<Table2Row> data;

  Table2DataSource(this.data) {
    buildDataGridRows();
  }

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  void buildDataGridRows() {
    _rows = data.map((row) {
      return DataGridRow(
        cells: [
          DataGridCell(columnName: 'sasaran', value: row.sasaran),
          DataGridCell(columnName: 'indikator', value: row.indikator),
          DataGridCell(columnName: 'satuan', value: row.satuan),
          DataGridCell(columnName: 'i', value: row.targetI),
          DataGridCell(columnName: 'ii', value: row.targetII),
          DataGridCell(columnName: 'iii', value: row.targetIII),
          DataGridCell(columnName: 'iv', value: row.targetIV),
        ],
      );
    }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            cell.value.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}
