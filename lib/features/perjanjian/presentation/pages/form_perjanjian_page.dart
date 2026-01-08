import 'package:flutter/material.dart';
// import 'package:auto_size_text/auto_size_text.dart';
import 'dart:typed_data';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../presentation/widgets/card_table1.dart';
import '../../presentation/widgets/card_table2.dart';
import '../../presentation/widgets/card_table3.dart';
import '../../presentation/widgets/card_table4.dart';
import 'package:rsud_lapkin_mobile/core/widgets/ui_helpers/app_snackbar.dart';

import 'package:rsud_lapkin_mobile/features/perjanjian/presentation/pdf/perjanjian_pdf_generator.dart';

import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../pdf/pdf_preview_page.dart';
import '..//controllers/services/perjanjian_service.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:convert';

enum FormMode { create, edit, view }

class FormPerjanjianPage extends StatefulWidget {
  final FormMode mode;
  final String? perjanjianId;

  const FormPerjanjianPage({
    Key? key,
    this.mode = FormMode.create,
    this.perjanjianId,
  }) : assert(
         mode != FormMode.edit || perjanjianId != null,
         'EDIT mode wajib punya perjanjianId',
       );

  @override
  State<FormPerjanjianPage> createState() => _FormPerjanjianPageState();
}

Map<String, dynamic>? userProfile;
//Uint8List? signatureRightBytes;

String? pangkatUser;
String? nipUser;

class _FormPerjanjianPageState extends State<FormPerjanjianPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController namaPihakPertamaController =
      TextEditingController();

  final TextEditingController namaPihakKeduaController =
      TextEditingController();

  final TextEditingController jabatanPihakPertamaController =
      TextEditingController();

  final TextEditingController jabatanController = TextEditingController();
  final TextEditingController tugasController = TextEditingController();

  List<TextEditingController> fungsiControllers =
      []; // untuk fungsi a-seterusnya

  String? selectedJabatanPihakKedua;

  String _progressMessage = '';
  double _progressValue = 0.0;

  Timer? _fakeProgressTimer;
  late final String? _perjanjianId;

  final List<String> jabatanList = [
    'Direktur',
    'Wadir Umum dan Keuangan',
    'Wadir Pelayanan',
    'Kabid Pelayanan',
    'Kabid Pelayanan Keperawatan',
    'Kabid Pelayanan Penunjang',
    'Kabag SDM dan Pengembangan',
    'Kabag Umum',
    'Kabag Keuangan',
    'Ketua Tim Kerja',
    'Admin/Staf',
  ];

  // ================= TABLE 1 & 2 SHARED =================
  late final SharedRowControllers sharedRows;

  // khusus table 2 (triwulan I–IV)
  final List<List<TextEditingController>> triwulanRows = [];
  // ======================================================

  // ================= TABLE 3 & 4 DATA =================

  final List<ProgramAnggaranRow> programRows = [];
  // ======================================================

  // Keys untuk mengakses method/state widget tabel (dynamic-cast dipakai)
  final GlobalKey table1Key = GlobalKey();
  final GlobalKey table2Key = GlobalKey();
  final GlobalKey table3Key = GlobalKey();
  final GlobalKey table4Key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    //loadUserSignature();
    getPangkatUser();
    getNipUser();

    // Default Nama Lengkap
    namaPihakKeduaController.text = "Direktur";

    // Default Jabatan
    selectedJabatanPihakKedua = "Direktur";

    // =========================
    // TABLE 1 & 2 (SHARED)
    // =========================
    sharedRows = SharedRowControllers();
    sharedRows.addRow(); // minimal 1 row

    //triwulanRows.add(List.generate(4, (_) => TextEditingController()));

    // =========================
    // TABLE 3 & 4 (PROGRAM & ANGGARAN)
    // =========================
    if (programRows.isEmpty) {
      programRows.add(ProgramAnggaranRow());
    }

    // =========================
    // FUNGSI
    // =========================
    if (fungsiControllers.isEmpty) {
      _addFungsiField();
    } else {
      _attachListener(0);
    }
    _perjanjianId = widget.mode == FormMode.edit ? widget.perjanjianId : null;
    debugPrint('FORM INIT | perjanjianId=$_perjanjianId');

    if (widget.mode == FormMode.edit && widget.perjanjianId != null) {
      _loadPerjanjianFromDb(widget.perjanjianId!);
    }
  }

  Future<void> _loadPerjanjianFromDb(String id) async {
    final data = await supabase
        .from('perjanjian_kinerja')
        .select()
        .eq('id', id)
        .single();

    // === FORM UTAMA ===
    namaPihakPertamaController.text = data['nama_pihak_pertama'] ?? '';
    jabatanPihakPertamaController.text = data['jabatan_pihak_pertama'] ?? '';

    namaPihakKeduaController.text = data['nama_pihak_kedua'] ?? '';
    selectedJabatanPihakKedua = data['jabatan_pihak_kedua'];

    tugasController.text = data['tugas_detail'] ?? '';

    // === FUNGSI ===
    fungsiControllers.clear();
    final fungsiList = List<String>.from(data['fungsi_list'] ?? []);
    for (final f in fungsiList) {
      final c = TextEditingController(text: f);
      fungsiControllers.add(c);
    }
    _addFungsiField(); // biar tetap ada field kosong

    // === TABLE 1 ===
    sharedRows.dispose();
    sharedRows.rows.clear();
    for (final row in List.from(data['tabel1'] ?? [])) {
      sharedRows.rows.add(
        List.generate(4, (i) => TextEditingController(text: row[i] ?? '')),
      );
    }

    // === TABLE 2 (TRIWULAN) ===
    for (final row in triwulanRows) {
      for (final c in row) {
        c.dispose();
      }
    }
    triwulanRows.clear();

    for (final row in List.from(data['tabel2'] ?? [])) {
      triwulanRows.add(
        List.generate(4, (i) => TextEditingController(text: row[i] ?? '')),
      );
    }

    // =====================
    // === TABLE 3 & 4 ===
    // =====================
    for (final r in programRows) {
      r.dispose();
    }
    programRows.clear();

    // tabel3 & tabel4 punya struktur TREE yang sama
    final raw = data['tabel4'] ?? data['tabel3'];

    if (raw != null) {
      final List decoded = raw is String ? jsonDecode(raw) : raw;

      for (final item in decoded) {
        programRows.add(
          parseProgramRowFromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    // fallback biar UI tidak kosong
    if (programRows.isEmpty) {
      programRows.add(ProgramAnggaranRow());
    }

    setState(() {});
  }

  ProgramAnggaranRow parseProgramRowFromJson(Map<String, dynamic> json) {
    final row = ProgramAnggaranRow(
      program: TextEditingController(text: json['program'] ?? ''),
      anggaran: TextEditingController(text: json['anggaran'] ?? ''),
      keterangan: TextEditingController(text: json['keterangan'] ?? ''),
      tw1: TextEditingController(text: json['tw1'] ?? ''),
      tw2: TextEditingController(text: json['tw2'] ?? ''),
      tw3: TextEditingController(text: json['tw3'] ?? ''),
      tw4: TextEditingController(text: json['tw4'] ?? ''),
    );

    final subs = (json['sub'] as List? ?? []);
    for (final s in subs) {
      row.children.add(parseProgramRowFromJson(Map<String, dynamic>.from(s)));
    }

    return row;
  }

  // =========================================================
  // Management Table 1 & 2
  // =========================================================
  void addRow1() {
    setState(() {
      sharedRows.addRow();
      triwulanRows.add(List.generate(4, (_) => TextEditingController()));
    });
  }

  void deleteRow1(int index) {
    if (index < 0 || index >= sharedRows.length) return;

    // 🔒 KASUS: TINGGAL 1 BARIS → CLEAR SAJA
    if (sharedRows.length == 1) {
      setState(() {
        for (final c in sharedRows[0]) {
          c.clear();
        }
        for (final c in triwulanRows[0]) {
          c.clear();
        }
      });
      return; // ⛔ STOP, JANGAN LANJUT KE ASSERT
    }

    // 🗑 NORMAL DELETE
    setState(() {
      sharedRows.deleteRow(index);

      for (final c in triwulanRows[index]) {
        c.dispose();
      }
      triwulanRows.removeAt(index);
    });

    // ✅ ASSERT HANYA UNTUK NORMAL DELETE
    assert(
      sharedRows.length == triwulanRows.length,
      'Row length mismatch between Table 1 & Table 2',
    );
  }
  // =========================================================

  // =========================================================
  // Management Table 3 & 4
  // =========================================================
  ProgramAnggaranRow _getRowByPath(List<int> path) {
    ProgramAnggaranRow current = programRows[path[0] - 1];

    for (int i = 1; i < path.length; i++) {
      current = current.children[path[i] - 1];
    }

    return current;
  }

  void _addProgram() {
    setState(() {
      programRows.add(ProgramAnggaranRow());
    });
  }

  void _addSub(List<int> parentPath) {
    setState(() {
      final program = _getRowByPath(parentPath);
      program.children.add(ProgramAnggaranRow());
    });
  }

  void _addSubSub(List<int> path) {
    setState(() {
      if (path.length < 2) return;

      final parent = _getRowByPath(path);
      parent.children.add(ProgramAnggaranRow());
    });
  }

  void _deleteProgram(int index) {
    setState(() {
      if (programRows.length == 1) {
        programRows.first.program.clear();
        programRows.first.anggaran.clear();
        programRows.first.keterangan.clear();
        programRows.first.children.clear();
        return;
      }

      programRows.removeAt(index);
    });
  }

  void _deleteSub(List<int> path) {
    if (path.length < 2) return;

    setState(() {
      final parentPath = path.sublist(0, path.length - 1);
      final parent = _getRowByPath(parentPath);
      final index = path.last - 1;

      if (parent.children.length == 1) {
        parent.children.first.program.clear();
        parent.children.first.anggaran.clear();
        parent.children.first.keterangan.clear();
        parent.children.first.children.clear();
        return;
      }

      parent.children[index].dispose();
      parent.children.removeAt(index);
    });
  }

  void _deleteSubSub(List<int> path) {
    if (path.length < 3) return;

    setState(() {
      final parentPath = path.sublist(0, path.length - 1);
      final parent = _getRowByPath(parentPath);
      final index = path.last - 1;

      if (parent.children.length == 1) {
        parent.children.first.program.clear();
        parent.children.first.anggaran.clear();
        parent.children.first.keterangan.clear();
        parent.children.first.children.clear();
        return;
      }

      parent.children[index].dispose();
      parent.children.removeAt(index);
    });
  }

  // =========================================================

  @override
  void dispose() {
    namaPihakPertamaController.dispose();
    namaPihakKeduaController.dispose();
    jabatanPihakPertamaController.dispose();
    jabatanController.dispose();
    tugasController.dispose();

    for (final c in fungsiControllers) {
      if (!c.isDisposed) c.dispose();
    }

    sharedRows.dispose();

    for (final row in programRows) {
      row.dispose();
    }

    super.dispose();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  Future<void> _loadUserData() async {
    final data = await getUserProfile();

    if (data != null) {
      namaPihakPertamaController.text = data['nama_lengkap'] ?? "";
      jabatanPihakPertamaController.text = data['jabatan'] ?? "";
    }
  }

  Future<UserSignature?> loadUserSignature() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final profile = await supabase
        .from('profiles')
        .select('ttd')
        .eq('id', user.id)
        .maybeSingle();

    final String? url = profile?['ttd'];
    if (url == null || url.isEmpty) return null;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    return UserSignature(bytes: response.bodyBytes, url: url);
  }

  // Future<Uint8List?> loadUserSignature() async {
  //   try {
  //     debugPrint('🔍 loadUserSignature: start');

  //     final user = supabase.auth.currentUser;
  //     if (user == null) {
  //       debugPrint('⚠️ User null');
  //       return null;
  //     }

  //     debugPrint('✅ User ditemukan: ${user.id}');

  //     final profile = await supabase
  //         .from('profiles')
  //         .select('ttd')
  //         .eq('id', supabase.auth.currentUser!.id)
  //         .maybeSingle();

  //     final String? ttdPihakPertamaUrl = profile?['ttd'];

  //     if (profile == null) {
  //       debugPrint('⚠️ Profile tidak ditemukan');
  //       return null;
  //     }

  //     final url = profile['ttd']?.toString();
  //     if (url == null || url.isEmpty) {
  //       debugPrint('⚠️ TTD kosong');
  //       return null;
  //     }

  //     debugPrint('🌐 Download tanda tangan...');
  //     final response = await http
  //         .get(Uri.parse(url))
  //         .timeout(const Duration(seconds: 8));

  //     if (response.statusCode == 200) {
  //       debugPrint('✅ TTD berhasil diunduh');
  //       return response.bodyBytes;
  //     }

  //     debugPrint('❌ HTTP ${response.statusCode}');
  //     return null;
  //   } on TimeoutException {
  //     debugPrint('⏱ Timeout loadUserSignature');
  //     return null;
  //   } catch (e, s) {
  //     debugPrint('❌ Error loadUserSignature: $e');
  //     debugPrintStack(stackTrace: s);
  //     return null;
  //   }
  // }

  Future<String?> getUserSignatureUrl() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final data = await Supabase.instance.client
        .from('profiles')
        .select('ttd_url')
        .eq('id', user.id)
        .single();

    return data['ttd_url'];
  }

  Future<String?> getPangkatUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select('pangkat')
        .eq('id', user.id)
        .maybeSingle();

    return response?['pangkat'] as String?;
  }

  Future<String?> getNipUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('profiles')
          .select('nip')
          .eq('id', user.id)
          .maybeSingle();

      return response?['nip'] as String?;
    } catch (e) {
      debugPrint('❌ getNipUser error: $e');
      return null;
    }
  }

  Future<bool> _validateTtdPihakPertama() async {
    final signature = await loadUserSignature();

    if (signature == null || signature.bytes.isEmpty) {
      _showDeleteError(
        "Tanda tangan pihak pertama belum tersedia.\nSilakan upload tanda tangan terlebih dahulu di halaman profil saya.",
      );
      return false;
    }

    return true;
  }

  /// Ambil data dari setiap tabel dengan memanggil method yang tersedia di state widget.
  /// Kita memakai `dynamic` casting karena state class pada file widget bersifat private.
  Map<String, dynamic> _collectAllData() {
    final result = <String, dynamic>{};

    // --- TABEL 1 ---
    try {
      final t1State = table1Key.currentState;
      if (t1State != null && (t1State as dynamic).getRowsAsStrings != null) {
        result['table1'] = (t1State as dynamic).getRowsAsStrings();
      } else {
        result['table1'] = <List<String>>[];
      }
    } catch (e) {
      result['table1'] = <List<String>>[];
      result['table1_error'] = e.toString();
    }

    // --- TABEL 2 ---
    try {
      final t2State = table2Key.currentState;
      if (t2State != null && (t2State as dynamic).getRowsAsStrings != null) {
        result['table2'] = (t2State as dynamic).getRowsAsStrings();
      } else {
        result['table2'] = <List<String>>[];
      }
    } catch (e) {
      result['table2'] = <List<String>>[];
      result['table2_error'] = e.toString();
    }

    // --- TABEL 3 ---
    try {
      final t3State = table3Key.currentState;

      if (t3State != null && (t3State as dynamic).getRowsAsStrings != null) {
        result['table3'] = (t3State as dynamic).getRowsAsStrings();
      } else {
        result['table3'] = <Map<String, dynamic>>[];
      }
    } catch (e) {
      result['table3'] = <Map<String, dynamic>>[];
      result['table3_error'] = e.toString();
    }

    // --- TABEL 4 ---
    try {
      final t4State = table4Key.currentState;

      if (t4State != null && (t4State as dynamic).getRowsAsStrings != null) {
        result['table4'] = (t4State as dynamic).getRowsAsStrings();
      } else {
        result['table4'] = <Map<String, dynamic>>[];
      }
    } catch (e) {
      result['table4'] = <Map<String, dynamic>>[];
      result['table4_error'] = e.toString();
    }

    // --- FORM NORMAL ---
    result['namaPihakPertama'] = namaPihakPertamaController.text.trim();
    result['jabatanPihakPertama'] = jabatanPihakPertamaController.text.trim();

    result['namaPihakKedua'] = namaPihakKeduaController.text.trim();
    result['jabatanPihakKedua'] = selectedJabatanPihakKedua ?? "";

    result['tugasDetail'] = tugasController.text.trim();

    // FUNGSI (list aman selalu ada)
    result['fungsiList'] = fungsiControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return result;
  }

  // =========================================================

  Future<void> _onPreviewPdfPressed({
    required bool isEditMode,
    String? perjanjianId,
  }) async {
    // ===================== GUARD =====================
    if (isEditMode && perjanjianId == null) {
      throw Exception('EDIT MODE tapi perjanjianId = null');
    }

    if (!_validateInputs()) return;

    // ===================== VALIDATE TTD =====================
    final isTtdValid = await _validateTtdPihakPertama();
    if (!isTtdValid) return;

    // ===================== COLLECT DATA =====================
    final data = _collectAllData();

    data['table1'] = (data['table1'] ?? []).cast<List<String>>();
    data['table2'] = (data['table2'] ?? []).cast<List<String>>();
    data['table3'] =
        (data['table3'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    data['table4'] =
        (data['table4'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    data['fungsiList'] = fungsiControllers.map((c) => c.text).toList();

    // ===================== PROGRESS =====================
    _progressValue = 0;
    _progressMessage = 'Menyiapkan data...';
    _showProfessionalProgress();
    _startFakeProgress();

    try {
      // ===================== LOAD USER DATA =====================
      _updateProgress('Mengambil tanda tangan...');
      // final signatureRightBytes = await loadUserSignature();
      final signature = await loadUserSignature();

      if (signature == null) {
        _showDeleteError('TTD pihak pertama belum diupload');
        return;
      }

      final signatureRightBytes = signature.bytes;
      final ttdPihakPertamaUrl = signature.url;

      _updateProgress('Mengambil data pengguna...');
      final pangkatUser = await getPangkatUser();
      final nipUser = await getNipUser();

      // ===================== GENERATE PDF =====================
      _updateProgress('Menyusun dokumen PDF...');

      final Uint8List pdfBytes = await generatePerjanjianPdf(
        isApproved: false,

        namaPihak1: data['namaPihakPertama']!,
        jabatanPihak1: data['jabatanPihakPertama']!,
        pangkatPihak1: pangkatUser!,
        nipPihak1: nipUser!,

        namaPihak2: data['namaPihakKedua']!,
        jabatanPihak2: data['jabatanPihakKedua']!,

        pangkatPihak2: null,
        nipPihak2: null,

        signatureRightBytes: signatureRightBytes,
        signatureLeftBytes: null,

        tabel1: data['table1'],
        tabel2: data['table2'],
        tabel3: data['table3'],
        tabel4: data['table4'],
        tugasDetail: data['tugasDetail'],
        fungsiList: List<String>.from(data['fungsiList']),
      );

      // ===================== CLOSE PROGRESS =====================
      _stopFakeProgress();
      if (Navigator.canPop(context)) Navigator.pop(context);

      // ===================== PREVIEW =====================
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewPage(
            pdfBytes: pdfBytes,
            status: isEditMode ? 'Edit' : 'Proses',
            isSaved: false,
            perjanjianId: perjanjianId,
            onSave: () async {
              // ===================== CONFIRM =====================
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Simpan Perjanjian'),
                  content: Text(
                    isEditMode
                        ? 'Perubahan akan disimpan sebagai versi baru.'
                        : 'Perjanjian akan disimpan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              _showProfessionalProgress();
              _startFakeProgress();

              final service = PerjanjianService();

              final payload = {
                ...data,
                'pangkatPihak1': pangkatUser,
                'nipPihak1': nipUser,
                'ttdPihak1': ttdPihakPertamaUrl,
              };

              // ===================== SAVE =====================
              if (isEditMode) {
                await service.updatePerjanjian(
                  perjanjianId: perjanjianId!,
                  data: payload,
                  pdfBytes: pdfBytes,
                );
              } else {
                await service.createPerjanjian(
                  data: payload,
                  pdfBytes: pdfBytes,
                );
              }

              _stopFakeProgress();

              // 🔥 PENTING: pop SEKALI dengan RESULT
              Navigator.pop(context, {
                'action': isEditMode ? 'updated' : 'created',
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditMode
                        ? '✅ Perjanjian berhasil diperbarui'
                        : '✅ Perjanjian berhasil disimpan',
                  ),
                ),
              );
            },
          ),
        ),
      );

      // ===================== RETURN RESULT KE PARENT =====================
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    } catch (e, s) {
      _stopFakeProgress();
      if (Navigator.canPop(context)) Navigator.pop(context);
      debugPrint('ERROR PDF: $e');
      debugPrintStack(stackTrace: s);
      _showDeleteError('Gagal membuat PDF');
    }
  }

  bool _validateInputs() {
    if (namaPihakPertamaController.text.trim().isEmpty) {
      _showDeleteError("Nama Pihak Pertama wajib diisi");
      return false;
    }

    if (jabatanPihakPertamaController.text.trim().isEmpty) {
      _showDeleteError("Jabatan Pihak Pertama wajib diisi");
      return false;
    }

    if (namaPihakKeduaController.text.trim().isEmpty) {
      _showDeleteError("Nama Pihak Kedua wajib diisi");
      return false;
    }

    if (selectedJabatanPihakKedua == null) {
      _showDeleteError("Jabatan Pihak Kedua wajib dipilih");
      return false;
    }

    return true;
  }

  void _updateProgress(String message, {double? value}) {
    setState(() {
      _progressMessage = message;
      if (value != null) _progressValue = value;
    });
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _progressMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProfessionalProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // ❌ disable back
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Memproses Dokumen', style: AppTextStyle.bold16),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _progressValue,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _progressMessage,
                  key: ValueKey(_progressMessage),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startFakeProgress() {
    _fakeProgressTimer?.cancel();
    _fakeProgressTimer = Timer.periodic(const Duration(milliseconds: 120), (
      timer,
    ) {
      if (_progressValue >= 0.9) {
        timer.cancel();
      } else {
        setState(() {
          _progressValue += 0.01;
        });
      }
    });
  }

  void _stopFakeProgress() {
    _fakeProgressTimer?.cancel();
  }

  // void _onSavePressed() {
  //   final all = _collectAllData();
  //   // untuk demo: tampilkan di dialog; di implementasi nyata: kirim ke API / simpan lokal
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Collected data (preview)'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: SingleChildScrollView(child: Text(all.toString())),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Dropdown jabatan
  Widget _dropdown(String? value, void Function(String?) onChanged) {
    final theme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      value: value,
      isDense: true, // <<< kecilkan tinggi
      decoration: InputDecoration(
        labelText: "Jabatan",
        labelStyle: TextStyle(fontSize: 14),
        filled: true,
        fillColor: theme.surfaceContainerLowest,
        isDense: true, // <<< menambah efek tinggi lebih kecil
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12, // <<< kecilkan tinggi dropdown
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
        ),
      ),
      items: jabatanList
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildModernInput({
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    final theme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      minLines: 1,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: theme.surfaceContainerLowest,
        isDense: true, // <<< membuat tinggi lebih kecil
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.outline.withOpacity(0.18)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12, // <<< tinggi field
        ),
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  //-------------------------------------

  //============ Fungsi management ===========
  void _addFungsiField() {
    final ctrl = TextEditingController();

    ctrl.addListener(() {
      final isLast = ctrl == fungsiControllers.last;

      if (isLast && ctrl.text.trim().isNotEmpty) {
        _addFungsiField(); // auto append
        setState(() {});
      }
    });

    setState(() {
      fungsiControllers.add(ctrl);
    });
  }

  void _removeFungsi(int index) {
    debugPrint(
      "🗑 DELETE REQUEST [FUNGSI] → index: $index, total: ${fungsiControllers.length}",
    );

    // --- Validasi Index ---
    if (index < 0 || index >= fungsiControllers.length) {
      debugPrint("❌ DELETE FAILED [FUNGSI] → index tidak valid");
      _showDeleteError("Gagal menghapus: index tidak valid");
      return;
    }

    final summary = fungsiControllers[index].text.trim().isEmpty
        ? "— kosong —"
        : fungsiControllers[index].text.trim();

    // --- Jika hanya ada 1 fungsi, hanya clear, tidak hapus ---
    if (fungsiControllers.length == 1) {
      debugPrint("🗑 DELETE [FUNGSI] → hanya satu, clear saja");
      fungsiControllers.first.clear();

      setState(() {});
      _showDeleteSuccess("Kolom fungsi baris ke 1 dikosongkan");
      return;
    }

    // --- Dispose controller ---
    fungsiControllers[index].dispose();

    // --- Hapus dari list ---
    setState(() {
      fungsiControllers.removeAt(index);
    });

    debugPrint("✅ DELETE SUCCESS [FUNGSI] → removed index: $index");

    _showDeleteSuccess(
      'Kolom fungsi baris ke ${index + 1} berisi "${summary}" dihapus',
    );
  }

  void _attachListener(int index) {
    fungsiControllers[index].addListener(() {
      final isLast = index == fungsiControllers.length - 1;
      final hasText = fungsiControllers[index].text.trim().isNotEmpty;

      // Jika mengetik di field terakhir → auto tambah
      if (isLast && hasText) {
        _addFungsiField();
      }

      setState(() {}); // refresh UI
    });
  }

  Widget _buildFungsiList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fungsiControllers.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildModernInput(
                  hint: "Fungsi ${String.fromCharCode(97 + i)}...",
                  controller: fungsiControllers[i],
                ),
              ),

              const SizedBox(width: 8),

              // tombol delete
              IconButton(
                icon: Icon(Icons.delete_outline, color: Color(0xFFE74C3C)),
                splashRadius: 20,
                //onPressed: () => _removeFungsi(i),
                onPressed: () async {
                  final confirm = await showConfirmDeleteDialog(context);
                  if (confirm) {
                    _removeFungsi(i);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // === BUTTON TAMBAH FUNGSI (model baru, kiri) ===
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addFungsiField,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Tambah Fungsi"),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ========================================
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
                "Hapus Fungsi?",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Text(
                "Apakah Anda yakin ingin menghapus baris fungsi ini?",
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

  // ----------------- Main build -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Form Perjanjian',
          style: AppTextStyle.bold16.copyWith(color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "PERJANJIAN KINERJA TAHUN 2025 WAKIL\nDIREKTUR PELAYANAN UOBK RSUD BANGIL\nKABUPATEN PASURUAN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Dalam rangka mewujudkan manajemen pemerintahan yang efektif, transparan dan akuntabel serta berorientasi pada hasil, kami yang bertanda tangan dibawah ini : ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // === INPUT NAMA PIHAK PERTAMA ===
                    _buildModernInput(
                      hint: "Nama Lengkap",
                      controller: namaPihakPertamaController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),

                    // === INPUT JABATAN PIHAK PERTAMA ===
                    _buildModernInput(
                      hint: "Jabatan",
                      controller: jabatanPihakPertamaController,
                      readOnly: true,
                    ),

                    const SizedBox(height: 8),
                    const Text("Selanjutnya disebut PIHAK PERTAMA."),
                    const SizedBox(height: 24),

                    // === INPUT NAMA PIHAK KEDUA ===
                    _buildModernInput(
                      hint: "Nama Lengkap",
                      controller: namaPihakKeduaController,
                    ),
                    const SizedBox(height: 8),

                    _dropdown(
                      selectedJabatanPihakKedua,
                      (v) => setState(() {
                        selectedJabatanPihakKedua = v;
                      }),
                    ),

                    const SizedBox(height: 12),
                    const Text("Selanjutnya disebut PIHAK KEDUA."),
                    const SizedBox(height: 24),

                    // === PARAGRAF PERJANJIAN KINERJA ===
                    const Text(
                      "Pihak pertama berjanji akan mewujudkan target kinerja yang seharusnya sesuai lampiran perjanjian ini, dalam rangka mencapai target kinerja jangka menengah seperti yang telah ditetapkan dalam dokumen perencanaan. Keberhasilan dan kegagalan pencapaian target kinerja tersebut menjadi tanggung jawab kami. ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 14),

                    // === PARAGRAF EVALUASI KINERJA ===
                    const Text(
                      "Pihak kedua akan melakukan evaluasi terhadap capaian kinerja dari perjanjian ini dan mengambil tindakan yang diperlukan dalam rangka pemberian penghargaan dan sanksi. ",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),

                    // === "INDIKATOR KINERJA INDIVIDU\nUOBK RSUD BANGIL TAHUN 2025" ===
                    const SizedBox(height: 40),
                    const Text(
                      "PERJANJIAN KINERJA TAHUN 2025 WAKIL\nDIREKTUR PELAYANAN UOBK RSUD BANGIL\nKABUPATEN PASURUAN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === INPUT MODERN (Jabatan, Tugas, Fungsi) ===
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Jabatan & Tugas",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // JABATAN
                    _buildModernInput(
                      // label: "Jabatan",
                      hint: "jabatan",
                      controller: jabatanPihakPertamaController,
                      readOnly: true,
                    ),

                    const SizedBox(height: 12),

                    // TUGAS
                    _buildModernInput(
                      // label: "Tugas",
                      hint: "Masukkan tugas...",
                      controller: tugasController,
                    ),

                    const SizedBox(height: 20),

                    // FUNGSI A – E
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Fungsi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // pemanggilan fungsi list
                    _buildFungsiList(),

                    const SizedBox(height: 20),

                    // === Card-based Table SASARAN & INDIKATOR ===
                    CardTable1Widget(
                      key: table1Key,
                      rows: sharedRows, // ✅ SATU object
                      onAddRow: addRow1,
                      onDeleteRow: deleteRow1,
                      onRowsChanged: () => setState(() {}), // 🔥 INI KUNCI
                    ),

                    const SizedBox(height: 30),

                    // === Card-based Table TARGET TRIWULAN ===
                    CardTable2Widget(
                      key: table2Key,
                      sharedRows: sharedRows, // ✅ NAMA BENAR
                      triwulanRows: triwulanRows, // ✅
                      onAddRow:
                          addRow1, // atau sharedRows.addRow (kalau sinkron)
                      onDeleteRow: deleteRow1, // Function(int)
                      onRowsChanged: () => setState(() {}), // 🔥 INI KUNCI
                    ),

                    const SizedBox(height: 30),

                    // === Card-based Table PROGRAM & ANGGARAN ===
                    CardTable3Widget(
                      key: table3Key,
                      rows: programRows,
                      onAddProgram: _addProgram,
                      onDeleteProgram: _deleteProgram,
                      onAddSub: _addSub,
                      onAddSubSub: _addSubSub,
                      onDeleteSub: _deleteSub,
                      onDeleteSubSub: _deleteSubSub,
                      onRowsChanged: () => setState(() {}), // 🔥 INI KUNCI
                    ),

                    const SizedBox(height: 30),

                    // === Card-based Table ANGGARAN DETAILED ===
                    CardTable4Widget(
                      key: table4Key,
                      rows: programRows, // 🔥 SAME LIST
                      onAddProgram: _addProgram,
                      onDeleteProgram: _deleteProgram,
                      onAddSub: _addSub,
                      onAddSubSub: _addSubSub,
                      onDeleteSub: _deleteSub,
                      onDeleteSubSub: _deleteSubSub,
                      onRowsChanged: () => setState(() {}), // 🔥 INI KUNCI
                    ),

                    const SizedBox(height: 30),

                    // === BUTTON SIMPAN / PREVIEW PDF ===
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          _onPreviewPdfPressed(
                            isEditMode: widget.mode == FormMode.edit,
                            perjanjianId: widget.mode == FormMode.edit
                                ? widget.perjanjianId
                                : null,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "PREVIEW",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // footer
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Text(
              '© 2025 RSUD Bangil – Sistem Laporan Kinerja',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

extension SafeController on TextEditingController {
  bool get isDisposed {
    try {
      // akses cursor position (akan error kalau sudah dispose)
      value;
      return false;
    } catch (_) {
      return true;
    }
  }
}

class SharedRowControllers {
  final List<List<TextEditingController>> _rows = [];

  List<List<TextEditingController>> get rows => _rows;

  int get length => _rows.length;

  /// ⬅️ INI YANG WAJIB
  List<TextEditingController> operator [](int index) => _rows[index];

  void addRow() {
    _rows.add(List.generate(4, (_) => TextEditingController()));
  }

  void deleteRow(int index) {
    if (_rows.length == 1) {
      for (final c in _rows.first) {
        c.clear();
      }
      return;
    }

    for (final c in _rows[index]) {
      c.dispose();
    }
    _rows.removeAt(index);
  }

  void dispose() {
    for (final row in _rows) {
      for (final c in row) {
        c.dispose();
      }
    }
  }
}

class ProgramAnggaranRow {
  final TextEditingController program;
  final TextEditingController anggaran;

  final TextEditingController tw1;
  final TextEditingController tw2;
  final TextEditingController tw3;
  final TextEditingController tw4;

  final TextEditingController keterangan;

  final List<ProgramAnggaranRow> children;

  ProgramAnggaranRow({
    TextEditingController? program,
    TextEditingController? anggaran,
    TextEditingController? tw1,
    TextEditingController? tw2,
    TextEditingController? tw3,
    TextEditingController? tw4,
    TextEditingController? keterangan,
    List<ProgramAnggaranRow>? children,
  }) : program = program ?? TextEditingController(),
       anggaran = anggaran ?? TextEditingController(),
       tw1 = tw1 ?? TextEditingController(),
       tw2 = tw2 ?? TextEditingController(),
       tw3 = tw3 ?? TextEditingController(),
       tw4 = tw4 ?? TextEditingController(),
       keterangan = keterangan ?? TextEditingController(),
       children = children ?? [];

  /// 🔥 WAJIB
  void dispose() {
    program.dispose();
    anggaran.dispose();
    tw1.dispose();
    tw2.dispose();
    tw3.dispose();
    tw4.dispose();
    keterangan.dispose();

    for (final c in children) {
      c.dispose();
    }
  }
}

class UserSignature {
  final Uint8List bytes;
  final String url;

  UserSignature({required this.bytes, required this.url});
}
