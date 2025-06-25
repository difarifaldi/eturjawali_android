import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'utils.dart'; // agar bisa pakai sha1Hash

class ApiService {
  static const String _baseUrl =
      'https://eturjawali.korlantas.polri.go.id/api/v2/';

  static String generateJWT() {
    final jwt = JWT({
      'sub': 'eturjawali', // sementara pakai ini, nanti bisa kita sesuaikan
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });

    final key = SecretKey('12345678901234567890123456789012');

    return jwt.sign(key, algorithm: JWTAlgorithm.HS256);
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final token = generateJWT();

    final url = Uri.parse('${_baseUrl}api/auth');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'login': username,
      'password': sha1Hash(password),
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('success') && data['success'] != null) {
        return data['success']; // sukses login, data user dikembalikan
      } else {
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
