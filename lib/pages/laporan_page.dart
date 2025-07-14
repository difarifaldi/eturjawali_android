import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaporanPage extends StatefulWidget {
  final DateTime startTime;
  final bool isTimerRunning;
  final String currentTime;

  const LaporanPage({
    super.key,
    required this.isTimerRunning,
    required this.startTime,
    required this.currentTime,
  });

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  Duration _elapsedTime = Duration.zero;
  late Timer _timer;

  int _currentStep = 0;

  String? _selectedJenisLaporan;
  String? _selectedLokasi;
  String? _selectedJenisGatur;
  String? _selectedKegiatan;

  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _lambungController = TextEditingController();

  final List<String> _jenisLaporan = [
    'PENGATURAN',
    'PENJAGAAN',
    'PENGAWALAN',
    'PATROLI',
  ];

  final List<String> _lokasiPengaturan = [
    'PERSIMPANGAN',
    'PUTARAN',
    'BELOK ARAH',
    'PENYEBRANGAN',
    'TMP KERAMAIAN',
    'TOL-GERBANG TOL',
    'TOL-REST AREA',
    'TOL-CHEVRON',
    'TOL-EXIT & IN RUN',
  ];

  final List<String> _jenisGatur = [
    'PERCEPATAN LALU LINTAS',
    'ALIH TUTUP ARUS LANTAS',
    'TUTUP ARUS LANTAS',
    'LAIN LAIN',
  ];

  final List<String> _kegiatanPengaturan = [
    'BERI JUK/ARAHAN',
    'BERI TEGURAN',
    'MENILANG',
    'MENYEBRANGKAN',
    'IJIN BERI JALAN',
    'PENANGANAN TP TKP',
    'GUANTIBMAS',
    'LAIN LAIN',
  ];

  final List<String> _lokasiPenjagaan = [
    'MAKO KANTOR POS TETAP',
    'POS SEMENTARA - REST AREA',
    'POS SEMENTARA - POS OPERASI',
    'POS SEMENTARA - POS PANTAU',
    'INDUK PJR DIPERKUAT',
  ];

  final List<String> _kegiatanPenjagaan = [
    'BERI JUK/HIMBAUAN',
    'BERI TEGURAN',
    'MENILANG',
    'MENYEBRANGKAN',
    'ARUS BALIK',
    'LAIN LAIN',
  ];

  final List<String> _kegiatanPengawalan = [
    'PIMPINAN LEMBAGA RI',
    'PIMPINAN LEMBAGA NEGARA ASING',
    'KONVOI ROMBONGAN',
    'JENAZAH',
    'IRING IRINGAN',
    'PERTIMBANGAN POLRI',
    'LOGISTIK PEMILU',
    'PASLON PEMILU',
    'LAIN LAIN',
  ];

  final List<String> _jenisKendaraanPatroli = ['RODA DUA', 'RODA EMPAT'];

  final List<String> _sasaranPatroli = ['DALAM KOTA', 'LUAR KOTA', 'JALAN TOL'];

  final List<String> _kegiatanPatroli = [
    'DATANGI LOKASI RWN MACET',
    'DATANGI LOKASI RWN GAR',
    'DATANGI LOKASI RWN LAKA',
    'DATANGI LOKASI RWN TP DI JLN',
    'PENANGANAN TP TKP',
    'GUANTIBMAS',
    'LAIN LAIN',
  ];

  Future<String> getAlamatLengkap(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'flutter-app', // Diperlukan oleh Nominatim
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? 'Alamat tidak ditemukan';
    } else {
      return 'Gagal mendapatkan alamat';
    }
  }

  final List<File> _mediaListPengaturan = [];
  final List<File> _mediaListPenjagaan = [];
  final List<File> _mediaListPengawalan = [];
  final List<File> _mediaListPatroli = [];
  final ImagePicker _picker = ImagePicker();
  void _showMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ambil Media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Dari Kamera'),
                onTap: () async {
                  final XFile? pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      if (_selectedJenisLaporan == 'PENGATURAN') {
                        _mediaListPengaturan.add(File(pickedFile.path));
                      } else if (_selectedJenisLaporan == 'PENJAGAAN') {
                        _mediaListPenjagaan.add(File(pickedFile.path));
                      } else if (_selectedJenisLaporan == 'PENGAWALAN') {
                        _mediaListPengawalan.add(File(pickedFile.path));
                      } else if (_selectedJenisLaporan == 'PATROLI') {
                        _mediaListPatroli.add(File(pickedFile.path));
                      }
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Dari Galeri'),
                onTap: () async {
                  final XFile? pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      if (_selectedJenisLaporan == 'PENGATURAN') {
                        _mediaListPengaturan.add(File(pickedFile.path));
                      } else if (_selectedJenisLaporan == 'PENJAGAAN') {
                        _mediaListPenjagaan.add(File(pickedFile.path));
                      } else if (_selectedJenisLaporan == 'PENGAWALAN') {
                        _mediaListPengawalan.add(File(pickedFile.path));
                      } else if (_selectedJenisLaporan == 'PATROLI') {
                        _mediaListPatroli.add(File(pickedFile.path));
                      }
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Batal'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  final List<Map<String, dynamic>> _ruteListPengawalan = [];
  final List<Map<String, dynamic>> _ruteListPatroli = [];
  void _showRuteDialog(BuildContext context) async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final lat = position.latitude;
    final lng = position.longitude;

    // Ambil alamat lengkap dari latlng
    final lokasiLengkap = await getAlamatLengkap(lat, lng);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rute Lokasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(center: LatLng(lat, lng), zoom: 16),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.eturjawali_android',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text("Lokasi"),
              Text("Lat: $lat, Lng: $lng"),
              Text(lokasiLengkap),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Simpan rute ke list
                setState(() {
                  final rute = {
                    'lat': lat,
                    'lng': lng,
                    'alamat': lokasiLengkap,
                  };

                  if (_selectedJenisLaporan == 'PENGAWALAN') {
                    _ruteListPengawalan.add(rute);
                  } else if (_selectedJenisLaporan == 'PATROLI') {
                    _ruteListPatroli.add(rute);
                  }

                  _currentStep = max(_currentStep, 7);
                });

                Navigator.pop(context);
              },
              child: const Text("SIMPAN"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.isTimerRunning) {
      _elapsedTime = DateTime.now().difference(widget.startTime);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsedTime = DateTime.now().difference(widget.startTime);
        });
      });
    }
  }

  @override
  void dispose() {
    if (widget.isTimerRunning) {
      _timer.cancel();
    }
    _detailController.dispose();
    _lambungController.dispose();
    super.dispose();
  }

  Widget buildDropdown({
    required String? selectedValue,
    required List<String> options,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: hint != null ? Text(hint) : null,
      items: options
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  List<Widget> buildFormSteps() {
    if (_selectedJenisLaporan == 'PENGATURAN') {
      return [
        if (_currentStep >= 1) ...[
          const Text("1. Di mana lokasi pengaturan?"),
          buildDropdown(
            selectedValue: _selectedLokasi,
            options: _lokasiPengaturan,
            onChanged: (val) => setState(() {
              _selectedLokasi = val;
              _currentStep = max(_currentStep, 2);
            }),
            hint: "Pilih lokasi",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 2) ...[
          const Text("2. Jenis pengaturan apa yang dilakukan?"),
          buildDropdown(
            selectedValue: _selectedJenisGatur,
            options: _jenisGatur,
            onChanged: (val) => setState(() {
              _selectedJenisGatur = val;
              _currentStep = max(_currentStep, 3);
            }),
            hint: "Pilih jenis gatur",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 3) ...[
          const Text("3. Kegiatan apa yang dilakukan?"),
          buildDropdown(
            selectedValue: _selectedKegiatan,
            options: _kegiatanPengaturan,
            onChanged: (val) => setState(() {
              _selectedKegiatan = val;
              _currentStep = max(_currentStep, 4);
            }),
            hint: "Pilih kegiatan",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 4) ...[
          const Text("4. Jelaskan detail kegiatan:"),
          TextField(
            controller: _detailController,
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 5));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan detail laporan",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 5) ...[
          const Text("5. Masukkan nomor lambung kendaraan:"),
          TextField(
            controller: _lambungController,
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 6));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan nomor lambung",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 6) ...[
          const Text("6. Ambil media pendukung:"),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () => _showMediaDialog(context),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_mediaListPengaturan.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_mediaListPengaturan.length, (index) {
                final media = _mediaListPengaturan[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        media,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _mediaListPengaturan.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

          const SizedBox(height: 24),
        ],
      ];
    } else if (_selectedJenisLaporan == 'PENJAGAAN') {
      return [
        if (_currentStep >= 1) ...[
          const Text("1. Di mana lokasi penjagaan?"),
          buildDropdown(
            selectedValue: _selectedLokasi,
            options: _lokasiPenjagaan,
            onChanged: (val) => setState(() {
              _selectedLokasi = val;
              _currentStep = max(_currentStep, 2);
            }),
            hint: "Pilih lokasi",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 2) ...[
          const Text("2. Kegiatan apa yang dilakukan?"),
          buildDropdown(
            selectedValue: _selectedKegiatan,
            options: _kegiatanPenjagaan,
            onChanged: (val) => setState(() {
              _selectedKegiatan = val;
              _currentStep = max(_currentStep, 3);
            }),
            hint: "Pilih kegiatan",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 3) ...[
          const Text("3. Jelaskan detail kegiatan:"),
          TextField(
            controller: _detailController,
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 4));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan detail laporan",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 4) ...[
          const Text("4. Masukkan nomor lambung kendaraan:"),
          TextField(
            controller: _lambungController,
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 5));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan nomor lambung",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 5) ...[
          const Text("5. Ambil media pendukung:"),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () => _showMediaDialog(context),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_mediaListPenjagaan.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_mediaListPenjagaan.length, (index) {
                final media = _mediaListPenjagaan[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        media,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _mediaListPenjagaan.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

          const SizedBox(height: 24),
        ],
      ];
    } else if (_selectedJenisLaporan == 'PENGAWALAN') {
      return [
        if (_currentStep >= 1) ...[
          const Text("1. Kegiatan pengawalan apa yang dilakukan?"),
          buildDropdown(
            selectedValue: _selectedKegiatan,
            options: _kegiatanPengawalan,
            onChanged: (val) => setState(() {
              _selectedKegiatan = val;
              _currentStep = max(_currentStep, 2);
            }),
            hint: "Pilih kegiatan",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 2) ...[
          const Text("2. Jelaskan detail kegiatan:"),
          TextField(
            controller: _detailController,
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 3));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan detail laporan",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 3) ...[
          const Text("3. Masukkan nomor lambung kendaraan:"),
          TextField(
            controller: _lambungController,
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 4));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan nomor lambung",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 4) ...[
          const Text("4. Daftar rute pengawalan:"),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showRuteDialog(context),
            icon: const Icon(Icons.map),
            label: const Text("Tambah rute"),
          ),
          const SizedBox(height: 12),

          // Tampilkan rute yang sudah ditambahkan
          if (_ruteListPengawalan.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_ruteListPengawalan.length, (index) {
                final rute = _ruteListPengawalan[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Rute ${index + 1}:"),
                            Text("Lat: ${rute['lat']}, Lng: ${rute['lng']}"),
                            Text(rute['alamat']),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _ruteListPengawalan.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),

          const SizedBox(height: 24),
        ],
        if (_currentStep >= 5) ...[
          const Text("5. Ambil media pendukung:"),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () => _showMediaDialog(context),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_mediaListPengawalan.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_mediaListPengawalan.length, (index) {
                final media = _mediaListPengawalan[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        media,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _mediaListPengawalan.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

          const SizedBox(height: 24),
        ],
      ];
    } else if (_selectedJenisLaporan == 'PATROLI') {
      return [
        if (_currentStep >= 1) ...[
          const Text("1. Jenis kendaraan patroli:"),
          buildDropdown(
            selectedValue: _selectedJenisGatur,
            options: _jenisKendaraanPatroli,
            onChanged: (val) => setState(() {
              _selectedJenisGatur = val;
              _currentStep = max(_currentStep, 2);
            }),
            hint: "Pilih jenis kendaraan",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 2) ...[
          const Text("2. Sasaran patroli:"),
          buildDropdown(
            selectedValue: _selectedLokasi,
            options: _sasaranPatroli,
            onChanged: (val) => setState(() {
              _selectedLokasi = val;
              _currentStep = max(_currentStep, 3);
            }),
            hint: "Pilih sasaran",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 3) ...[
          const Text("3. Kegiatan patroli:"),
          buildDropdown(
            selectedValue: _selectedKegiatan,
            options: _kegiatanPatroli,
            onChanged: (val) => setState(() {
              _selectedKegiatan = val;
              _currentStep = max(_currentStep, 4);
            }),
            hint: "Pilih kegiatan",
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        if (_currentStep >= 4) ...[
          const Text("4. Jelaskan detail kegiatan:"),
          TextField(
            controller: _detailController,

            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 5));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan detail laporan",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 5) ...[
          const Text("5. Masukkan nomor lambung kendaraan:"),
          TextField(
            controller: _lambungController,

            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _currentStep = max(_currentStep, 6));
              }
            },

            decoration: const InputDecoration(
              hintText: "Masukkan nomor lambung",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 6) ...[
          const Text("6. Daftar rute patroli:"),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showRuteDialog(context),
            icon: const Icon(Icons.map),
            label: const Text("Tambah rute"),
          ),
          const SizedBox(height: 12),

          if (_ruteListPatroli.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_ruteListPatroli.length, (index) {
                final rute = _ruteListPatroli[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Rute ${index + 1}:"),
                            Text("Lat: ${rute['lat']}, Lng: ${rute['lng']}"),
                            Text(rute['alamat']),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _ruteListPatroli.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),

          const SizedBox(height: 24),
        ],
        if (_currentStep >= 7) ...[
          const Text("7. Ambil media pendukung:"),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () => _showMediaDialog(context),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_mediaListPatroli.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_mediaListPatroli.length, (index) {
                final media = _mediaListPatroli[index];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        media,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _mediaListPatroli.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

          const SizedBox(height: 24),
        ],
      ];
    }

    return [];
  }

  // Map Data
  Map<String, dynamic> getLaporanData() {
    final laporan = <String, dynamic>{
      'jenis_laporan': _selectedJenisLaporan,
      'lokasi': _selectedLokasi,
      'kegiatan': _selectedKegiatan,
      'detail': _detailController.text,
      'lambung': _lambungController.text,
    };

    if (_selectedJenisLaporan == 'PENGATURAN') {
      laporan['jenis_gatur'] = _selectedJenisGatur;
      laporan['media'] = _mediaListPengaturan.map((file) => file.path).toList();
    } else if (_selectedJenisLaporan == 'PENJAGAAN') {
      laporan['media'] = _mediaListPenjagaan.map((file) => file.path).toList();
    } else if (_selectedJenisLaporan == 'PENGAWALAN') {
      laporan['rute'] = _ruteListPengawalan;
      laporan['media'] = _mediaListPengawalan.map((file) => file.path).toList();
    } else if (_selectedJenisLaporan == 'PATROLI') {
      laporan['jenis_kendaraan'] = _selectedJenisGatur;
      laporan['rute'] = _ruteListPatroli;
      laporan['media'] = _mediaListPatroli.map((file) => file.path).toList();
    }

    return laporan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('e-Turjawali'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    color: Colors.yellow,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.black),
                        const SizedBox(width: 8),
                        const Text(
                          "Mulai",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(widget.currentTime),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: Colors.white,
                          child: Text(
                            _elapsedTime
                                .toString()
                                .split('.')
                                .first
                                .padLeft(8, '0'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.black,
                    child: const Text(
                      "LAPORAN TURJAWALI",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Laporan jenis apa yang akan dibuat?'),
                        buildDropdown(
                          selectedValue: _selectedJenisLaporan,
                          options: _jenisLaporan,
                          onChanged: (val) {
                            setState(() {
                              _selectedJenisLaporan = val;
                              _currentStep = 1;
                              _selectedLokasi = null;
                              _selectedJenisGatur = null;
                              _selectedKegiatan = null;
                              _detailController.clear();
                              _lambungController.clear();
                            });
                          },
                        ),
                        const Divider(thickness: 1),
                        const SizedBox(height: 16),
                        ...buildFormSteps(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'BATAL',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final data = getLaporanData();

                      // Simpan data ke SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                        'last_laporan',
                        jsonEncode(data),
                      ); // simpan data laporan
                      await prefs.setInt(
                        'last_report_time',
                        DateTime.now().millisecondsSinceEpoch,
                      ); // simpan waktu sekarang

                      // Tampilkan data di dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Data Laporan"),
                          content: SingleChildScrollView(
                            child: Text(data.toString()),
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Tutup"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'SIMPAN',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
