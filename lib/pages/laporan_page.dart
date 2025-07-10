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

  String? _selectedJenisLaporan;
  String? _selectedLokasi;
  String? _selectedJenisGatur;
  String? _selectedKegiatan;

  bool _showDetailForm = false;
  String? _selectedDetailOption;

  bool _showMediaPicker = false;
  String? _selectedMediaOption;

  TextEditingController _detailController = TextEditingController();
  TextEditingController _lambungController = TextEditingController();

  final List<String> _lokasi = [
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

  final List<String> _kegiatan = [
    'BERI JUK/ARAHAN',
    'BERI TEGURAN',
    'MENILANG',
    'MENYEBRANGKAN',
    'IJIN',
    'BERI JALAN',
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
                onTap: () {
                  Navigator.of(context).pop();
                  // Tambahkan aksi kamera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Foto dari Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Tambahkan aksi foto kamera
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Video dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Tambahkan aksi ambil video
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
        border: InputBorder.none, // Hapus border
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Laporan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Header waktu
                  Container(
                    width: double.infinity,
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

                  //Judul
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    color: Colors.black,
                    child: Text(
                      "LAPORAN PENGATURAN",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),

                  //Form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dropdown: Lokasi
                        buildDropdown(
                          selectedValue: _selectedLokasi,
                          options: _lokasi,
                          onChanged: (val) =>
                              setState(() => _selectedLokasi = val),
                          hint: 'LOKASI',
                        ),

                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 16),

                        // Dropdown: Jenis Gatur
                        buildDropdown(
                          selectedValue: _selectedJenisGatur,
                          options: _jenisGatur,
                          onChanged: (val) =>
                              setState(() => _selectedJenisGatur = val),
                          hint: 'JENIS GATUR',
                        ),

                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 16),

                        // Dropdown: Kegiatan
                        buildDropdown(
                          selectedValue: _selectedKegiatan,
                          options: _kegiatan,
                          onChanged: (val) =>
                              setState(() => _selectedKegiatan = val),
                          hint: 'KEGIATAN',
                        ),

                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 24),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Apakah Anda ingin mengirim detail kegiatan?',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'Ya',
                                  groupValue: _selectedDetailOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDetailOption = value;
                                      _showDetailForm = value == 'Ya';
                                    });
                                  },
                                ),
                                const Text('Ya'),
                                const SizedBox(width: 16),
                                Radio<String>(
                                  value: 'Tidak',
                                  groupValue: _selectedDetailOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDetailOption = value;
                                      _showDetailForm = value == 'Ya';
                                    });
                                  },
                                ),
                                const Text('Tidak'),
                              ],
                            ),
                          ],
                        ),

                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 16),

                        if (_showDetailForm) ...[
                          // Label untuk Detail Laporan
                          const Text(
                            'Detail Laporan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // Input detail laporan
                          TextField(
                            controller: _detailController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan detail laporan',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Label untuk Nomor Lambung
                          const Text(
                            'Nomor Lambung',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // Input nomor lambung
                          TextField(
                            controller: _lambungController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nomor lambung',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Pertanyaan media
                        const SizedBox(height: 16),
                        const Text(
                          'Apakah Anda ingin menambahkan media?',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Ya',
                              groupValue: _selectedMediaOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedMediaOption = value;
                                  _showMediaPicker = value == 'Ya';
                                });
                              },
                            ),
                            const Text('Ya'),
                            const SizedBox(width: 16),
                            Radio<String>(
                              value: 'Tidak',
                              groupValue: _selectedMediaOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedMediaOption = value;
                                  _showMediaPicker = value == 'Ya';
                                });
                              },
                            ),
                            const Text('Tidak'),
                          ],
                        ),

                        if (_showMediaPicker) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: InkWell(
                              onTap: () => _showMediaDialog(context),
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tombol SIMPAN dan BATAL
            Row(
              children: [
                // Tombol BATAL di kiri
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

                // Tombol SIMPAN di kanan
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedJenisLaporan != null &&
                          _selectedLokasi != null &&
                          _selectedJenisGatur != null &&
                          _selectedKegiatan != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan berhasil diisi'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lengkapi semua pilihan terlebih dahulu',
                            ),
                          ),
                        );
                      }
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
