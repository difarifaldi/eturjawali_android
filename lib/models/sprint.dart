// models/sprint.dart
class Sprint {
  final int id;
  final String nomor;
  final String startDate;
  final String endDate;
  final String document;
  final String subject;
  final int isRunning;
  final int userId;
  final String? onlineDate;

  Sprint({
    required this.id,
    required this.nomor,
    required this.startDate,
    required this.endDate,
    required this.document,
    required this.subject,
    required this.isRunning,
    required this.userId,
    this.onlineDate,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      id: json['id_sprin'],
      nomor: json['nomor'] ?? '',
      startDate: json['waktu_mulai'] ?? '',
      endDate: json['waktu_akhir'] ?? '',
      document: json['dokumen'] ?? '',
      subject: json['perihal'] ?? '',
      isRunning: json['online_status'] ?? 0,
      userId: json['user_id'] ?? 0,
      onlineDate: json['waktu_online'],
    );
  }

  String getFormattedDate() {
    final millis = int.tryParse(startDate) ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
    return "${date.day}-${date.month}-${date.year}";
  }

  String getFormattedOnlineDate() {
    final millis =
        int.tryParse(onlineDate ?? '') ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final date = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
    return "${date.day}-${date.month}-${date.year}";
  }
}
