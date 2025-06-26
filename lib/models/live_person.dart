class LivePerson {
  final String idPengguna;
  final String nama;
  final double latitude;
  final double longitude;
  final String login;
  final String kesatuanNama;

  LivePerson({
    required this.idPengguna,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.login,
    required this.kesatuanNama,
  });

  // Factory untuk parsing dari JSON
  factory LivePerson.fromJson(Map<String, dynamic> json) {
    return LivePerson(
      idPengguna: json['id_pengguna'] ?? '',
      nama: json['nama'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      login: json['login'] ?? '',
      kesatuanNama: json['kesatuan_nama'] ?? '',
    );
  }

  // Konversi ke JSON (jika perlu)
  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
      'login': login,
      'kesatuan_nama': kesatuanNama,
    };
  }
}
