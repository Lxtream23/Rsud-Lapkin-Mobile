import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class RegisterController with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 🔹 REGISTER USER BARU
  Future<String?> register({
    required String idPegawai,
    required String namaLengkap,
    required String email,
    required String nip,
    required String jabatan,
    required String pangkat,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        idPegawai: idPegawai,
        namaLengkap: namaLengkap,
        email: email,
        nip: nip,
        jabatan: jabatan,
        pangkat: pangkat,
        password: password,
      );

      if (result == 'success') {
        // ✅ Register sukses — Supabase trigger akan otomatis isi tabel profiles
        return 'Akun berhasil dibuat. Silakan cek email untuk verifikasi.';
      } else {
        // ❌ Error dari AuthService
        return result ?? 'Pendaftaran gagal. Coba lagi nanti.';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
