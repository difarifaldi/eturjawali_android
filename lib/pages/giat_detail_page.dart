import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/giat.dart';
import '../api_service.dart';

class GiatDetailPage extends StatefulWidget {
  final int giatId;
  final int userId;

  const GiatDetailPage({super.key, required this.giatId, required this.userId});

  @override
  State<GiatDetailPage> createState() => _GiatDetailPageState();
}

class _GiatDetailPageState extends State<GiatDetailPage> {
  Giat? giat;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    try {
      final result = await ApiService.fetchGiatDetail(
        widget.giatId,
        widget.userId,
      );
      setState(() {
        giat = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat detail: $e')));
    }
  }

  Widget buildItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Giat'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : giat == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildItem('Satuan Kerja', giat!.workingUnitName),
                  buildItem('Pembuat Laporan', giat!.userName),
                  buildItem(
                    'Waktu',
                    giat!.time != null
                        ? DateFormat('dd MMM yyyy HH:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              int.tryParse(giat!.time!)! * 1000,
                            ).toLocal(),
                          )
                        : '-',
                  ),
                  buildItem(
                    'Lokasi',
                    '${giat!.latitude ?? '-'}, ${giat!.longitude ?? '-'}\n${giat!.address ?? '-'}',
                  ),
                  buildItem('Param 1', giat!.param1),
                  buildItem('Param 2', giat!.param2),
                  buildItem('Param 3', giat!.param3),
                  buildItem('Nomor Lambung', giat!.lambungNo),
                  buildItem('Catatan Laporan', giat!.desc),
                  // Tambahkan `rekan` kalau nanti sudah ada datanya
                ],
              ),
            ),
    );
  }
}
