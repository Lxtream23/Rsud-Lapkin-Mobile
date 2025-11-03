import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  /// Fungsi register ke Supabase Auth + simpan profil ke tabel `profiles`
  Future<String?> register({
    required String idPegawai,
    required String namaLengkap,
    required String email,
    required String nip,
    required String jabatan,
    required String pangkat,
    required String password,
  }) async {
    try {
      // 1️⃣ Buat akun di Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        return 'Gagal membuat akun. Coba lagi nanti.';
      }

      // 2️⃣ Cek apakah email sudah diverifikasi
      if (user.emailConfirmedAt == null) {
        // Belum verifikasi → kasih tahu user untuk cek email
        return "Akun berhasil dibuat! Silakan cek email Anda untuk verifikasi sebelum login.";
      }

      // 3️⃣ Jika user sudah terverifikasi → insert ke tabel profiles
      await supabase.auth.refreshSession();

      await supabase.from('profiles').insert({
        'id': user.id,
        'id_pegawai': idPegawai,
        'nama_lengkap': namaLengkap,
        'email': email,
        'nip': nip,
        'jabatan': jabatan,
        'pangkat': pangkat,
      });

      return null; // sukses
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan saat registrasi: $e';
    }
  }

  /// Fungsi login ke Supabase Auth
  Future<String?> login(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message; // kirim pesan error ke UI
    } catch (e) {
      return e.toString();
    }
  }

  /// Fungsi logout dari Supabase Auth
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
