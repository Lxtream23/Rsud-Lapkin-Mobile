import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/widgets/ui_helpers/app_snackbar.dart';

class CardTable4Widget extends StatefulWidget {
  const CardTable4Widget({super.key});

  @override
  State<CardTable4Widget> createState() => _CardTable4WidgetState();
}

class _CardTable4WidgetState extends State<CardTable4Widget> {
  final List<Map<String, dynamic>> _rows = [];
  int? openIndex;

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  // =========================================================
  // PUBLIC → PDF
  // =========================================================
  List<Map<String, dynamic>> getRowsAsStrings() {
    return _rows
        .asMap()
        .entries
        .map((e) => _mapRow(e.value, [e.key + 1]))
        .toList();
  }

  Map<String, dynamic> _mapRow(Map<String, dynamic> r, List<int> path) {
    return {
      "no": num(path),
      "program": r["program"].text,
      "anggaran": r["anggaran"].text,
      "tw1": r["tw1"].text,
      "tw2": r["tw2"].text,
      "tw3": r["tw3"].text,
      "tw4": r["tw4"].text,
      "keterangan": r["keterangan"].text,
      "sub": (r["sub"] as List)
          .asMap()
          .entries
          .map((e) => _mapRow(e.value, [...path, e.key + 1]))
          .toList(),
    };
  }

  // =========================================================
  // HELPERS
  // =========================================================
  String num(List<int> path) => path.join(".");

  int _parse(String v) =>
      int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  int _totalTW(Map<String, dynamic> r) =>
      _parse(r["tw1"].text) +
      _parse(r["tw2"].text) +
      _parse(r["tw3"].text) +
      _parse(r["tw4"].text);

  int _sisa(Map<String, dynamic> r) => _parse(r["anggaran"].text) - _totalTW(r);

  bool _warning(Map<String, dynamic> r) =>
      _totalTW(r) > _parse(r["anggaran"].text);

  String rupiah(int v) {
    final s = v.abs().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if ((s.length - i) % 3 == 0 && i != 0) b.write('.');
      b.write(s[i]);
    }
    return "Rp ${b.toString()}";
  }

  // =========================================================
  // DATA
  // =========================================================
  Map<String, dynamic> _newRow() => {
    "program": TextEditingController(),
    "anggaran": TextEditingController(),
    "tw1": TextEditingController(),
    "tw2": TextEditingController(),
    "tw3": TextEditingController(),
    "tw4": TextEditingController(),
    "keterangan": TextEditingController(),
    "sub": <Map<String, dynamic>>[],
  };

  void _addRow() => setState(() => _rows.add(_newRow()));
  void _addSub(int p) =>
      setState(() => (_rows[p]["sub"] as List).add(_newRow()));
  void _addSubSub(int p, int s) =>
      setState(() => (_rows[p]["sub"][s]["sub"] as List).add(_newRow()));

  void _deleteRow(int i) {
    if (_rows.length == 1) {
      final r = _rows.first;

      r["program"].clear();
      r["anggaran"].clear();
      r["tw1"].clear();
      r["tw2"].clear();
      r["tw3"].clear();
      r["tw4"].clear();
      r["keterangan"].clear();

      (r["sub"] as List).clear();

      setState(() {});
      return;
    }

    _rows.removeAt(i);
    setState(() {});
  }

  void _deleteSub(int p, int s) {
    (_rows[p]["sub"] as List).removeAt(s);
    setState(() {});
    _success("Sub program dihapus");
  }

  void _deleteSubSub(int p, int s, int ss) {
    (_rows[p]["sub"][s]["sub"] as List).removeAt(ss);
    setState(() {});
    _success("Sub-sub program dihapus");
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

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const Text(
          "TABEL TARGET PROGRAM",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_labelChip("${_rows.length} baris")],
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (_, i) => _programCard(i),
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(Icons.add_circle, color: theme.primary),
            label: Text(
              "Tambah Baris",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
            ),
            onPressed: () {
              _addRow();
              setState(() => openIndex = _rows.length - 1);
            },
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CARD
  // =========================================================
  Widget _programCard(int i) {
    final row = _rows[i];
    final sub = row["sub"] as List<Map<String, dynamic>>;

    return Card(
      color: const Color(0xFFBEF8FF),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => openIndex = openIndex == i ? null : i),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  _numBox(num([i + 1])),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row["program"].text.isEmpty
                              ? "— Program —"
                              : row["program"].text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _sisaText(row),
                      ],
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

                  AnimatedRotation(
                    turns: openIndex == i ? -0.25 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.chevron_left),
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

  // =========================================================
  // EXPANDED
  // =========================================================
  Widget _expanded(int i, List<Map<String, dynamic>> sub) {
    final r = _rows[i];
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          _input("Program", r["program"]),
          _input("Anggaran", r["anggaran"], isNumber: true),
          _input("Triwulan I", r["tw1"], isNumber: true),
          _input("Triwulan II", r["tw2"], isNumber: true),
          _input("Triwulan III", r["tw3"], isNumber: true),
          _input("Triwulan IV", r["tw4"], isNumber: true),
          _input("Keterangan", r["keterangan"]),
          const Divider(),

          for (int s = 0; s < sub.length; s++) _subBlock(i, s, sub[s]),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: Icon(Icons.add_circle, color: theme.primary),
              label: Text(
                "Tambah Sub Program",
                style: TextStyle(
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

  Widget _subBlock(int i, int s, Map<String, dynamic> r) {
    final subSub = r["sub"] as List<Map<String, dynamic>>;
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowHeader(
            num([i + 1, s + 1]),
            "Sub Program",
            r,
            onDelete: () => _deleteSub(i, s),
          ),

          _input("Program", r["program"]),
          _input("Anggaran", r["anggaran"], isNumber: true),
          _input("Triwulan I", r["tw1"], isNumber: true),
          _input("Triwulan II", r["tw2"], isNumber: true),
          _input("Triwulan III", r["tw3"], isNumber: true),
          _input("Triwulan IV", r["tw4"], isNumber: true),
          _input("Keterangan", r["keterangan"]),

          for (int ss = 0; ss < subSub.length; ss++)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: _subSubBlock(i, s, ss, subSub[ss]),
            ),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: Icon(Icons.add_circle, color: theme.primary, size: 18),
              label: Text(
                "Tambah Sub-Sub Program",
                style: TextStyle(
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
  }

  Widget _subSubBlock(int i, int s, int ss, Map<String, dynamic> r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowHeader(
          num([i + 1, s + 1, ss + 1]),
          "Sub-Sub Program",
          r,
          onDelete: () => _deleteSubSub(i, s, ss),
        ),
        _input("Program", r["program"]),
        _input("Anggaran", r["anggaran"], isNumber: true),
        _input("Triwulan I", r["tw1"], isNumber: true),
        _input("Triwulan II", r["tw2"], isNumber: true),
        _input("Triwulan III", r["tw3"], isNumber: true),
        _input("Triwulan IV", r["tw4"], isNumber: true),
        _input("Keterangan", r["keterangan"]),
      ],
    );
  }

  // =========================================================
  // COMPONENTS
  // =========================================================
  Widget _rowHeader(
    String no,
    String title,
    Map<String, dynamic> r, {
    required VoidCallback onDelete,
  }) {
    return Row(
      children: [
        _numBox(no),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              _sisaText(r),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: () async {
            final ok = await showConfirmDeleteDialog(context);
            if (!ok) return;

            onDelete();
            _showDeleteSuccess("$title dihapus");
          },
        ),
      ],
    );
  }

  Widget _sisaText(Map<String, dynamic> r) {
    final sisa = _sisa(r);
    final warn = sisa < 0;

    return Text(
      warn ? "⚠ Kelebihan: ${rupiah(sisa.abs())}" : "Sisa: ${rupiah(sisa)}",
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: warn ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _numBox(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController c, {
    bool isNumber = false,
  }) {
    final theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.surfaceContainerLowest,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

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

  void _success(String m) {
    final ctx = overlaySnackbarKey.currentContext;
    if (ctx != null) AppSnackbar.success(ctx, m);
  }
}
