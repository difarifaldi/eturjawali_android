import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'utils.dart'; // agar bisa pakai sha1Hash
import 'models/live_person.dart';
import 'models/statistik.dart';
import 'models/berita.dart';
import 'models/sprint.dart';
import 'models/giat.dart';
import 'models/checkin_request.dart';

class ApiService {
  static const String _baseUrl =
      'https://eturjawali.korlantas.polri.go.id/api/v2/';

  // JWT Login
  static String generateJWTLogin() {
    final jwt = JWT({
      'sub': 'eturjawali',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });

    final key = SecretKey('12345678901234567890123456789012');

    return jwt.sign(key, algorithm: JWTAlgorithm.HS256);
  }

  // JWT Pindah Halaman
  static String generateJWT(int userId) {
    final jwt = JWT({
      'uid': userId, // sesuai dengan Android
      'iat':
          DateTime.now().millisecondsSinceEpoch ~/
          1000, // dalam format Unix timestamp
    });

    final token = jwt.sign(
      SecretKey('12345678901234567890123456789012'),
      algorithm: JWTAlgorithm.HS256,
    );

    return token;
  }

  //Login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final token = generateJWTLogin();

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
    final token = generateJWT(userId);
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
      if (data['success'] != null && data['success'] is List) {
        return List<Sprint>.from(
          data['success'].map((item) => Sprint.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil sprint: ${response.statusCode}');
    }
  }

  // ambil berita terbaru
  static Future<List<Berita>> fetchBerita(int unitId, int userId) async {
    final token = generateJWT(userId); // gunakan userId
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
      if (data['success'] != null && data['success'] is List) {
        return List<Berita>.from(
          data['success'].map((item) => Berita.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil berita: ${response.statusCode}');
    }
  }

  //Ambil Live Personel
  static Future<List<LivePerson>> fetchLivePersonel(int userId) async {
    final token = generateJWT(userId); // tambahkan userId
    final url = Uri.parse('${_baseUrl}api/live');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

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
    final token = generateJWT(userId);
    final url = Uri.parse('${_baseUrl}api/statistik/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

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

  // ambil kegiatan terakhir
  static Future<List<Giat>> fetchKegiatanTerakhir(int userId) async {
    final token = generateJWT(userId);
    final url = Uri.parse('${_baseUrl}api/latest/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] != null && data['success'] is List) {
        return List<Giat>.from(
          data['success'].map((item) => Giat.fromJson(item)),
        );
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil Giat: ${response.statusCode}');
    }
  }

  //All Giat
  static Future<List<Giat>> fetchAllGiat({
    required int userId,
    int sprintId = 0,
    int limit = 10,
    int offset = 0,
    String? keyword,
    String? jenis,
    DateTime? from,
    DateTime? to,
  }) async {
    final token = generateJWT(userId);
    final url = Uri.parse(
      '${_baseUrl}api/my_giat/$userId/$sprintId/$limit/$offset',
    );

    final body = {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (jenis != null && jenis.isNotEmpty) 'jenis': jenis,
      if (from != null) 'from': DateFormat('dd/MM/yyyy').format(from),
      if (to != null) 'to': DateFormat('dd/MM/yyyy').format(to),
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('Request body: $body');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] != null && data['success'] is List) {
        return List<Giat>.from(data['success'].map((e) => Giat.fromJson(e)));
      }
    }

    return [];
  }

  //Detail Giat
  static Future<Giat?> fetchGiatDetail(int giatId, int userId) async {
    final token = generateJWT(userId);
    final url = Uri.parse('${_baseUrl}api/giat/$giatId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] != null && data['success'] is Map<String, dynamic>) {
        try {
          return Giat.fromJson(data['success']);
        } catch (e) {
          return null;
        }
      }
    } else {
      throw Exception('Gagal mengambil Giat: ${response.statusCode}');
    }

    return null;
  }

  //Start Giat
  static Future<bool> sendCheckin(CheckinRequest request) async {
    final token = generateJWT(request.idPengguna);
    final url = Uri.parse('${_baseUrl}api/checkin');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] != null;
    } else {
      throw Exception('Gagal kirim checkin: ${response.statusCode}');
    }
  }

  //Stop Giat
  static Future<bool> sendCheckout(CheckinRequest request) async {
    final token = generateJWT(request.idPengguna);
    final url = Uri.parse('${_baseUrl}api/checkout');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print("[STOP GIAT] Response: ${response.statusCode}");
    print('[STOP GIAT] Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] != null;
    } else {
      throw Exception('Gagal kirim checkout: ${response.statusCode}');
    }
  }

  //Tracking
  static Future<bool> sendTrackingData({
    required int userId,
    required int sprintId,
    required double latitude,
    required double longitude,
  }) async {
    final token = generateJWT(userId);
    final url = Uri.parse('${_baseUrl}api/track');

    final body = {
      "id_pengguna": userId,
      "id_sprin": sprintId.toString(),
      "latitude": latitude,
      "longitude": longitude,
      "lambung": "",
      "T": 0,
      "J": 0,
      "W": 0,
      "L": 0,
      "partner": [],
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print("[TRACKING] Response: ${response.statusCode}");
    print('[TRACKING] Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] != null;
    } else {
      throw Exception('Gagal kirim tracking: ${response.statusCode}');
    }
  }

  //Kirim Laporan
  static Future<bool> submit({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final token = generateJWT(userId);
    final url = Uri.parse('${_baseUrl}api/submit');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    print("[Kirim Laporan] Response: ${response.statusCode}");
    print('[Kirim Laporan] Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final dataRes = jsonDecode(response.body);
      return dataRes['success'] != null;
    } else {
      throw Exception('Gagal kirim Laporan: ${response.statusCode}');
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
    final token = generateJWT(userId);
    final data = {
      'email': email,
      'no_mobile': noMobile,
      'current_password': sha1Hash(currentPassword),
    };

    if (newPassword != null && newPassword.isNotEmpty) {
      data['password'] = sha1Hash(newPassword);
    }

    final url = Uri.parse('${_baseUrl}api/save_me/$userId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data), // langsung pakai Map<String, String>
      );

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
}
