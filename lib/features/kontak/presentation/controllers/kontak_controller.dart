import 'dart:convert';
import 'package:http/http.dart' as http;

class KontakController {
  // 🔹 Ganti URL ini sesuai endpoint API kamu
  final String baseUrl = "https://example.com/api";

  /// 🔹 Kirim pesan kontak ke backend
  Future<bool> sendContactMessage({
    required String nama,
    required String email,
    required String pesan,
  }) async {
    final url = Uri.parse('$baseUrl/contact');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"nama": nama, "email": email, "pesan": pesan}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Asumsikan backend mengirimkan format:
        // { "success": true, "message": "Pesan berhasil dikirim" }
        return data["success"] == true;
      } else {
        print("❌ Error response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Gagal mengirim pesan: $e");
      return false;
    }
  }

  /// 🔹 Validasi input sebelum dikirim
  Map<String, String?> validateFields({
    required String nama,
    required String email,
    required String pesan,
  }) {
    final errors = <String, String?>{};

    if (nama.isEmpty) {
      errors["nama"] = "Nama tidak boleh kosong";
    }
    if (email.isEmpty) {
      errors["email"] = "Email tidak boleh kosong";
    } else if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]+').hasMatch(email)) {
      errors["email"] = "Format email tidak valid";
    }
    if (pesan.isEmpty) {
      errors["pesan"] = "Pesan tidak boleh kosong";
    }

    return errors;
  }
}
