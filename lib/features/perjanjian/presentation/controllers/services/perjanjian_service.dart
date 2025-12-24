import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PerjanjianService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ======================================================
  // 🔹 SIMPAN BARU (INSERT)
  // ======================================================
  Future<String> savePerjanjian({
    required Map<String, dynamic> data,
    required Uint8List pdfBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final userId = user.id;
    final perjanjianId = const Uuid().v4();

    // 1️⃣ Upload PDF
    final pdfPath = '$userId/$perjanjianId.pdf';

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

    // 2️⃣ Insert database
    await _supabase.from('perjanjian_kinerja').insert({
      'id': perjanjianId,
      'user_id': userId,

      'nama_pihak_pertama': data['namaPihakPertama'],
      'jabatan_pihak_pertama': data['jabatanPihakPertama'],
      'pangkat_pihak_pertama': data['pangkatPihak1'],
      'nip_pihak_pertama': data['nipPihak1'],

      'nama_pihak_kedua': data['namaPihakKedua'],
      'jabatan_pihak_kedua': data['jabatanPihakKedua'],
      'pangkat_pihak_kedua': data['pangkatPihak2'],

      'tugas_detail': data['tugasDetail'],
      'fungsi_list': data['fungsiList'],

      'tabel1': data['table1'],
      'tabel2': data['table2'],
      'tabel3': data['table3'],
      'tabel4': data['table4'],

      'pdf_path': pdfPath,

      'status': 'Proses',
      'version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    return perjanjianId;
  }

  // ======================================================
  // 🔹 UPDATE (EDIT PERJANJIAN)
  // ======================================================
  Future<void> updatePerjanjian({
    required String perjanjianId,
    required Map<String, dynamic> data,
    required Uint8List pdfBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final userId = user.id;

    // 1️⃣ Ambil version lama
    final old = await _supabase
        .from('perjanjian_kinerja')
        .select('version')
        .eq('id', perjanjianId)
        .single();

    final int newVersion = (old['version'] ?? 1) + 1;

    // 2️⃣ Upload PDF (overwrite)
    final pdfPath = '$userId/$perjanjianId.pdf';

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

    // 3️⃣ Update database
    await _supabase
        .from('perjanjian_kinerja')
        .update({
          'nama_pihak_pertama': data['namaPihakPertama'],
          'jabatan_pihak_pertama': data['jabatanPihakPertama'],
          'pangkat_pihak_pertama': data['pangkatPihak1'],
          'nip_pihak_pertama': data['nipPihak1'],

          'nama_pihak_kedua': data['namaPihakKedua'],
          'jabatan_pihak_kedua': data['jabatanPihakKedua'],
          'pangkat_pihak_kedua': data['pangkatPihak2'],

          'tugas_detail': data['tugasDetail'],
          'fungsi_list': data['fungsiList'],

          'tabel1': data['table1'],
          'tabel2': data['table2'],
          'tabel3': data['table3'],
          'tabel4': data['table4'],

          'pdf_path': pdfPath,

          // 🔥 OTOMATIS
          'status': 'Proses',
          'version': newVersion,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', perjanjianId);
  }
}
