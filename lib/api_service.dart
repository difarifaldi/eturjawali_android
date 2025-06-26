import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'utils.dart'; // agar bisa pakai sha1Hash
import 'models/live_person.dart';

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

  static String? _authToken;

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
    // print('Status: ${response.statusCode}');
    // print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('success') && data['success'] != null) {
        final user = data['success'];
        _authToken = user['token'];
        print(user);
        return {
          'userId': int.parse(user['id_pengguna']),
          'username': user['login'],
          'unitId': int.parse(user['id_kesatuan']),
          'nama': user['nama'],
        };
      } else {
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // ambil daftar sprint (surat perintah)
  static Future<List<dynamic>> fetchSprint(int userId) async {
    final token = generateJWT();
    final url = Uri.parse('${_baseUrl}api/my_sprin/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    //print('Status Surat Perintah: ${response.statusCode}');
    // print('Body Surat Perintah: ${response.body}');
    // print('URL: $url');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception("Response kosong dari server");
      }

      final data = jsonDecode(response.body);

      if (data['data'] != null) {
        return data['data'];
      } else {
        return [];
      }
    } else {
      // Tambahan log detail kalau server error
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body.isEmpty ? "No content Surat Perintah" : response.body}',
      );
    }
  }

  // ambil berita terbaru
  static Future<List<dynamic>> fetchBerita(int unitId) async {
    final token = generateJWT();
    //final token = _authToken;

    final url = Uri.parse('${_baseUrl}api/berita/$unitId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    //print('Status Berita: ${response.statusCode}');
    //print('Body Berita: ${response.body}');
    //print('URL: $url');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception("Response kosong dari server");
      }

      final data = jsonDecode(response.body);

      if (data['data'] != null) {
        return data['data'];
      } else {
        return [];
      }
    } else {
      // Tambahan log detail kalau server error
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body.isEmpty ? "No content Berita" : response.body}',
      );
    }
  }

  static Future<List<LivePerson>> fetchLivePersonel() async {
    final token = generateJWT();
    final url = Uri.parse('${_baseUrl}api/live');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Status Personel: ${response.statusCode}');
    print('Body Personel: ${response.body}');
    print('URL: $url');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] != null) {
        return List<LivePerson>.from(
          data['success'].map((item) => LivePerson.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil personel: ${response.statusCode}');
    }
  }

  // ambil kegiatan terakhir
  // static Future<List<dynamic>> fetchKegiatanTerakhir(int userId) async {
  //   final token = generateJWT();
  //   //final token = _authToken;

  //   final url = Uri.parse('${_baseUrl}api/latest/$userId');

  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   print('Status Kegiatan Terakhir: ${response.statusCode}');
  //   print('Body Kegiatan Terakhir: ${response.body}');
  //   print('URL: $url');

  //   if (response.statusCode == 200) {
  //     if (response.body.isEmpty) {
  //       throw Exception("Response kosong dari server");
  //     }

  //     final data = jsonDecode(response.body);

  //     if (data['data'] != null) {
  //       return data['data'];
  //     } else {
  //       throw Exception(data['message'] ?? 'Data tidak tersedia');
  //     }
  //   } else {
  //     // Tambahan log detail kalau server error
  //     throw Exception(
  //       'HTTP ${response.statusCode}: ${response.body.isEmpty ? "No content" : response.body}',
  //     );
  //   }
  // }
}
