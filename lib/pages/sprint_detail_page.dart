import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class SprintDetailPage extends StatefulWidget {
  const SprintDetailPage({super.key});

  @override
  State<SprintDetailPage> createState() => _SprintDetailPageState();
}

class _SprintDetailPageState extends State<SprintDetailPage> {
  LatLng? userLocation;
  String currentTime = '';

  final Distance distance = Distance();
  final LatLng lokasiKesatuan = LatLng(
    -6.244222176711041,
    106.8554326236161,
  ); // Ganti dengan lokasi kesatuan sebenarnya
  final double radiusMeter = 100; // radius maksimum (misal 100 meter)

  @override
  void initState() {
    super.initState();
    getLocation();
    currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
  }

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      print("User Location: $userLocation");
    });
    print("Lokasi diperoleh: $userLocation");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('e-Turjawali'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // MAP
          if (userLocation != null)
            FlutterMap(
              options: MapOptions(center: userLocation, zoom: 16),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Waktu
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.black),
                  const SizedBox(width: 8),
                  const Text(
                    "Mulai",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(currentTime),
                ],
              ),
            ),
          ),

          // Menampilkan pesan jika lokasi belum tersedia
          if (userLocation == null)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Sedang mencari lokasi...',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          // Tombol Mulai
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ElevatedButton(
              onPressed: () {
                print("User Location saat tekan tombol: $userLocation");
                if (userLocation == null) return;

                final double jarak = distance.as(
                  LengthUnit.Meter,
                  userLocation!,
                  lokasiKesatuan,
                );

                if (jarak > radiusMeter) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController alasanController =
                          TextEditingController();

                      return AlertDialog(
                        title: const Text(
                          'Konfirmasi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // biar sejajar kiri
                          children: [
                            const Text(
                              'Anda berada di luar radius',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Masukkan alasan untuk lanjut giat',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: alasanController,
                              decoration: const InputDecoration(
                                hintText: 'Masukan Keterangan',
                                border: UnderlineInputBorder(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Tidak'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Giat dimulai (luar radius)'),
                                ),
                              );
                            },
                            child: const Text('Ya'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Giat dimulai')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text(
                "MULAI",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
