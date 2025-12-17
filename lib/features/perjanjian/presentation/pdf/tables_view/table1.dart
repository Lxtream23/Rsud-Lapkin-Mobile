// lib/pdf_builder/table1.dart
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable1(List<List<String>> table1) async {
  PdfFont poppins = await getPoppinsFont(size: 10);
  PdfFont poppinsBold = await getPoppinsFont(size: 10, bold: true);

  final grid = PdfGrid();
  grid.columns.add(count: 5);

  // Lebar kolom
  grid.columns[0].width = 30; // NO
  grid.columns[1].width = 145; // SASARAN
  grid.columns[2].width = 165; // INDIKATOR KINERJA
  grid.columns[3].width = 80; // SATUAN
  grid.columns[4].width = 80; // TARGET
  // === HEADER ===
  grid.headers.add(1);
  final header = grid.headers[0];

  grid.repeatHeader = true;

  header.cells[0].value = 'NO';
  header.cells[1].value = 'SASARAN';
  header.cells[2].value = 'INDIKATOR KINERJA';
  header.cells[3].value = 'SATUAN';
  header.cells[4].value = 'TARGET';

  final headerStyle = PdfGridCellStyle()
    ..font = poppinsBold
    ..stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    )
    ..backgroundBrush = PdfSolidBrush(
      PdfColor(230, 230, 230), // abu abu tipis 🔥
    )
    ..borders = PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
    );

  for (int i = 0; i < header.cells.count; i++) {
    header.cells[i].style = headerStyle;
  }

  // === ROWS ===
  for (int i = 0; i < table1.length; i++) {
    final row = table1[i];
    final r = grid.rows.add();

    r.cells[0].value = '${i + 1}'; // NO
    r.cells[1].value = row.isNotEmpty ? row[0] : ''; // SASARAN
    r.cells[2].value = row.length > 1 ? row[1] : ''; // INDIKATOR
    r.cells[3].value = row.length > 2 ? row[2] : ''; // SATUAN
    r.cells[4].value = row.length > 3 ? row[3] : ''; // TARGET

    // style body
    for (int c = 0; c < r.cells.count; c++) {
      r.cells[c].style = PdfGridCellStyle()
        ..font = poppinsBold
        ..borders = PdfBorders(
          left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        );
    }

    // Cell alignment
    r.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.right,
    );
    r.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left);
    r.cells[2].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left);
    r.cells[3].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    r.cells[4].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
  }

  // Cell padding
  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);

  return grid;
}
