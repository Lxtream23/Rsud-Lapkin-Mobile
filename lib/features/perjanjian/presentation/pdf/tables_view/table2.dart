import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable2(List<List<String>> table2) async {
  PdfFont poppins = await getPoppinsFont(size: 11);
  PdfFont poppinsBold = await getPoppinsFont(size: 11, bold: true);

  final grid = PdfGrid();

  // TOTAL 8 KOLOM (NO + 7 kolom lama)
  grid.columns.add(count: 8);

  // ---- LEBAR KOLOM ----
  grid.columns[0].width = 30; // NO
  grid.columns[1].width = 190; // Sasaran
  grid.columns[2].width = 170; // Indikator Kinerja
  grid.columns[3].width = 70; // Target
  grid.columns[4].width = 90; // I
  grid.columns[5].width = 90; // II
  grid.columns[6].width = 90; // III
  grid.columns[7].width = 90; // IV

  // ============================================================
  // HEADER (2 BARIS)
  // ============================================================
  grid.headers.add(2);

  // HEADER 1
  final h1 = grid.headers[0];

  h1.cells[0].value = 'NO';
  h1.cells[1].value = 'Sasaran';
  h1.cells[2].value = 'Indikator Kinerja';
  h1.cells[3].value = 'Target';

  // Gabung 4 kolom terakhir
  h1.cells[4].value = 'Target';
  h1.cells[4].columnSpan = 4;

  // RowSpan untuk stabil
  h1.cells[0].rowSpan = 2;
  h1.cells[1].rowSpan = 2;
  h1.cells[2].rowSpan = 2;
  h1.cells[3].rowSpan = 2;

  // HEADER 2
  final h2 = grid.headers[1];
  h2.cells[4].value = 'Triwulan I';
  h2.cells[5].value = 'Triwulan II';
  h2.cells[6].value = 'Triwulan III';
  h2.cells[7].value = 'Triwulan IV';

  // ---- STYLE HEADER ----
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

  // ============================================================
  // BODY + NOMOR OTOMATIS
  // ============================================================
  int no = 1;

  for (final rowData in table2) {
    final row = grid.rows.add();

    // --- NO otomatis ---
    row.cells[0].value = no.toString();
    no++;
    row.cells[0].style = PdfGridCellStyle()
      ..font = poppins
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

    // --- Kolom lain ---
    for (int i = 1; i < 8; i++) {
      final val = (i - 1 < rowData.length) ? (rowData[i - 1] ?? '') : '';
      row.cells[i].value = val;

      row.cells[i].style = PdfGridCellStyle()
        ..font = poppins
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
    }

    // Perbaiki alignment sasaran + indikator
    row.cells[1].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.left,
      lineAlignment: PdfVerticalAlignment.top,
    );

    row.cells[2].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.left,
      lineAlignment: PdfVerticalAlignment.top,
    );
  }

  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 4, bottom: 4);

  return grid;
}
