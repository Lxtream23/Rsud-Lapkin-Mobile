import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authService.login(email, password);

      if (result == null) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout(context);
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
