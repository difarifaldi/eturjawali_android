// models/berita.dart
class Berita {
  final int id;
  final String title;
  final String content;
  final String date;
  final String workingUnitName;
  final String workingUnitId;
  final String target;

  Berita({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.workingUnitName,
    required this.workingUnitId,
    required this.target,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id_berita'],
      title: json['judul'] ?? '',
      content: json['berita'] ?? '',
      date: json['waktu_publikasi'] ?? '',
      workingUnitName: json['kesatuan_nama'] ?? '',
      workingUnitId: json['id_kesatuan'].toString(),
      target: json['sasaran'] ?? '',
    );
  }

  String getFormattedDate() {
    if (date.isEmpty) return "-";
    final millis = int.tryParse(date) ?? 0;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
