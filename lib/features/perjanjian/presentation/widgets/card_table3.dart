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

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (_, i) => _programCard(i),
        ),

        // ✅ TOMBOL TAMBAH PROGRAM UTAMA
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
        color: Colors.blueGrey.shade100,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          "Tambah Program",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _addRow();
          setState(() {
            openIndex = _rows.length - 1; // auto expand
          });
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
                    child: Text(
                      num([i + 1]),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                    onPressed: () => _deleteRow(i),
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
              builder: (context) {
                final List<Map<String, dynamic>> subSub = sub[s]["sub"];
                return Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          num([i + 1, s + 1]),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _input("Sub Program", sub[s]["program"]),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteSub(i, s),
                        ),
                      ],
                    ),

                    // SUB-SUB
                    for (int ss = 0; ss < subSub.length; ss++)
                      Padding(
                        padding: const EdgeInsets.only(left: 32, bottom: 6),
                        child: Row(
                          children: [
                            Text(
                              num([i + 1, s + 1, ss + 1]),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _input(
                                "Sub-Sub Program",
                                subSub[ss]["program"],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _deleteSubSub(i, s, ss),
                            ),
                          ],
                        ),
                      ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Tambah Sub-Sub"),
                        onPressed: () => _addSubSub(i, s),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Tambah Sub Program"),
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
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 6,
            child: Text(
              "JUMLAH",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rupiah(totalAnggaran),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  void _success(String m) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx != null) AppSnackbar.success(ctx, m);
  }
}

const TextStyle _th = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
