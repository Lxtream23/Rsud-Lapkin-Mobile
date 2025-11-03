import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class RegisterController with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

    final result = await _authService.register(
      idPegawai: idPegawai,
      namaLengkap: namaLengkap,
      email: email,
      nip: nip,
      jabatan: jabatan,
      pangkat: pangkat,
      password: password,
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
