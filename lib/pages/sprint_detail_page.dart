import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import '../api_service.dart';
import '../models/checkin_request.dart';

class SprintDetailPage extends StatefulWidget {
  final int sprintId;
  final int userId;
  const SprintDetailPage({
    super.key,
    required this.sprintId,
    required this.userId,
  });

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
    restoreTimerIfNeeded();
  }

  //Mulai Waktu
  void startElapsedTimer({bool fromRestore = false}) async {
    if (_timer != null && _timer!.isActive) return;

    final prefs = await SharedPreferences.getInstance();

    if (!fromRestore) {
      final now = DateTime.now();
      await prefs.setBool('isTimerRunning', true);
      await prefs.setString('startTime', now.toIso8601String());
      setState(() {
        elapsedTime = Duration.zero;
      });
    }

    setState(() {
      isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime += const Duration(seconds: 1);
      });
    });
  }

  //Start Giat
  Future<void> checkinData(String note) async {
    if (userLocation == null) return;

    final checkinData = CheckinRequest(
      idPengguna: widget.userId,
      idSprin: widget.sprintId,
      latitude: userLocation!.latitude,
      longitude: userLocation!.longitude,
      pointLatitude: lokasiKesatuan.latitude,
      pointLongitude: lokasiKesatuan.longitude,
      note: note.isEmpty ? '-' : note,
    );

    try {
      final success = await ApiService.sendCheckin(checkinData);
      if (success) {
        print('Berhasil check-in');
      } else {
        print('Gagal check-in');
      }
    } catch (e) {
      print('Error saat check-in: $e');
    }
  }

  //Stop Giat
  Future<void> checkoutData(String note) async {
    if (userLocation == null) return;

    final checkoutData = CheckinRequest(
      idPengguna: widget.userId,
      idSprin: widget.sprintId,
      latitude: userLocation!.latitude,
      longitude: userLocation!.longitude,
      pointLatitude: lokasiKesatuan.latitude,
      pointLongitude: lokasiKesatuan.longitude,
      note: note.isEmpty ? '-' : note,
    );

    try {
      final success = await ApiService.sendCheckout(checkoutData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sprintId');
      await prefs.remove('isTimerRunning');
      await prefs.remove('startTime');

      // Update background service
      FlutterBackgroundService().invoke('updateSprintId', {'sprintId': null});

      if (success) {
        print('✅ Berhasil checkout');
      } else {
        print('❌ Gagal checkout');
      }
    } catch (e) {
      print('🚨 Error saat checkout: $e');
    }
  }

  //Stop Waktu
  void stopElapsedTimer() async {
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isTimerRunning');
    await prefs.remove('startTime');

    setState(() {
      isTimerRunning = false;
      elapsedTime = Duration.zero;
    });
  }

  Future<void> restoreTimerIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final running = prefs.getBool('isTimerRunning') ?? false;

    if (running) {
      final startStr = prefs.getString('startTime');
      if (startStr != null) {
        final start = DateTime.tryParse(startStr);
        if (start != null) {
          final now = DateTime.now();
          final duration = now.difference(start);

          setState(() {
            isTimerRunning = true;
            elapsedTime = duration;
          });

          startElapsedTimer(fromRestore: true);
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //Dapatkan Lokasi
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

  Future<void> saveSprintId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sprintId', widget.sprintId);
    print("📍 sprintId ${widget.sprintId} tersimpan ke SharedPreferences");

    FlutterBackgroundService().invoke('updateSprintId', {
      'sprintId': widget.sprintId,
    });
  }

  //Dialog Alasan
  void showAlasanDialog({
    required BuildContext context,
    required String title,
    required String message,
    required void Function(String alasan) onConfirm,
  }) {
    final TextEditingController alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
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
                final alasan = alasanController.text;
                Navigator.of(context).pop();
                onConfirm(alasan);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
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

                  final double jarak = distance.as(
                    LengthUnit.Meter,
                    userLocation!,
                    lokasiKesatuan,
                  );

                  if (jarak > radiusMeter) {
                    showAlasanDialog(
                      context: context,
                      title: 'Konfirmasi',
                      message:
                          'Anda berada di luar radius.\nMasukkan alasan untuk menyelesaikan giat:',
                      onConfirm: (alasan) {
                        checkoutData(alasan);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Giat dihentikan (luar radius)'),
                          ),
                        );
                      },
                    );
                  } else {
                    checkoutData('');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Giat dihentikan')),
                    );
                  }

                  return;
                }

                if (userLocation == null) return;

                final double jarak = distance.as(
                  LengthUnit.Meter,
                  userLocation!,
                  lokasiKesatuan,
                );

                if (jarak > radiusMeter) {
                  showAlasanDialog(
                    context: context,
                    title: 'Konfirmasi',
                    message:
                        'Anda berada di luar radius.\nMasukkan alasan untuk lanjut giat:',
                    onConfirm: (alasan) {
                      startElapsedTimer();
                      saveSprintId();
                      checkinData(alasan);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Giat dimulai (luar radius)'),
                        ),
                      );
                    },
                  );
                } else {
                  startElapsedTimer();
                  saveSprintId();
                  checkinData("");
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Giat dimulai')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(60),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
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
