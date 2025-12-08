import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json",
      "Accept": "application/json",},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String userType,
  ) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json",
      "Accept": "application/json",},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "user_type": userType,
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    return jsonDecode(response.body);
  }
}
