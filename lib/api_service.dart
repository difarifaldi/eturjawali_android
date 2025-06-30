import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'utils.dart'; // agar bisa pakai sha1Hash
import 'models/live_person.dart';
import 'models/statistik.dart';
import 'models/berita.dart';
import 'models/sprint.dart';
import 'dart:convert';

class ApiService {
  static const String _baseUrl =
      'https://eturjawali.korlantas.polri.go.id/api/v2/';

  static String generateJWT() {
    final jwt = JWT({
      'sub': 'eturjawali',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });

    final key = SecretKey('12345678901234567890123456789012');

    return jwt.sign(key, algorithm: JWTAlgorithm.HS256);
  }

  static String? _authToken;

  //Login
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
          'kesatuan_nama': user['kesatuan_nama'],
          'email': user['email'],
          'no_mobile': user['no_mobile'],
          'photo': user['photo'],
        };
      } else {
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // ambil daftar sprint (surat perintah)
  static Future<List<Sprint>> fetchSprint(int userId) async {
    final token = generateJWT();
    final url = Uri.parse('${_baseUrl}api/my_sprin/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        return List<Sprint>.from(
          data['data'].map((item) => Sprint.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil sprint: ${response.statusCode}');
    }
  }

  // ambil berita terbaru
  static Future<List<Berita>> fetchBerita(int unitId) async {
    final token = generateJWT();
    final url = Uri.parse('${_baseUrl}api/berita/$unitId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        return List<Berita>.from(
          data['data'].map((item) => Berita.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil berita: ${response.statusCode}');
    }
  }

  //Ambil Live Personel
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
    // print('Status Personel: ${response.statusCode}');
    // print('Body Personel: ${response.body}');
    // print('URL: $url');

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

  //Ambil Statistik
  static Future<Statistik> fetchStatistik(int userId) async {
    final token = generateJWT();
    final url = Uri.parse('${_baseUrl}api/statistik/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Status Statistik: ${response.statusCode}');
    print('Body Statistik: ${response.body}');
    print('URL: $url');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final success = data['success'];

      if (success != null && success is Map<String, dynamic>) {
        return Statistik.fromJson(success);
      } else {
        throw Exception('Format data statistik tidak valid');
      }
    } else {
      throw Exception('Gagal mengambil statistik: ${response.statusCode}');
    }
  }

  //Update Profile
  static Future<bool> updateProfile({
    required int userId,
    required String email,
    required String noMobile,
    required String currentPassword,
    String? newPassword,
  }) async {
    final token = generateJWT();
    final data = {
      'email': email,
      'no_mobile': noMobile,
      'current_password': sha1Hash(currentPassword),
    };

    if (newPassword != null && newPassword.isNotEmpty) {
      data['password'] = sha1Hash(newPassword);
    }

    final url = Uri.parse('${_baseUrl}api/save_me/$userId');
    print('Token dipakai: $token');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: data, // langsung pakai Map<String, String>
      );

      print('Status Update: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] != null) {
          return true;
        } else {
          throw Exception(body['message'] ?? 'Update gagal');
        }
      } else {
        throw Exception('Gagal update: ${response.body}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
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
