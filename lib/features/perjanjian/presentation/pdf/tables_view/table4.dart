import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable4(List<Map<String, dynamic>> table4) async {
  final poppins = await getPoppinsFont(size: 10);
  final poppinsBold = await getPoppinsFont(size: 10, bold: true);

  final grid = PdfGrid();
  grid.columns.add(count: 7); // ✅ FIX: 7 kolom
  grid.repeatHeader = true;

  // ===============================
  // COLUMN WIDTH
  // ===============================
  grid.columns[0].width = 30; // No
  grid.columns[1].width = 230; // Program
  grid.columns[2].width = 120; // Anggaran
  grid.columns[3].width = 110; // TW I
  grid.columns[4].width = 110; // TW II
  grid.columns[5].width = 110; // TW III
  grid.columns[6].width = 110; // TW IV

  // ===============================
  // HEADER (2 BARIS)
  // ===============================
  grid.headers.add(2);
  final h1 = grid.headers[0];
  final h2 = grid.headers[1];

  h1.cells[0].value = "No";
  h1.cells[1].value = "Program";
  h1.cells[2].value = "Anggaran";
  h1.cells[3].value = "Target";
  h1.cells[3].columnSpan = 4;

  h1.cells[0].rowSpan = 2;
  h1.cells[1].rowSpan = 2;
  h1.cells[2].rowSpan = 2;

  h2.cells[3].value = "Triwulan I";
  h2.cells[4].value = "Triwulan II";
  h2.cells[5].value = "Triwulan III";
  h2.cells[6].value = "Triwulan IV";

  final headerStyle = PdfGridCellStyle(
    font: poppinsBold,
    backgroundBrush: PdfSolidBrush(PdfColor(230, 230, 230)),
    borders: PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0)),
      right: PdfPen(PdfColor(0, 0, 0)),
      top: PdfPen(PdfColor(0, 0, 0)),
      bottom: PdfPen(PdfColor(0, 0, 0)),
    ),
  );

  for (int r = 0; r < grid.headers.count; r++) {
    final row = grid.headers[r];
    for (int c = 0; c < row.cells.count; c++) {
      row.cells[c].style = headerStyle;
      row.cells[c].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
    }
  }

  // ===============================
  // HELPERS
  // ===============================
  double num(dynamic v) =>
      double.tryParse(v?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '') ??
      0;

  PdfGridCellStyle bodyStyle(bool bold) => PdfGridCellStyle(
    font: bold ? poppinsBold : poppins,
    borders: PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0)),
      right: PdfPen(PdfColor(0, 0, 0)),
      top: PdfPen(PdfColor(0, 0, 0)),
      bottom: PdfPen(PdfColor(0, 0, 0)),
    ),
  );

  // ===============================
  // ROW DATA (RECURSIVE)
  // ===============================
  void addRows(List<Map<String, dynamic>> rows) {
    for (final r in rows) {
      final isMain = !r["no"].toString().contains(".");

      final anggaran = num(r["anggaran"]);
      final t1 = num(r["tw1"]);
      final t2 = num(r["tw2"]);
      final t3 = num(r["tw3"]);
      final t4 = num(r["tw4"]);
      final sisa = anggaran - (t1 + t2 + t3 + t4);

      final row = grid.rows.add();

      row.cells[0].value = r["no"] ?? "";
      row.cells[1].value = r["program"] ?? "";
      row.cells[2].value = anggaran.toStringAsFixed(0);
      row.cells[3].value = t1.toStringAsFixed(0);
      row.cells[4].value = t2.toStringAsFixed(0);
      row.cells[5].value = t3.toStringAsFixed(0);
      row.cells[6].value = t4.toStringAsFixed(0);

      for (int i = 0; i < row.cells.count; i++) {
        row.cells[i].style = bodyStyle(isMain);

        for (int i = 0; i < row.cells.count; i++) {
          row.cells[i].style = bodyStyle(isMain);

          row.cells[i].stringFormat = PdfStringFormat(
            alignment: () {
              if (i == 0) return PdfTextAlignment.right; // No
              if (i == 1) return PdfTextAlignment.left; // Program
              return PdfTextAlignment.right; // Anggaran & TW
            }(),
            lineAlignment: PdfVerticalAlignment.middle,
          );
        }
      }

      // 🔴 OVER BUDGET
      if (sisa < 0) {
        for (int i = 0; i < row.cells.count; i++) {
          row.cells[i].style!.backgroundBrush = PdfSolidBrush(
            PdfColor(255, 220, 220),
          );
        }
      }

      // recursive sub
      if (r["sub"] is List && (r["sub"] as List).isNotEmpty) {
        addRows(List<Map<String, dynamic>>.from(r["sub"]));
      }
    }
  }

  addRows(table4);

  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);

  return grid;
}
