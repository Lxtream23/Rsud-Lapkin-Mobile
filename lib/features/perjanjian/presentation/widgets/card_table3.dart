import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/widgets/ui_helpers/app_snackbar.dart';

class CardTable3Widget extends StatefulWidget {
  const CardTable3Widget({super.key});

  @override
  State<CardTable3Widget> createState() => _CardTable3WidgetState();
}

class _CardTable3WidgetState extends State<CardTable3Widget> {
  final List<Map<String, dynamic>> _rows = [];
  int? openIndex;

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  // =========================
  // AUTO NUMBERING
  // =========================
  String num(List<int> path) => path.join(".");

  // =========================
  // DATA MANAGEMENT
  // =========================
  void _addRow() {
    _rows.add({
      "program": TextEditingController(),
      "anggaran": TextEditingController(),
      "keterangan": TextEditingController(),
      "sub": <Map<String, dynamic>>[],
    });
    setState(() {});
  }

  void _deleteRow(int i) {
    if (_rows.length == 1) {
      _rows.first["program"].clear();
      _rows.first["anggaran"].clear();
      _rows.first["keterangan"].clear();
      (_rows.first["sub"] as List).clear();
      setState(() {});
      return;
    }
    _rows.removeAt(i);
    setState(() {});
    _success("Program dihapus");
  }

  void _addSub(int p) {
    (_rows[p]["sub"] as List).add({
      "program": TextEditingController(),
      "anggaran": TextEditingController(),
      "keterangan": TextEditingController(),
      "sub": <Map<String, dynamic>>[],
    });
    setState(() => openIndex = p);
  }

  void _addSubSub(int p, int s) {
    (_rows[p]["sub"][s]["sub"] as List).add({
      "program": TextEditingController(),
      "anggaran": TextEditingController(),
      "keterangan": TextEditingController(),
      "sub": <Map<String, dynamic>>[],
    });
    setState(() {});
  }

  void _deleteSub(int p, int s) {
    (_rows[p]["sub"] as List).removeAt(s);
    setState(() {});
    _success("Sub-program dihapus");
  }

  void _deleteSubSub(int p, int s, int ss) {
    (_rows[p]["sub"][s]["sub"] as List).removeAt(ss);
    setState(() {});
    _success("Sub-sub program dihapus");
  }

  // =========================
  // TOTAL
  // =========================
  double _parse(String t) =>
      double.tryParse(t.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  double get totalAnggaran =>
      _rows.fold(0, (s, r) => s + _parse(r["anggaran"].text));

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
              "TABEL PROGRAM & ANGGARAN",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // BARIS COUNT CHIP
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_labelChip("${_rows.length} baris")],
        ),
        const SizedBox(height: 8),

        _header(),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (_, i) => _programCard(i),
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
          _addRow();
          setState(() => openIndex = _rows.length - 1);
          _success("Program baru ditambahkan");
        },
      ),
    );
  }

  // =========================
  // PROGRAM CARD
  // =========================
  Widget _programCard(int i) {
    final row = _rows[i];
    final sub = row["sub"] as List<Map<String, dynamic>>;

    return Card(
      color: Color(0xFFBEF8FF),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => openIndex = openIndex == i ? null : i),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
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
                          num([i + 1]),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: Text(
                      row["program"].text.isEmpty
                          ? "— Program —"
                          : row["program"].text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(rupiah(_parse(row["anggaran"].text))),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row["keterangan"].text.isEmpty
                          ? "-"
                          : row["keterangan"].text,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final ok = await showConfirmDeleteDialog(context);
                      if (!ok) return;

                      _deleteRow(i);
                      _showDeleteSuccess("Program dihapus");
                    },
                  ),
                ],
              ),
            ),
          ),
          if (openIndex == i) _expanded(i, sub),
        ],
      ),
    );
  }

  // =========================
  // EXPANDED FORM
  // =========================
  Widget _expanded(int i, List<Map<String, dynamic>> sub) {
    final theme = Theme.of(context).colorScheme;
    final row = _rows[i];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          _input("Program", row["program"]),
          _input("Anggaran", row["anggaran"]),
          _input("Keterangan", row["keterangan"]),
          const Divider(),

          for (int s = 0; s < sub.length; s++)
            Builder(
              builder: (_) {
                final List<Map<String, dynamic>> subSub = sub[s]["sub"];

                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              num([i + 1, s + 1]),
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
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final ok = await showConfirmDeleteDialog(context);
                              if (!ok) return;

                              _deleteSub(i, s);
                              _showDeleteSuccess("Sub program dihapus");
                            },
                          ),
                        ],
                      ),
                      _input("Program", sub[s]["program"]),
                      _input("Anggaran", sub[s]["anggaran"]),
                      _input("Keterangan", sub[s]["keterangan"]),

                      for (int ss = 0; ss < subSub.length; ss++)
                        Padding(
                          padding: const EdgeInsets.only(left: 24, bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      num([i + 1, s + 1, ss + 1]),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      "Sub-Sub Program",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    onPressed: () => _deleteSubSub(i, s, ss),
                                  ),
                                ],
                              ),
                              _input("Program", subSub[ss]["program"]),
                              _input("Anggaran", subSub[ss]["anggaran"]),
                              _input("Keterangan", subSub[ss]["keterangan"]),
                            ],
                          ),
                        ),

                      Align(
                        key: ValueKey("add-subsub-$i-$s"),
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: Icon(
                            Icons.add_circle,
                            color: theme.primary,
                            size: 18,
                          ),
                          label: Text(
                            "Tambah Sub-Sub Program",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                          onPressed: () => _addSubSub(i, s),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),

          // ✅ FIX UTAMA: tombol ini SELALU ada
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
              onPressed: () => _addSub(i),
            ),
          ),
        ],
      ),
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
}

const TextStyle _th = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
