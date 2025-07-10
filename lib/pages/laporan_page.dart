import 'package:flutter/material.dart';
import 'dart:async';

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
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Foto dari Kamera'),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Video dari Galeri'),
                onTap: () => Navigator.of(context).pop(),
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
              _currentStep = 2;
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
              _currentStep = 3;
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
              _currentStep = 4;
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
              if (val.isNotEmpty) setState(() => _currentStep = 5);
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
              if (val.isNotEmpty) setState(() => _currentStep = 6);
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
              _currentStep = 2;
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
              _currentStep = 3;
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
              if (val.isNotEmpty) setState(() => _currentStep = 4);
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
              if (val.isNotEmpty) setState(() => _currentStep = 5);
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
              _currentStep = 2;
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
              if (val.isNotEmpty) setState(() => _currentStep = 3);
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
              if (val.isNotEmpty) setState(() => _currentStep = 4);
            },
            decoration: const InputDecoration(
              hintText: "Masukkan nomor lambung",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 4) ...[
          const Text("4. Daftar rute pengawalan:"),
          TextField(
            onChanged: (val) {
              if (val.isNotEmpty) setState(() => _currentStep = 5);
            },
            decoration: const InputDecoration(
              hintText: "Masukkan rute pengawalan",
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
              _currentStep = 2;
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
              _currentStep = 3;
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
              _currentStep = 4;
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
              if (val.isNotEmpty) setState(() => _currentStep = 5);
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
              if (val.isNotEmpty) setState(() => _currentStep = 6);
            },
            decoration: const InputDecoration(
              hintText: "Masukkan nomor lambung",
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentStep >= 6) ...[
          const Text("6. Daftar rute patroli:"),
          TextField(
            onChanged: (val) {
              if (val.isNotEmpty) setState(() => _currentStep = 7);
            },
            decoration: const InputDecoration(
              hintText: "Masukkan rute patroli",
            ),
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
    } else if (_selectedJenisLaporan == 'PATROLI') {
      laporan['jenis_kendaraan'] = _selectedJenisGatur;
    } else if (_selectedJenisLaporan == 'PENGAWALAN') {}

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
                    onPressed: () {
                      final data = getLaporanData();

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
