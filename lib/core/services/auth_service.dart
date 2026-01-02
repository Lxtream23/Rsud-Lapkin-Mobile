import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rsud_lapkin_mobile/core/enums/user_role.dart';
import 'package:rsud_lapkin_mobile/core/enums/user_role_ext.dart';
import 'auth_wrapper.dart';

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
          'role': 'user', // 👈 DEFAULT ROLE
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
  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      await supabase.removeAllChannels();
      await supabase.auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [AuthService.logout] Gagal logout: $e');
      }
    } finally {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (route) => false,
        );
      }
    }
  }

  /// 🔹 CEK STATUS LOGIN
  bool get isLoggedIn => supabase.auth.currentSession != null;

  /// 🔹 Dapatkan user saat ini
  User? get currentUser => supabase.auth.currentUser;

  /// 🔹 AMBIL ROLE USER DARI TABLE PROFILES (RECOMMENDED)
  Future<UserRole> fetchCurrentRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return UserRole.unknown;

    try {
      final data = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return data?['role']?.toString().toUserRole() ?? UserRole.unknown;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthService.fetchCurrentRole] $e');
      }
      return UserRole.unknown;
    }
  }

  /// 🔹 AMBIL ROLE USER
  UserRole get currentRole {
    final user = supabase.auth.currentUser;
    if (user == null) return UserRole.unknown;

    final roleRaw = user.userMetadata?['role'];

    return roleRaw?.toString().toUserRole() ?? UserRole.unknown;
  }
}
