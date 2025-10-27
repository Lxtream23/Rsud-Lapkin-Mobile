import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsController {
  final String baseUrl =
      "https://example.com/api"; // 🔹 Ganti dengan URL API kamu

  // 🔹 Ganti Password
  Future<bool> changePassword({
    required String oldPassword,
    required String confirmOldPassword,
    required String newPassword,
    required String confirmNewPassword,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/change-password");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "old_password": oldPassword,
        "confirm_old_password": confirmOldPassword,
        "new_password": newPassword,
        "confirm_new_password": confirmNewPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["success"] == true;
    } else {
      return false;
    }
  }

  // 🔹 Ganti Email
  Future<bool> changeEmail({
    required String oldEmail,
    required String newEmail,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/change-email");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "old_email": oldEmail,
        "new_email": newEmail,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["success"] == true;
    } else {
      return false;
    }
  }
}
