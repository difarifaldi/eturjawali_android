class RouteModel {
  final String? longitude;
  final String? latitude;
  final String? address;
  final int order;

  RouteModel({
    this.longitude,
    this.latitude,
    this.address,
    required this.order,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      longitude: json['longitude'] ?? '',
      latitude: json['latitude'] ?? '',
      address: json['alamat'] ?? '',
      order: json['urutan'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'longitude': longitude,
    'latitude': latitude,
    'alamat': address,
    'urutan': order,
  };
}
