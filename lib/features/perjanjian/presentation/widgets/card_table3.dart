import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/widgets/ui_helpers/app_snackbar.dart';
import 'package:rsud_lapkin_mobile/features/perjanjian/presentation/pages/form_perjanjian_page.dart';

class CardTable3Widget extends StatefulWidget {
  final List<ProgramAnggaranRow> rows;

  final VoidCallback onAddProgram;
  final void Function(int index) onDeleteProgram;

  final void Function(List<int> parentPath) onAddSub;
  final void Function(List<int> parentPath) onAddSubSub;

  final void Function(List<int> path) onDeleteSub;
  final void Function(List<int> path) onDeleteSubSub;

  const CardTable3Widget({
    super.key,
    required this.rows,
    required this.onAddProgram,
    required this.onDeleteProgram,
    required this.onAddSub,
    required this.onAddSubSub,
    required this.onDeleteSub,
    required this.onDeleteSubSub,
  });

  @override
  State<CardTable3Widget> createState() => _CardTable3WidgetState();
}

class _CardTable3WidgetState extends State<CardTable3Widget> {
  //final List<Map<String, dynamic>> _rows = [];
  int? openIndex;

  @override
  void initState() {
    super.initState();
    //_addRow();
  }

  // =========================
  // GET DATA AS STRINGS
  // =========================
  List<Map<String, dynamic>> getRowsAsStrings() {
    return _mapRows(widget.rows, []);
  }

  List<Map<String, dynamic>> _mapRows(
    List<ProgramAnggaranRow> rows,
    List<int> path,
  ) {
    return rows.asMap().entries.map((e) {
      final i = e.key;
      final r = e.value;
      final p = [...path, i + 1];

      return {
        "no": p.join("."),
        "program": r.program.text.trim(),
        "anggaran": r.anggaran.text.trim(),
        "keterangan": r.keterangan.text.trim(),
        "sub": _mapRows(r.children, p),
      };
    }).toList();
  }

  // List<Map<String, dynamic>> getRowsAsStrings() {
  //   final List<Map<String, dynamic>> result = [];

  //   for (int i = 0; i < _rows.length; i++) {
  //     final row = _rows[i];

  //     result.add({
  //       "no": "${i + 1}",
  //       "program": row["program"].text,
  //       "anggaran": row["anggaran"].text,
  //       "keterangan": row["keterangan"].text,
  //       "sub": _mapSub(row["sub"], [i + 1]),
  //     });
  //   }

  //   return result;
  // }

  // List<Map<String, dynamic>> _mapSub(List subs, List<int> path) {
  //   final List<Map<String, dynamic>> result = [];

  //   for (int i = 0; i < subs.length; i++) {
  //     final sub = subs[i];
  //     final newPath = [...path, i + 1];

  //     result.add({
  //       "no": newPath.join("."),
  //       "program": sub["program"].text,
  //       "anggaran": sub["anggaran"].text,
  //       "keterangan": sub["keterangan"].text,
  //       "sub": _mapSub(sub["sub"], newPath),
  //     });
  //   }

  //   return result;
  // }

  // =========================
  // AUTO NUMBERING
  // =========================
  String num(List<int> path) => path.join(".");

  // =========================
  // DATA MANAGEMENT
  // =========================
  // void _addRow() {
  //   _rows.add({
  //     "program": TextEditingController(),
  //     "anggaran": TextEditingController(),
  //     "keterangan": TextEditingController(),
  //     "sub": <Map<String, dynamic>>[],
  //   });
  //   setState(() {});
  // }

  // void _deleteRow(int i) {
  //   if (_rows.length == 1) {
  //     _rows.first["program"].clear();
  //     _rows.first["anggaran"].clear();
  //     _rows.first["keterangan"].clear();
  //     (_rows.first["sub"] as List).clear();
  //     setState(() {});
  //     return;
  //   }
  //   _rows.removeAt(i);
  //   setState(() {});
  //   _success("Program dihapus");
  // }

  // void _addSub(int p) {
  //   (_rows[p]["sub"] as List).add({
  //     "program": TextEditingController(),
  //     "anggaran": TextEditingController(),
  //     "keterangan": TextEditingController(),
  //     "sub": <Map<String, dynamic>>[],
  //   });
  //   setState(() => openIndex = p);
  // }

  // void _addSubSub(int p, int s) {
  //   (_rows[p]["sub"][s]["sub"] as List).add({
  //     "program": TextEditingController(),
  //     "anggaran": TextEditingController(),
  //     "keterangan": TextEditingController(),
  //     "sub": <Map<String, dynamic>>[],
  //   });
  //   setState(() {});
  // }

  // void _deleteSub(int p, int s) {
  //   (_rows[p]["sub"] as List).removeAt(s);
  //   setState(() {});
  //   _success("Sub-program dihapus");
  // }

  // void _deleteSubSub(int p, int s, int ss) {
  //   (_rows[p]["sub"][s]["sub"] as List).removeAt(ss);
  //   setState(() {});
  //   _success("Sub-sub program dihapus");
  // }

  // =========================
  // TOTAL
  // =========================
  double _parse(String t) =>
      double.tryParse(t.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  double get totalAnggaran =>
      widget.rows.fold(0, (s, r) => s + _parse(r.anggaran.text));

  // double get totalAnggaran =>
  //     _rows.fold(0, (s, r) => s + _parse(r["anggaran"].text));

  String rupiah(double v) {
    final s = v.toInt().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if ((s.length - i) % 3 == 0 && i != 0) b.write('.');
      b.write(s[i]);
    }
    return "Rp ${b.toString()}";
  }

  Future<bool> showConfirmDeleteDialog(BuildContext context) async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                "Hapus Baris?",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Text(
                "Apakah Anda yakin ingin menghapus baris ini?",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // SHOW DELETE SUCCESS SNACKBAR
  void _showDeleteSuccess(String msg) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx == null) {
      debugPrint("Overlay NULL → Snackbar gagal ditampilkan");
      return;
    }

    AppSnackbar.success(ctx, msg);
  }

  // SHOW DELETE ERROR SNACKBAR
  void _showDeleteError(String msg) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx == null) return;

    AppSnackbar.error(ctx, msg);
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "TABEL PROGRAM",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // BARIS COUNT CHIP
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_labelChip("${widget.rows.length} baris")],
        ),
        const SizedBox(height: 8),

        _header(),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.rows.length,
          itemBuilder: (_, i) {
            final row = widget.rows[i];
            return _programCard(row, [i + 1]);
          },
        ),

        _addMainProgramButton(),
        const SizedBox(height: 10),
        _footer(),
      ],
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFBEF8FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text("No", style: _th)),
          Expanded(flex: 4, child: Text("Program", style: _th)),
          Expanded(flex: 2, child: Text("Anggaran", style: _th)),
          Expanded(flex: 2, child: Text("Ket", style: _th)),
        ],
      ),
    );
  }

  // =========================
  // ADD MAIN PROGRAM BUTTON
  // =========================
  Widget _addMainProgramButton() {
    final theme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: Icon(Icons.add_circle, color: theme.primary),
        label: Text(
          "Tambah Baris",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
        onPressed: () {
          widget.onAddProgram();
          setState(() {
            openIndex = widget.rows.length - 1;
          });
          _success("Program baru ditambahkan");
        },
      ),
    );
  }

  // =========================
  // PROGRAM CARD
  // =========================
  Widget _programCard(ProgramAnggaranRow row, List<int> path) {
    final index = path.last - 1;

    return Card(
      color: const Color(0xFFBEF8FF),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                openIndex = openIndex == index ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  /// NO
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          num(path),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// PROGRAM
                  Expanded(
                    flex: 4,
                    child: Text(
                      row.program.text.isEmpty
                          ? "— Program —"
                          : row.program.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  /// ANGGARAN
                  Expanded(
                    flex: 2,
                    child: Text(rupiah(_parse(row.anggaran.text))),
                  ),

                  /// KETERANGAN
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.keterangan.text.isEmpty ? "-" : row.keterangan.text,
                    ),
                  ),

                  /// ACTION
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🗑 DELETE
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final ok = await showConfirmDeleteDialog(context);
                          if (!ok) return;

                          widget.onDeleteProgram(index);
                          _showDeleteSuccess("Program dihapus");
                        },
                      ),

                      /// ▶️ TOGGLE
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            openIndex = openIndex == index ? null : index;
                          });
                        },
                        child: AnimatedRotation(
                          turns: openIndex == index ? -0.25 : 0,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOut,
                          child: const Icon(Icons.chevron_left, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// ⬇️ SUB PROGRAM
          if (openIndex == index) _expanded(row, path),
        ],
      ),
    );
  }

  // =========================
  // EXPANDED FORM
  // =========================
  Widget _expanded(ProgramAnggaranRow row, List<int> path) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          _input("Program", row.program),
          _input("Anggaran", row.anggaran),
          _input("Keterangan", row.keterangan),
          const Divider(),

          /// SUB PROGRAM
          for (int s = 0; s < row.children.length; s++)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: _subProgram(
                row: row.children[s],
                path: [...path, s + 1], // ✅ BENAR
              ),
            ),

          /// ➕ TAMBAH SUB PROGRAM
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: Icon(Icons.add_circle, color: theme.primary),
              label: Text(
                "Tambah Sub Program",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
              onPressed: () {
                widget.onAddSub(path);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _subProgram({
    required ProgramAnggaranRow row,
    required List<int> path,
  }) {
    final theme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER SUB PROGRAM
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                path.join("."),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Sub Program",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => widget.onDeleteSub(path),
            ),
          ],
        ),

        _input("Program", row.program),
        _input("Anggaran", row.anggaran),
        _input("Keterangan", row.keterangan),

        /// SUB-SUB PROGRAM
        for (int i = 0; i < row.children.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: _subProgram(
              row: row.children[i],
              path: [...path, i + 1], // ✅ BENAR
            ),
          ),

        /// ➕ TAMBAH SUB-SUB
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(Icons.add_circle, color: theme.primary, size: 18),
            label: Text(
              "Tambah Sub-Sub Program",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
            ),
            onPressed: () {
              widget.onAddSubSub(path);
            },
          ),
        ),

        const Divider(),
      ],
    );
  }

  // =========================
  // FOOTER
  // =========================
  Widget _footer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFBEF8FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 6,
            child: Text(
              "JUMLAH",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rupiah(totalAnggaran),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // INPUT
  // =========================
  Widget _input(String label, TextEditingController c) {
    final theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // 👈 JARAK ANTAR INPUT
      child: AnimatedSize(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: TextField(
          controller: c,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 14),
            filled: true,
            fillColor: theme.surfaceContainerLowest,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  // LABEL CHIP
  Widget _labelChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFBEF8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // SNACKBAR

  void _success(String m) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx != null) AppSnackbar.success(ctx, m);
  }

  Widget _buildRows(List<ProgramAnggaranRow> rows, List<int> path) {
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++)
          _programCard(rows[i], [...path, i + 1]),
      ],
    );
  }
}

const TextStyle _th = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
