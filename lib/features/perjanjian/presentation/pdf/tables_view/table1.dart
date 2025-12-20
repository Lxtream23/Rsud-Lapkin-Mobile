// lib/pdf_builder/table1.dart
import 'package:syncfusion_flutter_pdf/pdf.dart';

PdfGrid buildTable1(
  List<List<String>> table1,
  PdfFont fontBody,
  PdfFont fontBold,
) {
  final grid = PdfGrid();
  grid.columns.add(count: 5);
  grid.repeatHeader = true;

  // =========================
  // COLUMN WIDTH
  // =========================
  grid.columns[0].width = 30; // NO
  grid.columns[1].width = 145; // SASARAN
  grid.columns[2].width = 165; // INDIKATOR
  grid.columns[3].width = 80; // SATUAN
  grid.columns[4].width = 80; // TARGET

  // =========================
  // HEADER
  // =========================
  grid.headers.add(1);
  final header = grid.headers[0];

  header.cells[0].value = 'NO';
  header.cells[1].value = 'SASARAN';
  header.cells[2].value = 'INDIKATOR KINERJA';
  header.cells[3].value = 'SATUAN';
  header.cells[4].value = 'TARGET';

  final headerStyle = PdfGridCellStyle(
    font: fontBold,
    backgroundBrush: PdfSolidBrush(PdfColor(245, 245, 245)), // abu tipis
    borders: PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
    ),
  );
  headerStyle.stringFormat = PdfStringFormat(
    alignment: PdfTextAlignment.center,
    lineAlignment: PdfVerticalAlignment.middle,
  );

  for (int i = 0; i < header.cells.count; i++) {
    header.cells[i].style = headerStyle;
  }

  // =========================
  // BODY ROWS
  // =========================
  for (int i = 0; i < table1.length; i++) {
    final data = table1[i];
    final row = grid.rows.add();

    row.cells[0].value = '${i + 1}';
    row.cells[1].value = data.isNotEmpty ? data[0] : '';
    row.cells[2].value = data.length > 1 ? data[1] : '';
    row.cells[3].value = data.length > 2 ? data[2] : '';
    row.cells[4].value = data.length > 3 ? data[3] : '';

    for (int c = 0; c < row.cells.count; c++) {
      row.cells[c].style = PdfGridCellStyle(
        font: fontBody,
        borders: PdfBorders(
          left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        ),
      );

      row.cells[c].stringFormat = PdfStringFormat(
        alignment: c == 0 ? PdfTextAlignment.right : PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.top,
      );
    }
  }

  // =========================
  // CELL PADDING
  // =========================
  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);

  return grid;
}
