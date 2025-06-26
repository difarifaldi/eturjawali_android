import 'package:flutter/material.dart';
import '../api_service.dart';

class HomePage extends StatefulWidget {
  final String username;
  final int userId;
  final int unitId;

  const HomePage({
    super.key,
    required this.username,
    required this.userId,
    required this.unitId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> sprintList = [];
  List<dynamic> beritaList = [];
  List<dynamic> kegiatanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final sprin = await ApiService.fetchSprint(widget.userId);
      final berita = await ApiService.fetchBerita(widget.unitId);
      final kegiatan = await ApiService.fetchKegiatanTerakhir(widget.userId);

      setState(() {
        sprintList = sprin;
        beritaList = berita;
        kegiatanList = kegiatan;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal load data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.username}!',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Surat Perintah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sprintList.map(
                      (item) => Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Text(item['no_sprin'] ?? 'Tanpa nomor'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Berita Terkini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...beritaList.map(
                      (item) => Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Text(item['judul'] ?? 'Tanpa judul'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Kegiatan Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...kegiatanList.map(
                      (item) => Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama_kegiatan'] ?? 'Tanpa nama',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(item['tanggal'] ?? 'Tanpa tanggal'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
