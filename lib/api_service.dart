import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost/panah_presensi_api/api.php";

  // Fungsi Registrasi
  static Future<Map<String, dynamic>> registerUser(
      String username, String password, String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl?action=register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"success": false, "message": "Failed to connect to API"};
    }
  }

  // Fungsi Login
  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl?action=login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"success": false, "message": "Failed to connect to API"};
    }
  }
}
