import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  /// 🔹 REGISTER USER (otomatis trigger Supabase handle_new_user)
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
      // 1️⃣ Buat akun di Supabase Auth dengan metadata tambahan
      final AuthResponse response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'id_pegawai': idPegawai,
          'nama_lengkap': namaLengkap,
          'nip': nip,
          'jabatan': jabatan,
          'pangkat': pangkat,
        },
      );

      final user = response.user;
      if (user == null) {
        return 'Gagal membuat akun. Silakan coba lagi.';
      }

      // 2️⃣ Tunggu 1–2 detik supaya trigger Supabase berjalan
      await Future.delayed(const Duration(seconds: 2));

      // 3️⃣ Logout otomatis agar user verifikasi email terlebih dahulu
      await supabase.auth.signOut();

      // 4️⃣ Berhasil
      return 'Akun berhasil dibuat. Silakan cek email untuk verifikasi.';
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains('already registered') ||
          msg.contains('user already exists')) {
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau login.';
      } else if (msg.contains('password')) {
        return 'Kata sandi terlalu lemah. Gunakan kombinasi huruf dan angka.';
      } else {
        return 'Pendaftaran gagal: ${e.message}';
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ [AuthService.register] $e\n$st');
      }
      return 'Terjadi kesalahan koneksi. Pastikan jaringan stabil dan coba lagi.';
    }
  }

  /// 🔹 LOGIN USER
  Future<String?> login(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      // 🔄 Pastikan session terbaru di-refresh
      await supabase.auth.refreshSession();

      return null; // success
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains('invalid login credentials')) {
        return 'Email atau kata sandi salah.';
      } else if (msg.contains('email not confirmed')) {
        return 'Akun belum terverifikasi. Silakan cek email Anda.';
      } else {
        return 'Gagal login: ${e.message}';
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ [AuthService.login] $e\n$st');
      }
      return 'Tidak dapat terhubung ke server. Coba lagi nanti.';
    }
  }

  /// 🔹 LOGOUT
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();

      // 🧹 Pastikan session benar-benar bersih (kadang perlu di web)
      await supabase.removeAllChannels();
    } catch (e) {
      if (kDebugMode) print('⚠️ [AuthService.logout] $e');
    }
  }

  /// 🔹 CEK STATUS LOGIN
  bool get isLoggedIn => supabase.auth.currentSession != null;

  /// 🔹 Dapatkan user saat ini
  User? get currentUser => supabase.auth.currentUser;
}
