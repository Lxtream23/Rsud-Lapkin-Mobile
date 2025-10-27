import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsController {
  final String baseUrl =
      'https://api.rsudbangil.go.id'; // ganti sesuai server kamu

  Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String confirmOldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'old_password': oldPassword,
          'confirm_old_password': confirmOldPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmNewPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeEmail({
    required String userId,
    required String oldEmail,
    required String newEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/change-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'old_email': oldEmail,
          'new_email': newEmail,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
