class CheckinRequest {
  final int idPengguna;
  final int idSprin;
  final double latitude;
  final double longitude;
  final double pointLatitude;
  final double pointLongitude;
  final String note;

  CheckinRequest({
    required this.idPengguna,
    required this.idSprin,
    required this.latitude,
    required this.longitude,
    required this.pointLatitude,
    required this.pointLongitude,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'id_pengguna': idPengguna,
    'id_sprin': idSprin,
    'latitude': latitude,
    'longitude': longitude,
    'point_latitude': pointLatitude,
    'point_longitude': pointLongitude,
    'note': note,
  };
}
