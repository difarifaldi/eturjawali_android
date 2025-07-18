import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class LaporanReviewPage extends StatefulWidget {
  final Map<String, dynamic> laporan;

  const LaporanReviewPage({Key? key, required this.laporan}) : super(key: key);

  @override
  State<LaporanReviewPage> createState() => _LaporanReviewPageState();
}

class _LaporanReviewPageState extends State<LaporanReviewPage> {
  String durasi = '-';

  @override
  void initState() {
    super.initState();
    hitungDurasi();
  }

  Future<void> hitungDurasi() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString('startTime');
    final waktuSimpanStr = widget.laporan['waktu_simpan'];

    if (startStr != null && waktuSimpanStr != null) {
      final start = DateTime.tryParse(startStr);
      final waktuSimpanEpoch = int.tryParse(waktuSimpanStr);
      if (start != null && waktuSimpanEpoch != null) {
        final waktuSimpan = DateTime.fromMillisecondsSinceEpoch(
          waktuSimpanEpoch * 1000,
        );
        final selisih = waktuSimpan.difference(start);

        setState(() {
          final hours = selisih.inHours;
          final minutes = selisih.inMinutes % 60;
          final seconds = selisih.inSeconds % 60;

          durasi = '$hours jam $minutes menit $seconds detik';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final laporan = widget.laporan;
    final jenis = laporan['jenis'];

    List<Widget> buildReviewItems() {
      List<Widget> items = [];

      // durasi
      items.addAll([
        const Text(
          "Durasi Laporan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(durasi),
        const SizedBox(height: 12),
        const Text(
          "Lokasi Petugas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${laporan['latitude']?.toString() ?? '-'}, ${laporan['longitude']?.toString() ?? '-'}',
        ),
        Text(laporan['lokasi'] ?? '-'),
        const SizedBox(height: 12),

        const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(laporan['param1'] ?? '-'),
        const SizedBox(height: 12),
      ]);

      if (jenis == 'PENGATURAN') {
        items.addAll([
          const Text(
            "Jenis Gatur",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(laporan['param2'] ?? '-'),
          const SizedBox(height: 12),

          const Text("Kegiatan", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(laporan['param3'] ?? '-'),
          const SizedBox(height: 12),

          const Text(
            "Nomor lambung",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(laporan['no_lambung'] ?? '-'),
          const SizedBox(height: 12),

          const Text(
            "Media pendukung",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (laporan['files'] != null && laporan['files'].isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(laporan['files'].length, (index) {
                final filePath = laporan['files'][index];
                return Image.file(
                  File(filePath),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              }),
            )
          else
            const Text("Tidak ada media"),

          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const Text(
            "Detail kegiatan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(laporan['catatan'] ?? '-'),
          const SizedBox(height: 12),
        ]);
      }

      return items;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Review Laporan")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(children: buildReviewItems()),
            ),
          ),
          // Tombol bawah menempel kiri kanan tanpa radius
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      side: const BorderSide(color: Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        final userId = widget.laporan['id_petugas'] ?? 0;
                        final data = widget.laporan;

                        await ApiService.submit(userId: userId, data: data);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Laporan dikirim!')),
                          );
                          Navigator.pop(context); // kembali setelah berhasil
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengirim laporan: $e'),
                            ),
                          );
                        }
                      }
                    },

                    child: const Text("Kirim"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
