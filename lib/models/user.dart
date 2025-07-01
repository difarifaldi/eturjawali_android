class User {
  final String nrp;
  final int userId;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String workingUnit;
  final String workingUnitId;
  final String photo;
  final String token;
  final String akses;
  final int status;

  User({
    required this.nrp,
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.workingUnit,
    required this.workingUnitId,
    required this.photo,
    required this.token,
    required this.akses,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nrp: json['login'] ?? '',
      userId: json['id_pengguna'] ?? 0,
      name: json['nama'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['no_mobile'] ?? '',
      workingUnit: json['kesatuan_nama'] ?? '',
      workingUnitId: json['id_kesatuan']?.toString() ?? '',
      photo: json['photo'] ?? '',
      token: json['token'] ?? '',
      akses: json['akses'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'login': nrp,
    'id_pengguna': userId,
    'nama': name,
    'email': email,
    'password': password,
    'no_mobile': phone,
    'kesatuan_nama': workingUnit,
    'id_kesatuan': workingUnitId,
    'photo': photo,
    'token': token,
    'akses': akses,
    'status': status,
  };

  /// Fungsi untuk mengecek akses
  bool allowed(String rightCode) {
    final upperAccess = akses.toUpperCase();
    final searchCode = '|${rightCode.toUpperCase()}|';
    return upperAccess.contains(searchCode);
  }
}
