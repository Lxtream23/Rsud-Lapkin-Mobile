import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔹 LOGIN USER ke Supabase
  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authService.login(email, password);

      if (result == null) {
        // ✅ Login berhasil
        _setLoading(false);
        return true;
      } else {
        // ⚠️ Login gagal, tampilkan pesan error
        _errorMessage = result;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// 🔹 LOGOUT USER dari Supabase
  Future<void> logout() async {
    try {
      await _authService.logout();
      // 🔸 Hapus state setelah logout
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Gagal logout: $e');
    }
  }

  /// 🔹 Reset error (berguna saat pindah halaman)
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
