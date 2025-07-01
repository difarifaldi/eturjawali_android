class Statistik {
  final int statPengaturan;
  final int statPenjagaan;
  final int statPengawalan;
  final int statPatroli;
  final int statOnline;

  Statistik({
    required this.statPengaturan,
    required this.statPenjagaan,
    required this.statPengawalan,
    required this.statPatroli,
    required this.statOnline,
  });

  factory Statistik.fromJson(Map<String, dynamic> json) {
    return Statistik(
      statPengaturan: int.tryParse(json['pengaturan'] ?? '0') ?? 0,
      statPenjagaan: int.tryParse(json['penjagaan'] ?? '0') ?? 0,
      statPengawalan: int.tryParse(json['pengawalan'] ?? '0') ?? 0,
      statPatroli: int.tryParse(json['patroli'] ?? '0') ?? 0,
      statOnline: int.tryParse(json['online'] ?? '0') ?? 0,
    );
  }
}
