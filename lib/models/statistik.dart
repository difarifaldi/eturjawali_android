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
      statPengaturan: json['statPengaturan'] ?? 0,
      statPenjagaan: json['statPenjagaan'] ?? 0,
      statPengawalan: json['statPengawalan'] ?? 0,
      statPatroli: json['statPatroli'] ?? 0,
      statOnline: json['statOnline'] ?? 0,
    );
  }
}
