import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/format_rupiah.dart';
import '../utils/pdf_fonts.dart';

Future<PdfGrid> buildTable3(List<Map<String, dynamic>> table3) async {
  final poppins = await getPoppinsFont(size: 10);
  final poppinsBold = await getPoppinsFont(size: 10, bold: true);

  final grid = PdfGrid();
  grid.columns.add(count: 4);

  grid.columns[0].width = 35; // NO
  grid.columns[1].width = 260; // PROGRAM
  grid.columns[2].width = 130; // ANGGARAN
  grid.columns[3].width = 75; // KET

  // ================= HEADER =================
  grid.headers.add(1);
  final h = grid.headers[0];

  grid.repeatHeader = true;

  h.cells[0].value = 'No';
  h.cells[1].value = 'Program';
  h.cells[2].value = 'Anggaran';
  h.cells[3].value = 'Ket';

  for (int i = 0; i < h.cells.count; i++) {
    h.cells[i].style = PdfGridCellStyle(
      font: poppinsBold,
      backgroundBrush: PdfSolidBrush(
        PdfColor(245, 245, 245), // 👈 HEADER ABU-ABU TIPIS
      ),
      borders: PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      ),
    );

    h.cells[i].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
  }

  double totalAnggaran = 0;

  // ================= BODY =================
  for (int i = 0; i < table3.length; i++) {
    final row = table3[i];

    final ang = _parse(row['anggaran']);
    totalAnggaran += ang;

    // ===== BARIS UTAMA (BOLD) =====
    _addRow(
      grid,
      no: '${i + 1}',
      program: row['program'] ?? '',
      anggaran: row['anggaran'] ?? '',
      ket: row['keterangan'] ?? '',
      font: poppinsBold,
    );

    // ===== SUB & SUB-SUB (REGULAR) =====
    _renderSub(grid, row['sub'] ?? [], parentNo: '${i + 1}', font: poppins);
  }

  // ================= TOTAL =================
  final t = grid.rows.add();
  t.cells[0].value = '';
  t.cells[1].value = 'JUMLAH';
  t.cells[2].value = formatRupiah(totalAnggaran.toInt().toString());
  t.cells[3].value = '';

  for (int i = 0; i < t.cells.count; i++) {
    t.cells[i].style = _cellStyle(poppinsBold);
  }

  t.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right);
  t.cells[2].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right);

  grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);

  return grid;
}

// ================= SUB RENDER =================
void _renderSub(
  PdfGrid grid,
  List subs, {
  required String parentNo,
  required PdfFont font,
}) {
  for (int i = 0; i < subs.length; i++) {
    final s = subs[i];
    final no = '$parentNo.${i + 1}';

    _addRow(
      grid,
      no: no,
      program: s['program'] ?? '',
      anggaran: s['anggaran'] ?? '', // ✅ FIX
      ket: s['keterangan'] ?? '',
      font: font,
    );

    if (s['sub'] != null && s['sub'].isNotEmpty) {
      _renderSub(grid, s['sub'], parentNo: no, font: font);
    }
  }
}

// ================= ADD ROW =================
void _addRow(
  PdfGrid grid, {
  required String no,
  required String program,
  required String anggaran,
  required String ket,
  required PdfFont font,
}) {
  final r = grid.rows.add();

  r.cells[0].value = no;
  r.cells[1].value = program;
  r.cells[2].value = formatRupiah(anggaran);
  r.cells[3].value = ket;

  for (int i = 0; i < r.cells.count; i++) {
    r.cells[i].style = _cellStyle(font);
  }

  r.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right);
  r.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left);
  r.cells[2].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right);
  r.cells[3].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center);
}

// ================= STYLE =================
PdfGridCellStyle _cellStyle(PdfFont font) {
  return PdfGridCellStyle(
    font: font,
    borders: PdfBorders(
      left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
    ),
  );
}

double _parse(String? v) =>
    double.tryParse((v ?? '').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
