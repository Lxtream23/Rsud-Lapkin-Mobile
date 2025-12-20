// lib/pdf_builder/table2.dart
import 'package:syncfusion_flutter_pdf/pdf.dart';

PdfGrid buildTable2(
  List<List<String>> table2,
  PdfFont fontBody,
  PdfFont fontBold,
) {
  final grid = PdfGrid();
  grid.columns.add(count: 8);
  grid.repeatHeader = true;

  // =====================================================
  // COLUMN WIDTH
  // =====================================================
  grid.columns[0].width = 30; // NO
  grid.columns[1].width = 190; // Sasaran
  grid.columns[2].width = 170; // Indikator Kinerja
  grid.columns[3].width = 70; // Target
  grid.columns[4].width = 90; // TW I
  grid.columns[5].width = 90; // TW II
  grid.columns[6].width = 90; // TW III
  grid.columns[7].width = 90; // TW IV

  // =====================================================
  // HEADER (2 ROWS)
  // =====================================================
  grid.headers.add(2);

  final h1 = grid.headers[0];
  final h2 = grid.headers[1];

  h1.cells[0].value = 'NO';
  h1.cells[1].value = 'Sasaran';
  h1.cells[2].value = 'Indikator Kinerja';
  h1.cells[3].value = 'Target';
  h1.cells[4].value = 'Target';
  h1.cells[4].columnSpan = 4;

  h1.cells[0].rowSpan = 2;
  h1.cells[1].rowSpan = 2;
  h1.cells[2].rowSpan = 2;
  h1.cells[3].rowSpan = 2;

  h2.cells[4].value = 'Triwulan I';
  h2.cells[5].value = 'Triwulan II';
  h2.cells[6].value = 'Triwulan III';
  h2.cells[7].value = 'Triwulan IV';

  final headerStyle = PdfGridCellStyle(
    font: fontBold,
    backgroundBrush: PdfSolidBrush(PdfColor(245, 245, 245)),
    borders: PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
    ),
  );

  for (int r = 0; r < grid.headers.count; r++) {
    for (int c = 0; c < grid.headers[r].cells.count; c++) {
      grid.headers[r].cells[c].style = headerStyle;
      grid.headers[r].cells[c].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.top,
      );
    }
  }

  // =====================================================
  // BODY ROWS
  // =====================================================
  int no = 1;

  for (final rowData in table2) {
    final row = grid.rows.add();

    row.cells[0].value = no.toString();
    no++;

    for (int c = 0; c < row.cells.count; c++) {
      final isTextCol = c == 1 || c == 2;

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
        alignment: c == 0
            ? PdfTextAlignment.right
            : isTextCol
            ? PdfTextAlignment.left
            : PdfTextAlignment.center,
        lineAlignment: isTextCol
            ? PdfVerticalAlignment.top
            : PdfVerticalAlignment.middle,
      );
    }

    for (int i = 1; i < row.cells.count; i++) {
      row.cells[i].value = (i - 1 < rowData.length)
          ? (rowData[i - 1] ?? '')
          : '';
    }
  }

  // =====================================================
  // CELL PADDING
  // =====================================================
  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);

  return grid;
}
