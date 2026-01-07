import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
final String baseUrl = "http://10.60.14.106:8000/api"; 
  //yang mau pake hp pake ini aja yang atas ditutup
   //final String baseUrl = "http://10.0.2.2:8000/api";


  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
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
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
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

  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse("$baseUrl/profile");

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String username,
    required String email,
    String? password,
  }) async {
    final url = Uri.parse("$baseUrl/profile");

    final body = {"username": username, "email": email};

    if (password != null && password.isNotEmpty) {
      body["password"] = password;
    }

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("UPDATE PROFILE STATUS: ${response.statusCode}");
    print("UPDATE PROFILE BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal update profile');
    }

    return data;
  }

  Future<Map<String, dynamic>> updatePhoto({
    required String token,
    required String filePath,
  }) async {
    final url = Uri.parse("$baseUrl/profile/photo");

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    request.files.add(await http.MultipartFile.fromPath('photo', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  Future<bool> saveHistory(String token, String gestureName, double accuracy) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'gesture_name': gestureName,
          'accuracy': accuracy,
          'source': 'camera',
        }),
      );

      // 201 Created berarti berhasil disimpan
      if (response.statusCode == 201) {
        print("History saved successfully");
        return true;
      } else {
        print("Failed to save history: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saving history: $e");
      return false;
    }
  }
}

