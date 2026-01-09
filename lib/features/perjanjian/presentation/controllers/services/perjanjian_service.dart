import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:rsud_lapkin_mobile/features/perjanjian/presentation/pdf/perjanjian_pdf_generator.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PerjanjianService {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<List<String>> _castTable(dynamic raw) {
    if (raw == null) return [];

    final decoded = raw is String ? jsonDecode(raw) : raw;

    return (decoded as List)
        .map<List<String>>(
          (row) => (row as List)
              .map<String>((cell) => cell?.toString() ?? '')
              .toList(),
        )
        .toList();
  }

  List<String> _castStringList(dynamic raw) {
    if (raw == null) return [];

    final decoded = raw is String ? jsonDecode(raw) : raw;

    return (decoded as List).map<String>((e) => e?.toString() ?? '').toList();
  }

  List<List<String>> castTableMatrix(dynamic raw) {
    if (raw == null) return [];

    final decoded = raw is String ? jsonDecode(raw) : raw;

    return (decoded as List)
        .map<List<String>>(
          (row) => (row as List)
              .map<String>((cell) => cell?.toString() ?? '')
              .toList(),
        )
        .toList();
  }

  List<Map<String, dynamic>> castTableTree(dynamic raw) {
    if (raw == null) return [];

    final decoded = raw is String ? jsonDecode(raw) : raw;

    return (decoded as List)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  List<String> castStringList(dynamic raw) {
    if (raw == null) return [];

    final decoded = raw is String ? jsonDecode(raw) : raw;

    return (decoded as List).map<String>((e) => e?.toString() ?? '').toList();
  }

  Future<Uint8List> downloadSignature(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Gagal download tanda tangan pimpinan');
    }

    return response.bodyBytes;
  }

  // ======================================================
  // 🔹 SIMPAN BARU (USER BIASA - DRAFT)
  // ======================================================
  Future<String> createPerjanjian({
    required Map<String, dynamic> data,
    required Uint8List pdfBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    final userId = user.id;
    final id = const Uuid().v4();
    final pdfPath = '$userId/$id.pdf';

    // 1️⃣ Upload PDF
    await _supabase.storage
        .from('perjanjian-pdf')
        .uploadBinary(
          pdfPath,
          pdfBytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: false,
          ),
        );

    // 2️⃣ Insert DB (DATA PIMPINAN BOLEH NULL)
    await _supabase.from('perjanjian_kinerja').insert({
      'id': id,
      'user_id': userId,

      // ===== PIHAK 1 =====
      'nama_pihak_pertama': data['namaPihakPertama'],
      'jabatan_pihak_pertama': data['jabatanPihakPertama'],
      'pangkat_pihak_pertama': data['pangkatPihak1'],
      'nip_pihak_pertama': data['nipPihak1'],
      'ttd_pihak_pertama_url': data['ttdPihak1'],

      // ===== PIHAK 2 =====
      'nama_pihak_kedua': data['namaPihakKedua'],
      'jabatan_pihak_kedua': data['jabatanPihakKedua'],
      'pangkat_pihak_kedua': null, // 🔥 BELUM DISETUJUI
      'nip_pihak_kedua': null,
      'ttd_pihak_kedua_url': null, // 🔥 BELUM DISETUJUI
      // ===== ISI =====
      'tugas_detail': data['tugasDetail'],
      'fungsi_list': data['fungsiList'],
      'tabel1': data['table1'],
      'tabel2': data['table2'],
      'tabel3': data['table3'],
      'tabel4': data['table4'],

      // ===== META =====
      'pdf_path': pdfPath,
      'status': 'Proses',
      'version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    return id;
  }

  // ======================================================
  // 🔹 UPDATE (EDIT DRAFT OLEH USER)
  // ======================================================
  Future<void> updatePerjanjian({
    required String perjanjianId,
    required Map<String, dynamic> data,
    required Uint8List pdfBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    final userId = user.id;

    // 1️⃣ Ambil version lama
    final old = await _supabase
        .from('perjanjian_kinerja')
        .select('version')
        .eq('id', perjanjianId)
        .single();

    final int newVersion = (old['version'] ?? 1) + 1;
    final pdfPath = '$userId/$perjanjianId.pdf';

    // 2️⃣ Overwrite PDF
    await _supabase.storage
        .from('perjanjian-pdf')
        .uploadBinary(
          pdfPath,
          pdfBytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );

    // 3️⃣ Update DB (TETAP STATUS PROSES)
    await _supabase
        .from('perjanjian_kinerja')
        .update({
          'nama_pihak_pertama': data['namaPihakPertama'],
          'jabatan_pihak_pertama': data['jabatanPihakPertama'],
          'pangkat_pihak_pertama': data['pangkatPihak1'],
          'nip_pihak_pertama': data['nipPihak1'],
          'ttd_pihak_pertama_url': data['ttdPihak1'],

          'nama_pihak_kedua': data['namaPihakKedua'],
          'jabatan_pihak_kedua': data['jabatanPihakKedua'],
          'pangkat_pihak_kedua': null, // 🔥 BELUM DISETUJUI
          'nip_pihak_kedua': null,
          'ttd_pihak_kedua_url': null, // 🔥 BELUM DISETUJUI

          'tugas_detail': data['tugasDetail'],
          'fungsi_list': data['fungsiList'],
          'tabel1': data['table1'],
          'tabel2': data['table2'],
          'tabel3': data['table3'],
          'tabel4': data['table4'],

          'pdf_path': pdfPath,
          'status': 'Proses',
          'version': newVersion,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', perjanjianId);
  }
  // ======================================================
  // 🔵 APPROVE PERJANJIAN (PIMPINAN)
  // ======================================================

  Future<void> approvePerjanjian({
    required String perjanjianId,
    required Map<String, dynamic> pimpinanProfile,
  }) async {
    final supabase = Supabase.instance.client;

    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    /// ===== VALIDASI PROFIL PIMPINAN =====
    final String nip = pimpinanProfile['nip'] ?? '';
    final String pangkat = pimpinanProfile['pangkat'] ?? '';
    final String ttdPimpinanUrl = pimpinanProfile['ttd'] ?? '';
    final String namaPimpinan = pimpinanProfile['nama_lengkap'] ?? '';
    final String jabatanPimpinan = pimpinanProfile['jabatan'] ?? 'Direktur';

    if (nip.isEmpty || pangkat.isEmpty || ttdPimpinanUrl.isEmpty) {
      throw Exception('Data pimpinan belum lengkap');
    }

    /// ===== AMBIL DATA PERJANJIAN =====
    final data = await supabase
        .from('perjanjian_kinerja')
        .select()
        .eq('id', perjanjianId)
        .single();

    final String? ttdUserUrl = data['ttd_pihak_pertama_url'];
    if (ttdUserUrl == null || ttdUserUrl.isEmpty) {
      throw Exception('TTD pihak pertama tidak ditemukan');
    }

    /// ===== DOWNLOAD TTD =====
    final Uint8List signatureLeftBytes = await downloadSignature(
      ttdPimpinanUrl,
    );

    final Uint8List signatureRightBytes = await downloadSignature(ttdUserUrl);

    /// 🔥 VALIDASI HASIL DOWNLOAD
    if (signatureLeftBytes.isEmpty) {
      throw Exception('TTD pimpinan gagal diunduh');
    }
    if (signatureRightBytes.isEmpty) {
      throw Exception('TTD pihak pertama gagal diunduh');
    }

    debugPrint('TTD PIMPINAN SIZE : ${signatureLeftBytes.length}');
    debugPrint('TTD USER SIZE     : ${signatureRightBytes.length}');

    /// ===== CAST DATA =====
    final tabel1 = castTableMatrix(data['tabel1']);
    final tabel2 = castTableMatrix(data['tabel2']);
    final tabel3 = castTableTree(data['tabel3']);
    final tabel4 = castTableTree(data['tabel4']);
    final fungsiList = castStringList(data['fungsi_list']);

    /// ===== GENERATE PDF (APPROVED) =====
    final Uint8List approvedPdf = await generatePerjanjianPdf(
      // ===== PIHAK PERTAMA (USER) =====
      namaPihak1: data['nama_pihak_pertama'],
      jabatanPihak1: data['jabatan_pihak_pertama'],
      pangkatPihak1: data['pangkat_pihak_pertama'],
      nipPihak1: data['nip_pihak_pertama'],

      // ===== PIHAK KEDUA (PIMPINAN) 🔥 =====
      namaPihak2: namaPimpinan,
      jabatanPihak2: jabatanPimpinan,
      pangkatPihak2: pangkat,
      nipPihak2: nip,

      // ===== TTD =====
      signatureLeftBytes: signatureLeftBytes, // pimpinan
      signatureRightBytes: signatureRightBytes, // user
      // ===== ISI =====
      tabel1: tabel1,
      tabel2: tabel2,
      tabel3: tabel3,
      tabel4: tabel4,
      tugasDetail: data['tugas_detail'],
      fungsiList: fungsiList,

      isApproved: true,
    );

    /// ===== OVERWRITE PDF =====
    await supabase.storage
        .from('perjanjian-pdf')
        .uploadBinary(
          data['pdf_path'],
          approvedPdf,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );

    /// ===== UPDATE DB =====
    await supabase
        .from('perjanjian_kinerja')
        .update({
          'status': 'Disetujui',
          'approved_at': DateTime.now().toIso8601String(),
          'approved_by': user.id,

          // 🔥 SIMPAN DATA PIMPINAN RESMI
          'nama_pihak_kedua': namaPimpinan,
          'jabatan_pihak_kedua': jabatanPimpinan,
          'pangkat_pihak_kedua': pangkat,
          'nip_pihak_kedua': nip,
          'ttd_pihak_kedua_url': ttdPimpinanUrl,
        })
        .eq('id', perjanjianId);
  }

  // ======================================================
  // 🔴 REJECT PERJANJIAN (PIMPINAN)
  // ======================================================
  Future<void> rejectPerjanjian({
    required String perjanjianId,
    required String alasan,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    if (alasan.trim().isEmpty) {
      throw Exception('Alasan penolakan wajib diisi');
    }

    try {
      // ✅ Ambil nama resmi dari profile
      final profile = await supabase
          .from('profile')
          .select('nama_lengkap')
          .eq('id', user.id)
          .single();

      final namaPimpinan = profile['nama_lengkap'] ?? 'Pimpinan';

      await supabase
          .from('perjanjian_kinerja')
          .update({
            'status': 'Ditolak',
            'rejection_reason': alasan.trim(),

            // 🔒 AUDIT TRAIL (WAJIB)
            'rejected_by': user.id,
            'rejected_by_name': namaPimpinan,
            'rejected_at': DateTime.now().toIso8601String(),

            // reset notifikasi
            'rejection_read_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', perjanjianId);
    } catch (e) {
      debugPrint('REJECT PERJANJIAN ERROR: $e');
      rethrow;
    }
  }
}

// import 'dart:typed_data';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';
// import 'package:flutter/material.dart';

// class PerjanjianService {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   // ======================================================
//   // 🔹 SIMPAN BARU (INSERT)
//   // ======================================================
//   Future<String> createPerjanjian({
//     required Map<String, dynamic> data,
//     required Uint8List pdfBytes,
//   }) async {
//     final user = _supabase.auth.currentUser;
//     if (user == null) throw Exception('User belum login');

//     final userId = user.id;
//     final id = const Uuid().v4();
//     final pdfPath = '$userId/$id.pdf';

//     // 1️⃣ Upload PDF
//     await _supabase.storage
//         .from('perjanjian-pdf')
//         .uploadBinary(
//           pdfPath,
//           pdfBytes,
//           fileOptions: const FileOptions(
//             contentType: 'application/pdf',
//             upsert: false, // CREATE = tidak boleh overwrite
//           ),
//         );

//     // 2️⃣ Insert DB
//     await _supabase.from('perjanjian_kinerja').insert({
//       'id': id,
//       'user_id': userId,

//       'nama_pihak_pertama': data['namaPihakPertama'],
//       'jabatan_pihak_pertama': data['jabatanPihakPertama'],
//       'pangkat_pihak_pertama': data['pangkatPihak1'],
//       'nip_pihak_pertama': data['nipPihak1'],

//       'nama_pihak_kedua': data['namaPihakKedua'],
//       'jabatan_pihak_kedua': data['jabatanPihakKedua'],
//       'pangkat_pihak_kedua': data['pangkatPihak2'],

//       'tugas_detail': data['tugasDetail'],
//       'fungsi_list': data['fungsiList'],

//       'tabel1': data['table1'],
//       'tabel2': data['table2'],
//       'tabel3': data['table3'],
//       'tabel4': data['table4'],

//       'pdf_path': pdfPath,
//       'status': 'Proses',
//       'version': 1,
//       'created_at': DateTime.now().toIso8601String(),
//       'updated_at': DateTime.now().toIso8601String(),
//     });

//     return id;
//   }

//   // ======================================================
//   // 🔹 UPDATE (EDIT PERJANJIAN)
//   // ======================================================
//   Future<void> updatePerjanjian({
//     required String perjanjianId,
//     required Map<String, dynamic> data,
//     required Uint8List pdfBytes,
//   }) async {
//     final user = _supabase.auth.currentUser;
//     debugPrint('UPDATE PDF PATH: $perjanjianId');
//     if (user == null) throw Exception('User belum login');

//     final userId = user.id;

//     // 1️⃣ Ambil version lama
//     final old = await _supabase
//         .from('perjanjian_kinerja')
//         .select('version')
//         .eq('id', perjanjianId)
//         .single();

//     final int newVersion = (old['version'] ?? 1) + 1;
//     final pdfPath = '$userId/$perjanjianId.pdf';
//     debugPrint('OVERWRITE PDF PATH: $pdfPath');

//     // 2️⃣ Overwrite PDF lama
//     try {
//       await _supabase.storage
//           .from('perjanjian-pdf')
//           .uploadBinary(
//             pdfPath,
//             pdfBytes,
//             fileOptions: const FileOptions(
//               contentType: 'application/pdf',
//               upsert: true, // overwrite
//             ),
//           );

//       // 3️⃣ Update DB
//       await _supabase
//           .from('perjanjian_kinerja')
//           .update({
//             'nama_pihak_pertama': data['namaPihakPertama'],
//             'jabatan_pihak_pertama': data['jabatanPihakPertama'],
//             'pangkat_pihak_pertama': data['pangkatPihak1'],
//             'nip_pihak_pertama': data['nipPihak1'],

//             'nama_pihak_kedua': data['namaPihakKedua'],
//             'jabatan_pihak_kedua': data['jabatanPihakKedua'],
//             'pangkat_pihak_kedua': data['pangkatPihak2'],

//             'tugas_detail': data['tugasDetail'],
//             'fungsi_list': data['fungsiList'],

//             'tabel1': data['table1'],
//             'tabel2': data['table2'],
//             'tabel3': data['table3'],
//             'tabel4': data['table4'],

//             'pdf_path': pdfPath,
//             'status': 'Proses',
//             'version': newVersion,
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('id', perjanjianId);
//     } catch (e) {
//       debugPrint('Update gagal: $e');
//       rethrow;
//     }
//   }
// }
