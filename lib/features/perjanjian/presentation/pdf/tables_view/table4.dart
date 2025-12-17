import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable4(List<Map<String, dynamic>> table4) async {
  final poppins = await getPoppinsFont(size: 10);
  final poppinsBold = await getPoppinsFont(size: 10, bold: true);

  final grid = PdfGrid();
  grid.columns.add(count: 7);
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
  // HEADER (2 ROW)
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
      final cell = grid.headers[r].cells[c];
      cell.style = headerStyle;
      cell.stringFormat = PdfStringFormat(
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

  String rupiah(double v) {
    final s = v.toStringAsFixed(0);
    return " ${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}";
  }

  PdfTextAlignment alignByColumn(int col) {
    if (col == 1) return PdfTextAlignment.left; // Program
    return PdfTextAlignment.right; // Angka + No
  }

  PdfGridCellStyle bodyStyle(bool bold) => PdfGridCellStyle(
    font: bold ? poppinsBold : poppins,
    borders: PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
    ),
  );

  // ===============================
  // TOTAL (HANYA BARIS UTAMA)
  // ===============================
  double totalAnggaran = 0;
  double totalT1 = 0;
  double totalT2 = 0;
  double totalT3 = 0;
  double totalT4 = 0;

  // ===============================
  // RECURSIVE ROWS
  // ===============================
  void addRows(List<Map<String, dynamic>> rows) {
    for (final r in rows) {
      final isMain = !r["no"].toString().contains(".");

      final anggaran = num(r["anggaran"]);
      final t1 = num(r["tw1"]);
      final t2 = num(r["tw2"]);
      final t3 = num(r["tw3"]);
      final t4 = num(r["tw4"]);

      if (isMain) {
        totalAnggaran += anggaran;
        totalT1 += t1;
        totalT2 += t2;
        totalT3 += t3;
        totalT4 += t4;
      }

      final row = grid.rows.add();

      row.cells[0].value = r["no"];
      row.cells[1].value = r["program"];
      row.cells[2].value = rupiah(anggaran);
      row.cells[3].value = rupiah(t1);
      row.cells[4].value = rupiah(t2);
      row.cells[5].value = rupiah(t3);
      row.cells[6].value = rupiah(t4);

      for (int i = 0; i < row.cells.count; i++) {
        row.cells[i].style = bodyStyle(isMain);
        row.cells[i].stringFormat = PdfStringFormat(
          alignment: alignByColumn(i),
          lineAlignment: PdfVerticalAlignment.middle,
        );
      }

      if (r["sub"] is List && (r["sub"] as List).isNotEmpty) {
        addRows(List<Map<String, dynamic>>.from(r["sub"]));
      }
    }
  }

  addRows(table4);

  // ===============================
  // TOTAL ROW
  // ===============================
  final totalRow = grid.rows.add();

  // Gabungkan kolom NO + PROGRAM
  totalRow.cells[0].columnSpan = 2;
  totalRow.cells[0].value = "JUMLAH";
  totalRow.cells[1].value = "";

  // Isi nilai total
  totalRow.cells[2].value = rupiah(totalAnggaran);
  totalRow.cells[3].value = rupiah(totalT1);
  totalRow.cells[4].value = rupiah(totalT2);
  totalRow.cells[5].value = rupiah(totalT3);
  totalRow.cells[6].value = rupiah(totalT4);

  // Style + Alignment
  for (int i = 0; i < totalRow.cells.count; i++) {
    totalRow.cells[i].style = PdfGridCellStyle(
      font: poppinsBold,
      borders: PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0), width: 0.5), // garis kiri tebal
        right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        top: PdfPen(PdfColor(0, 0, 0), width: 0.5), // garis atas tebal
        bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      ),
    );

    totalRow.cells[i].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.right, // semua ke kanan
      lineAlignment: PdfVerticalAlignment.middle,
    );
  }

  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);

  return grid;
}
