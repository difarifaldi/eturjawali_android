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
  String? _selectedJenis;

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
    super.dispose();
  }

  final List<String> _jenisLaporan = [
    'Pengaturan',
    'Penjagaan',
    'Pengawalan',
    'Patroli',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Laporan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Header waktu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    _elapsedTime.toString().split('.').first.padLeft(8, '0'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Padding baru untuk isi lainnya
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jenis Laporan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedJenis,
                  hint: const Text('Pilih Jenis Laporan'),
                  items: _jenisLaporan.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedJenis = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedJenis != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Laporan: $_selectedJenis')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Silakan pilih jenis laporan'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
