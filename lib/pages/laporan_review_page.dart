import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'sprint_detail_page.dart';

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
      ]);

      if (jenis == 'PENGATURAN') {
        items.addAll([
          const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(laporan['param1'] ?? '-'),
          const SizedBox(height: 12),
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
                  width: 0.100,
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
      } else if (jenis == 'PENJAGAAN') {
        items.addAll([
          const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(laporan['param1'] ?? '-'),
          const SizedBox(height: 12),

          const Text("Kegiatan", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(laporan['param2'] ?? '-'),
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
                  width: 0.100,
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
      } else if (jenis == 'PENGAWALAN') {
        items.addAll([
          const Text("Kegiatan", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(laporan['param1'] ?? '-'),
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
                  width: 0.100,
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
      } else if (jenis == 'PATROLI') {
        items.addAll([
          const Text("Jenis", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(laporan['param1'] ?? '-'),
          const SizedBox(height: 12),
          const Text("Sasaran", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  width: 0.100,
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
              // Tombol Batal
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: Colors.white, width: 0.9),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
              ),

              // Tombol Draft
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: Colors.white, width: 0.9),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final existingDrafts =
                          prefs.getStringList('draftLaporan') ?? [];

                      final draft = widget.laporan;
                      final draftJson = jsonEncode(draft);

                      existingDrafts.add(draftJson);
                      await prefs.setStringList('draftLaporan', existingDrafts);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Laporan disimpan sebagai draft.'),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SprintDetailPage(
                            sprintId: widget.laporan['id_sprin'],
                            userId: widget.laporan['id_petugas'],
                            nomorSurat: widget.laporan['nomor_sprint'],
                          ),
                        ),
                      );
                    },
                    child: const Text("Draft"),
                  ),
                ),
              ),

              // Tombol Kirim
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: Colors.white, width: 0.9),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final userId = widget.laporan['id_petugas'] ?? 0;
                        final data = widget.laporan;

                        await ApiService.submit(userId: userId, data: data);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Laporan dikirim!')),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SprintDetailPage(
                              sprintId: widget.laporan['id_sprin'],
                              userId: widget.laporan['id_petugas'],
                              nomorSurat: widget.laporan['nomor_sprint'],
                            ),
                          ),
                        );
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
