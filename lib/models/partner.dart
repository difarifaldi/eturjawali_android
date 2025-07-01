import 'user.dart';

class Partner extends User {
  bool selected;

  Partner({
    required super.nrp,
    required super.userId,
    required super.name,
    required super.email,
    required super.password,
    required super.phone,
    required super.workingUnit,
    required super.workingUnitId,
    required super.photo,
    required super.token,
    required super.akses,
    required super.status,
    this.selected = false,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
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
      selected: false,
    );
  }

  @override
  Map<String, dynamic> toJson() => super.toJson();
}
