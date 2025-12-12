// lib/pdf_builder/table2.dart
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable2(List<List<String>> table2) async {
  PdfFont poppins = await getPoppinsFont(size: 11);
  PdfFont poppinsBold = await getPoppinsFont(size: 11, bold: true);

  final grid = PdfGrid();
  grid.columns.add(count: 7); // ← HANYA SEKALI!

  // 🔥 Lebar kolom
  grid.columns[0].width = 130; // Sasaran
  grid.columns[1].width = 130; // Indikator
  grid.columns[2].width = 40; // Target
  grid.columns[3].width = 45; // I
  grid.columns[4].width = 45; // II
  grid.columns[5].width = 45; // III
  grid.columns[6].width = 45; // IV

  // ---------------- HEADER (2 BARIS) ----------------
  grid.headers.add(2);

  // HEADER ROW 1
  final h1 = grid.headers[0];
  h1.cells[0].value = 'Sasaran';
  h1.cells[1].value = 'Indikator Kinerja';
  h1.cells[2].value = 'Target';

  h1.cells[3].value = 'Target';
  h1.cells[3].columnSpan = 4; // gabung col 3–6

  h1.cells[0].rowSpan = 2;
  h1.cells[1].rowSpan = 2;
  h1.cells[2].rowSpan = 2;

  // HEADER ROW 2
  final h2 = grid.headers[1];
  h2.cells[3].value = 'Triwulanan I';
  h2.cells[4].value = 'Triwulanan II';
  h2.cells[5].value = 'Triwulanan III';
  h2.cells[6].value = 'Triwulanan IV';

  // STYLE HEADER
  final headerStyle = PdfGridCellStyle()
    ..font = poppinsBold
    ..stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    )
    ..borders = PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0)),
      right: PdfPen(PdfColor(0, 0, 0)),
      top: PdfPen(PdfColor(0, 0, 0)),
      bottom: PdfPen(PdfColor(0, 0, 0)),
    );

  for (int r = 0; r < grid.headers.count; r++) {
    for (int c = 0; c < grid.headers[r].cells.count; c++) {
      grid.headers[r].cells[c].style = headerStyle;
    }
  }

  // ---------------- BODY ----------------
  for (final rowData in table2) {
    final r = grid.rows.add();

    for (int i = 0; i < 7; i++) {
      final val = (i < rowData.length) ? (rowData[i] ?? '') : '';
      r.cells[i].value = val;

      r.cells[i].style = PdfGridCellStyle()
        ..font = poppins
        ..borders = PdfBorders(
          left: PdfPen(PdfColor(0, 0, 0)),
          right: PdfPen(PdfColor(0, 0, 0)),
          top: PdfPen(PdfColor(0, 0, 0)),
          bottom: PdfPen(PdfColor(0, 0, 0)),
        )
        ..stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        );
    }

    // Kolom 0 & 1 → left align & top align
    r.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.left,
      lineAlignment: PdfVerticalAlignment.top,
    );

    r.cells[1].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.left,
      lineAlignment: PdfVerticalAlignment.top,
    );
  }

  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 4, bottom: 4);

  return grid;
}
