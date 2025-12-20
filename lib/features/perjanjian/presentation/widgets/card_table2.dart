// lib/presentation/widgets/card_table2.dart
import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/core/widgets/ui_helpers/app_snackbar.dart';
import 'package:rsud_lapkin_mobile/features/perjanjian/presentation/pages/form_perjanjian_page.dart';

class CardTable2Widget extends StatefulWidget {
  final SharedRowControllers sharedRows;
  final List<List<TextEditingController>> triwulanRows;

  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;

  final VoidCallback onRowsChanged;

  const CardTable2Widget({
    super.key,
    required this.sharedRows,
    required this.triwulanRows,
    required this.onAddRow,
    required this.onDeleteRow,
    required this.onRowsChanged,
  });

  @override
  State<CardTable2Widget> createState() => _CardTable2WidgetState();
}

class _CardTable2WidgetState extends State<CardTable2Widget>
    with TickerProviderStateMixin {
  /// setiap baris: 7 kolom
  // final List<List<TextEditingController>> _rows = [];

  /// index card yang terbuka (accordion mode)
  int? _openIndex;

  bool _autoRowAdded = false; // ✅ WAJIB

  List<List<TextEditingController>> get _rows => widget.triwulanRows;

  @override
  void initState() {
    super.initState();
    //_addRow();
  }

  List<List<String>> getRowsAsStrings() {
    final result = <List<String>>[];

    final rowCount = widget.sharedRows.length;

    for (int i = 0; i < rowCount; i++) {
      final shared = widget.sharedRows[i];
      final triwulan = widget.triwulanRows[i];

      final target = shared[3].text.trim();
      final satuan = shared[2].text.trim();

      // 👉 Gabungkan target + satuan
      final targetWithSatuan = satuan.isNotEmpty ? "$target $satuan" : target;

      result.add([
        shared[0].text.trim(), // Sasaran
        shared[1].text.trim(), // Indikator
        targetWithSatuan, // ✅ Target + Satuan
        triwulan[0].text.trim(), // TW I
        triwulan[1].text.trim(), // TW II
        triwulan[2].text.trim(), // TW III
        triwulan[3].text.trim(), // TW IV
      ]);
    }

    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ===================================================================
  // ROW MANAGEMENT
  // ===================================================================
  // ADD ROW
  // void _addRow() {
  //   setState(() {
  //     _rows.add(List.generate(7, (_) => TextEditingController()));
  //   });
  // }

  // void _addRow() {
  //   final newRow = List.generate(7, (_) => TextEditingController());

  //   // Listener hanya cek perubahan
  //   for (final ctrl in newRow) {
  //     ctrl.addListener(_onRowChanged);
  //   }

  //   setState(() {
  //     _rows.add(newRow);
  //     _autoRowAdded = false; // reset flag setiap row baru
  //   });
  // }

  // void _onRowChanged() {
  //   if (_rows.isEmpty) return;

  //   final lastRow = _rows.last;

  //   final hasData = lastRow.any((c) => c.text.trim().isNotEmpty);

  //   // 🔒 hanya add sekali
  //   if (hasData && !_autoRowAdded) {
  //     _autoRowAdded = true;
  //     _addRow();
  //   }

  //   setState(() {}); // update summary / header
  // }

  // // DELETE ROW
  // void _deleteRow(int index) {
  //   debugPrint(
  //     "🗑 DELETE REQUEST [TABEL2] → index: $index, total rows: ${_rows.length}",
  //   );

  //   // --- Validasi Index ---
  //   if (index < 0 || index >= _rows.length) {
  //     debugPrint(
  //       "❌ DELETE FAILED [TABEL2] → index out of range. Tidak jadi hapus.",
  //     );
  //     _showDeleteError("Gagal menghapus: index tidak valid");
  //     return;
  //   }

  //   // ---- Ambil summary row untuk pesan snackbar ----
  //   final deletedSummary = _summary(_rows[index]);

  //   // --- Kasus: hanya ada 1 baris, jangan hapus hanya kosongkan ---
  //   if (_rows.length == 1) {
  //     debugPrint("🗑 DELETE [TABEL2] → Hanya satu baris. Membersihkan saja...");
  //     for (final c in _rows.first) {
  //       if (!c.isClosed)
  //         c.clear();
  //       else {
  //         debugPrint("⚠ Controller [TABEL2] sudah closed, skip clear");
  //       }
  //     }

  //     setState(() {});

  //     debugPrint(
  //       "🗑 DELETE [TABEL2] → Menghapus row ke-$index "
  //       "(kolom: ${_rows.first.length} controller).",
  //     );

  //     _showDeleteSuccess("Baris 1 telah dikosongkan");
  //     return;
  //   }

  //   // ---- Hapus controller dengan aman ----
  //   for (final c in _rows[index]) {
  //     if (!c.isClosed) {
  //       c.dispose();
  //     } else {
  //       debugPrint("⚠ [TABEL2]Controller sudah closed, skip dispose");
  //     }
  //   }

  //   // ---- Update UI ----
  //   setState(() {
  //     _rows.removeAt(index);

  //     // Tutup accordion jika row yang dihapus adalah row terbuka
  //     if (_openIndex == index) {
  //       _openIndex = null;
  //     }

  //     // Jika openIndex melebihi panjang list setelah delete → geser
  //     if (_openIndex != null && _openIndex! >= _rows.length) {
  //       _openIndex = _rows.length - 1;
  //     }
  //   });

  //   debugPrint("✅ DELETE SUCCESS [TABEL2] → removed row index: $index");

  //   // ---- Snackbar sukses ----
  //   _showDeleteSuccess("Baris ${index + 1} dihapus: \"$deletedSummary\"");
  // }

  // CEK APAKAH ROW KOSONG
  bool _rowIsEmpty(int i) {
    final shared = widget.sharedRows[i];
    final triwulan = widget.triwulanRows[i];

    return [...shared, ...triwulan].every((c) => c.text.trim().isEmpty);
  }

  // SUMMARY TEXT
  String _summary(int i) {
    final shared = widget.sharedRows[i];

    for (final c in shared) {
      final t = c.text.trim();
      if (t.isNotEmpty) {
        return t.length > 30 ? '${t.substring(0, 30)}…' : t;
      }
    }
    return '— kosong —';
  }

  // TOGGLE CARD
  void _toggleCard(int index) {
    setState(() {
      _openIndex = (_openIndex == index) ? null : index;
    });
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

  // CONFIRM DELETE DIALOG
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

  // ===================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    final rowCount = widget.sharedRows.length;

    // ✅ PAKSA SINKRON
    while (widget.triwulanRows.length < rowCount) {
      widget.triwulanRows.add(List.generate(4, (_) => TextEditingController()));
    }

    // lanjut render normal

    // LABELS
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "TABEL TARGET SASARAN",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),
        // BARIS COUNT CHIP
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_labelChip("$rowCount baris")],
        ),
        const SizedBox(height: 8),

        // LIST OF CARDS
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rowCount,
          itemBuilder: (context, i) {
            final shared = widget.sharedRows[i];
            final triwulan = widget.triwulanRows[i];

            return _TriwulanCardItem(
              index: i,
              isOpen: _openIndex == i,
              isEmpty: _rowIsEmpty(i),
              headerSummary: _summary(i),
              onToggle: () => _toggleCard(i),
              onDelete: () {
                widget.onDeleteRow(i);
                setState(() {}); // 🔥 refresh langsung
              },
              onConfirmDelete: () => showConfirmDeleteDialog(context),
              child: Column(
                children: [
                  _input("Sasaran", shared[0]), // shared[0] = sasaran
                  const SizedBox(height: 8),
                  _input("Indikator", shared[1]), // shared[1] = indikator
                  const SizedBox(height: 8),
                  _targetWithSatuan(
                    shared[3], // target
                    shared[2], // satuan
                  ), // shared[3] = target
                  const SizedBox(height: 8),
                  _input("Triwulan I", triwulan[0]), // triwulan[0] = TW I
                  const SizedBox(height: 8),
                  _input("Triwulan II", triwulan[1]), // triwulan[1] = TW II
                  const SizedBox(height: 8),
                  _input("Triwulan III", triwulan[2]), // triwulan[2] = TW III
                  const SizedBox(height: 8),
                  _input("Triwulan IV", triwulan[3]), // triwulan[3] = TW IV
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // ADD ROW BUTTON
        TextButton.icon(
          onPressed: () {
            widget.onAddRow();
            widget.onRowsChanged(); // ⬅️ PAKSA REBUILD
          },
          icon: Icon(Icons.add_circle, color: theme.primary),
          label: Text(
            "Tambah Baris",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                "Catatan: Isi tabel sesuai dengan sasaran, indikator, target dan target triwulan yang telah ditetapkan dalam perjanjian.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // modern input style
  Widget _input(String label, TextEditingController ctrl) {
    final theme = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: TextField(
        controller: ctrl,
        minLines: 1,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14),
          filled: true,
          fillColor: theme.surfaceContainerLowest,
          isDense: true, // <<< membuat tinggi lebih kecil
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
        onChanged: (_) {
          widget.onRowsChanged();
          setState(() {});
        },
      ),
    );
  }

  Widget _targetWithSatuan(
    TextEditingController targetCtrl,
    TextEditingController satuanCtrl,
  ) {
    final theme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: AnimatedBuilder(
        animation: Listenable.merge([targetCtrl, satuanCtrl]),
        builder: (context, _) {
          final target = targetCtrl.text.trim();
          final satuan = satuanCtrl.text.trim();

          final value = target.isEmpty && satuan.isEmpty
              ? ""
              : "$target $satuan";

          return TextField(
            controller: TextEditingController(text: value),
            enabled: false, // 🔒 read-only (mirroring)
            minLines: 1,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: "Target",
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
          );
        },
      ),
    );
  }

  // ===================================================================
}

//
extension ControllerSafeDispose on TextEditingController {
  bool get isClosed {
    try {
      // akses apapun yang memerlukan controller hidup
      text;
      return false; // tidak error → belum disposed
    } catch (_) {
      return true; // error → sudah disposed
    }
  }
}

// ===================================================================
// CARD WIDGET
// ===================================================================
class _TriwulanCardItem extends StatefulWidget {
  final int index;
  final String headerSummary;
  final bool isOpen;
  final bool isEmpty;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Widget child;

  final Future<bool> Function() onConfirmDelete;

  const _TriwulanCardItem({
    required this.index,
    required this.headerSummary,
    required this.isOpen,
    required this.isEmpty,
    required this.onToggle,
    required this.onDelete,
    required this.child,
    required this.onConfirmDelete, // ✅
  });

  @override
  State<_TriwulanCardItem> createState() => _TriwulanCardItemState();
}

class _TriwulanCardItemState extends State<_TriwulanCardItem>
    with TickerProviderStateMixin {
  late final AnimationController _rotation;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.isOpen ? 0.0 : 25,
    );
  }

  @override
  void didUpdateWidget(covariant _TriwulanCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      widget.isOpen ? _rotation.reverse() : _rotation.forward();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  // ===================================================================
  @override
  Widget build(BuildContext context) {
    // CARD
    return Card(
      color: Color(0xFFBEF8FF),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        child: Column(
          // HEADER & CHILDREN
          children: [
            InkWell(
              onTap: widget.onToggle,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // NUMBER CHIP
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${widget.index + 1}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    // SUMMARY TEXT
                    Expanded(
                      child: Text(
                        widget.headerSummary,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // DELETE BUTTON
                    IconButton(
                      onPressed: () async {
                        final ok = await widget.onConfirmDelete();
                        if (ok) widget.onDelete();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE74C3C),
                      ),
                      splashRadius: 20,
                    ),

                    // if (widget.isEmpty)
                    // IconButton(
                    //   onPressed: () async {
                    //     final ok =
                    //         await (context
                    //                 .findAncestorStateOfType<
                    //                   _CardTable2WidgetState
                    //                 >()
                    //                 ?.showConfirmDeleteDialog(context) ??
                    //             Future.value(false));

                    //     if (ok) widget.onDelete();
                    //   },
                    //   icon: Icon(
                    //     Icons.delete_outline,
                    //     color: Color(0xFFE74C3C),
                    //   ),
                    //   splashRadius: 20,
                    // ),

                    // ARROW ICON
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.25).animate(_rotation),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),

            // CHILD CONTENT
            if (widget.isOpen)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: widget.child,
              ),
          ],
        ),
      ),
    );
  }
}
