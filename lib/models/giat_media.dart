class GiatMedia {
  final String giatId;
  final String name;
  final String md5;
  final String mime;
  final double size;
  final String saveDate;
  final String fileUrl;

  GiatMedia({
    required this.giatId,
    required this.name,
    required this.md5,
    required this.mime,
    required this.size,
    required this.saveDate,
    required this.fileUrl,
  });

  factory GiatMedia.fromJson(Map<String, dynamic> json) {
    return GiatMedia(
      giatId: json['id_kegiatan'] ?? '',
      name: json['name'] ?? '',
      md5: json['md5'] ?? '',
      mime: json['mime'] ?? '',
      size: double.tryParse(json['size']?.toString() ?? '0') ?? 0,
      saveDate: json['waktu_simpan'] ?? '',
      fileUrl: json['fileurl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_kegiatan': giatId,
    'name': name,
    'md5': md5,
    'mime': mime,
    'size': size,
    'waktu_simpan': saveDate,
    'fileurl': fileUrl,
  };
}
