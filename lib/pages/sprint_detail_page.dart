import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import '../api_service.dart';
import '../models/checkin_request.dart';
import 'laporan_page.dart';

class SprintDetailPage extends StatefulWidget {
  final int sprintId;
  final int userId;
  final String nomorSurat;

  const SprintDetailPage({
    super.key,
    required this.sprintId,
    required this.userId,
    required this.nomorSurat,
  });

  @override
  State<SprintDetailPage> createState() => _SprintDetailPageState();
}

class _SprintDetailPageState extends State<SprintDetailPage> {
  LatLng? userLocation;
  String currentTime = '';

  final MapController mapController = MapController();
  final Distance distance = Distance();
  final LatLng lokasiKesatuan = LatLng(
    -6.244222176711041,
    106.8554326236161,
  ); // Ganti dengan lokasi kesatuan sebenarnya
  final double radiusMeter = 100;

  bool isTimerRunning = false;
  Duration elapsedTime = Duration.zero;
  Timer? _timer;

  final PanelController _panelController = PanelController();
  bool isPanelOpen = false;

  double _iconOffsetY = 80;

  @override
  void initState() {
    super.initState();
    getLocation();
    currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    restoreTimerIfNeeded();
  }

  //Mulai Waktu
  void startElapsedTimer({bool fromRestore = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!fromRestore) {
      final now = DateTime.now();
      await prefs.setBool('isTimerRunning', true);
      await prefs.setString('startTime', now.toIso8601String());
    }

    setState(() {
      isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final startStr = prefs.getString('startTime');
      if (startStr != null) {
        final start = DateTime.tryParse(startStr);
        if (start != null) {
          final now = DateTime.now();
          setState(() {
            elapsedTime = now.difference(start);
          });
        }
      }
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

      // Update background service
      FlutterBackgroundService().invoke('updateSprintId', {'sprintId': null});

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sprintId');
      await prefs.remove('nomorSurat');
      await prefs.remove('isTimerRunning');
      await prefs.remove('startTime');

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
            currentTime = DateFormat(
              'HH:mm:ss',
            ).format(start); // ← Tambahkan ini
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

  //Ke Lokasi Saya
  Future<void> goToMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      mapController.move(currentLatLng, 16.0);

      setState(() {
        userLocation = currentLatLng;
      });
    } catch (e) {}
  }

  //Simpan sprint ke shared
  Future<void> saveSprintId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sprintId', widget.sprintId);
    await prefs.setString('nomorSurat', widget.nomorSurat);
    print("📍 sprintId ${widget.sprintId} tersimpan ke SharedPreferences");

    // 🔁 Tambah delay agar service isolate siap
    Future.delayed(Duration(seconds: 2), () {
      FlutterBackgroundService().invoke('updateSprintId', {
        'sprintId': widget.sprintId,
      });
      print("📤 Kirim sprintId ke background service");
    });
  }

  //Dapatkan laporan
  Future<List<Map<String, dynamic>>> getDraftLaporan() async {
    final prefs = await SharedPreferences.getInstance();
    final draftList = prefs.getStringList('draftLaporan') ?? [];
    return draftList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  //Dialog Alasan
  void showAlasanDialog({
    required BuildContext context,
    required String title,
    required String message,
    required void Function(String alasan) onConfirm,
  }) {
    final TextEditingController alasanController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 16),
                TextFormField(
                  controller: alasanController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan Keterangan',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Keterangan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final alasan = alasanController.text;
                  Navigator.of(context).pop();
                  onConfirm(alasan);
                }
                // Jika tidak valid, pesan error otomatis muncul di TextFormField
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
          // Panel dan isi layar utama
          Positioned.fill(
            child: isTimerRunning
                ? SlidingUpPanel(
                    controller: _panelController,
                    minHeight: 80,
                    maxHeight: 250,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: Colors.transparent,
                    boxShadow: [],
                    panelBuilder: (ScrollController sc) =>
                        _buildSlidingPanel(sc),
                    onPanelSlide: (position) {
                      setState(() {
                        isPanelOpen = position > 0.2;
                        _iconOffsetY =
                            80 +
                            (250 - 80) *
                                position; // minHeight + delta * position
                      });
                    },
                    body: _buildMainStack(),
                  )
                : _buildMainStack(),
          ),

          Positioned(
            right: 16,
            bottom: _iconOffsetY + 16, // posisi dinamis berdasarkan panel
            child: Column(
              children: [
                // Icon Dokumen
                GestureDetector(
                  onTap: () {
                    print("📄 Icon dokumen ditekan");
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ), // jarak antar ikon
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                    child: const Icon(Icons.description, color: Colors.black),
                  ),
                ),

                // Icon orang
                GestureDetector(
                  onTap: () {
                    print("👤 Icon orang ditekan");
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                    ),
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Laporan & Selesaikan di atas panel
          if (isTimerRunning)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStopButtons(),
            ),

          // Tombol Mulai
          if (!isTimerRunning)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStartButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainStack() {
    return Stack(
      children: [
        // Map
        if (userLocation != null)
          FlutterMap(
            mapController: mapController,
            options: MapOptions(center: userLocation, zoom: 16),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.eturjawali_android',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      'assets/images/ic_ev_lantas.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          const Center(child: CircularProgressIndicator()),

        //My Location
        Positioned(
          top: 100,
          right: 10,
          child: GestureDetector(
            onTap: goToMyLocation,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ),
        // Waktu
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(color: Colors.amber[300]),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black),
                const SizedBox(width: 8),
                const Text(
                  "Mulai: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  currentTime,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Spacer(),
                if (isTimerRunning)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
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
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlidingPanel(ScrollController controller) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isPanelOpen ? Colors.white : Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          if (isPanelOpen) ...[
            const SizedBox(height: 12),
            const Text(
              'DRAFT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            // Garis bawah kuning dengan lebar terbatas
            Container(height: 2, width: 100, color: Colors.amber),

            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getDraftLaporan(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final drafts = snapshot.data!;
                  if (drafts.isEmpty) {
                    return const Center(child: Text('Belum ada draft.'));
                  }

                  return ListView.builder(
                    controller: controller,
                    itemCount: drafts.length,
                    itemBuilder: (context, index) {
                      final draft = drafts[index];
                      final epochStr = draft['waktu'];
                      String waktuFormatted = '-';
                      if (epochStr != null) {
                        final epoch = int.tryParse(epochStr.toString());
                        if (epoch != null) {
                          final dt = DateTime.fromMillisecondsSinceEpoch(
                            epoch * 1000,
                          );
                          waktuFormatted =
                              '${dt.day.toString().padLeft(2, '0')} ${_bulan(dt.month)} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        }
                      }

                      final nomor = draft['nomor_sprint'] ?? '-';
                      final catatan = draft['catatan'] ?? '-';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            draft['jenis'] ?? 'Tanpa Jenis',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            nomor,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            catatan.length > 100
                                                ? catatan.substring(0, 100) +
                                                      '...'
                                                : catatan,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          waktuFormatted,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            final draftList =
                                                prefs.getStringList(
                                                  'draftLaporan',
                                                ) ??
                                                [];
                                            draftList.removeAt(index);
                                            await prefs.setStringList(
                                              'draftLaporan',
                                              draftList,
                                            );
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            height: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _bulan(int bulan) {
    const namaBulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return namaBulan[bulan - 1];
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: () {
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
                const SnackBar(content: Text('Giat dimulai (luar radius)')),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: const Text(
        "MULAI",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildStopButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final prefs = SharedPreferences.getInstance();
              prefs.then((sp) {
                final startStr = sp.getString('startTime');
                if (startStr != null) {
                  final startTime = DateTime.tryParse(startStr);
                  if (startTime != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LaporanPage(
                          startTime: startTime,
                          isTimerRunning: isTimerRunning,
                          currentTime: currentTime,
                        ),
                      ),
                    );
                  }
                }
              });
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text("LAPORAN", style: TextStyle(color: Colors.white)),
          ),
        ),

        Expanded(
          child: ElevatedButton(
            onPressed: () {
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
                    stopElapsedTimer();
                    checkoutData(alasan);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Giat dihentikan (luar radius)'),
                      ),
                    );
                  },
                );
              } else {
                stopElapsedTimer();
                checkoutData('');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giat dihentikan')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text(
              "SELESAIKAN",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
