// lib/pdf_builder/table2.dart
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable2(List<List<String>> table2) async {
  PdfFont poppins = await getPoppinsFont(size: 11);
  PdfFont poppinsBold = await getPoppinsFont(size: 11, bold: true);

  final grid = PdfGrid();
  grid.columns.add(count: 7);

  // 🔥 Atur lebar kolom
  grid.columns[0].width = 130; // Sasaran
  grid.columns[1].width = 130; // Indikator
  grid.columns[2].width = 40; // Target
  grid.columns[3].width = 45; // I
  grid.columns[4].width = 45; // II
  grid.columns[5].width = 45; // III
  grid.columns[6].width = 45; // IV

  // ---------------- HEADER (2 BARIS) ----------------
  //final grid = PdfGrid();

  // WAJIB: buat jumlah kolom dulu
  grid.columns.add(count: 7);

  // Tambah 2 baris header
  grid.headers.add(2);

  // ---------------- HEADER ROW 1 ----------------
  final h1 = grid.headers[0];

  h1.cells[0].value = 'Sasaran';
  h1.cells[1].value = 'Indikator Kinerja';
  h1.cells[2].value = 'Target';

  h1.cells[3].value = 'Target Triwulanan';
  h1.cells[3].columnSpan = 4; // gabung col 3–6

  // rowSpan kolom lain
  h1.cells[0].rowSpan = 2;
  h1.cells[1].rowSpan = 2;
  h1.cells[2].rowSpan = 2;

  // ---------------- HEADER ROW 2 ----------------
  final h2 = grid.headers[1];

  // sekarang row 2 DIJAMIN PUNYA 7 CELL
  h2.cells[3].value = 'I';
  h2.cells[4].value = 'II';
  h2.cells[5].value = 'III';
  h2.cells[6].value = 'IV';

  // ------ Style Header ------
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

  // apply to both header rows
  for (int h = 0; h < grid.headers.count; h++) {
    final row = grid.headers[h];
    for (int c = 0; c < row.cells.count; c++) {
      row.cells[c].style = headerStyle;
    }
  }

  // ---------------- BODY ----------------
  for (final rowData in table2) {
    final r = grid.rows.add();

    for (int i = 0; i < 7; i++) {
      final v = (i < rowData.length) ? (rowData[i] ?? '') : '';
      r.cells[i].value = v;

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

    // Kolom 0 & 1 left-align dan top-align
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
