// lib/pdf_builder/table3.dart
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/format_rupiah.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable3(List<Map<String, dynamic>> table3) async {
  PdfFont poppins = await getPoppinsFont(size: 12);
  PdfFont poppinsBold = await getPoppinsFont(size: 12, bold: true);

  final grid = PdfGrid();
  grid.columns.add(count: 4);

  // Lebar kolom
  grid.columns[0].width = 30; // NO
  grid.columns[1].width = 250; // PROGRAM
  grid.columns[2].width = 100; // ANGGARAN
  grid.columns[3].width = 100; // KETERANGAN

  // ---------------- HEADER ----------------
  grid.headers.add(1);
  final header = grid.headers[0];
  header.cells[0].value = 'NO';
  header.cells[1].value = 'PROGRAM / SUB PROGRAM';
  header.cells[2].value = 'ANGGARAN';
  header.cells[3].value = 'KETERANGAN';

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

  for (int i = 0; i < header.cells.count; i++) {
    header.cells[i].style = headerStyle;
  }

  int no = 1;
  double totalAnggaran = 0;

  // ---------------- BODY ----------------
  for (final item in table3) {
    final program = (item['program'] ?? '').toString();
    final angRaw = (item['anggaran'] ?? '').toString();
    final keter = (item['keterangan'] ?? '').toString();
    final subs = (item['sub'] ?? [])
        .cast<dynamic>()
        .map((s) => s?.toString() ?? '')
        .toList();

    // Total hanya dari baris utama
    final digits = angRaw.replaceAll(RegExp(r'[^0-9]'), '');
    final numVal = double.tryParse(digits) ?? 0.0;
    totalAnggaran += numVal;

    // -------- ROW UTAMA (BOLD) --------
    final mainRow = grid.rows.add();
    mainRow.cells[0].value = '$no';
    mainRow.cells[1].value = program;
    mainRow.cells[2].value = formatRupiah(angRaw);
    mainRow.cells[3].value = keter;

    for (int i = 0; i < mainRow.cells.count; i++) {
      final cell = mainRow.cells[i];
      cell.style = PdfGridCellStyle()
        ..font = poppinsBold
        ..borders = PdfBorders(
          left: PdfPen(PdfColor(0, 0, 0)),
          right: PdfPen(PdfColor(0, 0, 0)),
          top: PdfPen(PdfColor(0, 0, 0)),
          bottom: PdfPen(PdfColor(0, 0, 0)),
        );
    }

    mainRow.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    mainRow.cells[1].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.left,
    );
    mainRow.cells[2].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.right,
    );
    mainRow.cells[3].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );

    // -------- SUB ROWS (REGULAR) --------
    int idx = 1;
    for (final s in subs) {
      final r = grid.rows.add();

      r.cells[0].value = '$no.$idx';
      r.cells[1].value = '   $s';
      r.cells[2].value = formatRupiah(angRaw); // mengikuti parent
      r.cells[3].value = '';

      for (int i = 0; i < r.cells.count; i++) {
        final cell = r.cells[i];
        cell.style = PdfGridCellStyle()
          ..font = poppins
          ..borders = PdfBorders(
            left: PdfPen(PdfColor(0, 0, 0)),
            right: PdfPen(PdfColor(0, 0, 0)),
            top: PdfPen(PdfColor(0, 0, 0)),
            bottom: PdfPen(PdfColor(0, 0, 0)),
          );
      }

      r.cells[0].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
      );
      r.cells[1].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.left,
      );
      r.cells[2].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.right,
      );

      idx++;
    }

    no++;
  }

  // ---------------- TOTAL ROW ----------------
  final totalRow = grid.rows.add();
  totalRow.cells[0].value = '';
  totalRow.cells[1].value = 'JUMLAH';
  totalRow.cells[2].value = formatRupiah(totalAnggaran.toInt().toString());
  totalRow.cells[3].value = '';

  for (int i = 0; i < totalRow.cells.count; i++) {
    final cell = totalRow.cells[i];
    cell.style = PdfGridCellStyle()
      ..font = poppinsBold
      ..borders = PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0)),
        right: PdfPen(PdfColor(0, 0, 0)),
        top: PdfPen(PdfColor(0, 0, 0)),
        bottom: PdfPen(PdfColor(0, 0, 0)),
      );
  }
  // ➜ CENTER TEXT "JUMLAH"
  totalRow.cells[1].stringFormat = PdfStringFormat(
    alignment: PdfTextAlignment.center,
    lineAlignment: PdfVerticalAlignment.middle,
  );

  // Align anggaran to right
  totalRow.cells[2].stringFormat = PdfStringFormat(
    alignment: PdfTextAlignment.right,
  );

  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 3, bottom: 3);

  return grid;
}
