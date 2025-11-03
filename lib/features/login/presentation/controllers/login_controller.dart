import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fungsi login user ke Supabase
  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result == null) {
        // ✅ Login berhasil
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        // ⚠️ Login gagal
        _errorMessage = result;
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Logout Supabase
  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
