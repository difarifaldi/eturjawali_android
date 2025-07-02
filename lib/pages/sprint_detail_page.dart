import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  final double radiusMeter = 100;

  bool isTimerRunning = false;
  Duration elapsedTime = Duration.zero;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    getLocation();
    currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
  }

  //Mulai Waktu
  void startElapsedTimer() {
    if (_timer != null && _timer!.isActive) return;

    setState(() {
      isTimerRunning = true;
      elapsedTime = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime += const Duration(seconds: 1);
      });
    });
  }

  //Stop Waktu
  void stopElapsedTimer() {
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                  if (isTimerRunning) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        elapsedTime.toString().split('.').first.padLeft(8, "0"),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                if (isTimerRunning) {
                  stopElapsedTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Giat dihentikan')),
                  );
                  return;
                }

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
                        title: const Text('Konfirmasi'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Anda berada di luar radius'),
                            const SizedBox(height: 4),
                            const Text('Masukkan alasan untuk lanjut giat'),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: alasanController,
                              decoration: const InputDecoration(
                                hintText: 'Masukan Keterangan',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Tidak'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              startElapsedTimer();
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
                  startElapsedTimer();
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
              child: Text(
                isTimerRunning ? "SELESAIKAN" : "MULAI",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
