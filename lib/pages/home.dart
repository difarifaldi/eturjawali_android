import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/live_person.dart';
import '../models/statistik.dart';

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
  List<LivePerson> livePersonList = [];
  Statistik? statistik;
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
      final live = await ApiService.fetchLivePersonel();
      final stats = await ApiService.fetchStatistik(widget.userId);

      setState(() {
        sprintList = sprin;
        beritaList = berita;
        livePersonList = live;
        statistik = stats;
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
                    const SizedBox(height: 32),

                    // Statistik Ringkasan
                    if (statistik != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistik Kegiatan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildStatCard(
                                'Pengaturan',
                                statistik!.statPengaturan,
                              ),
                              _buildStatCard(
                                'Penjagaan',
                                statistik!.statPenjagaan,
                              ),
                              _buildStatCard(
                                'Pengawalan',
                                statistik!.statPengawalan,
                              ),
                              _buildStatCard('Patroli', statistik!.statPatroli),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 32),

                    // Bagian Surat Perintah
                    const Text(
                      'Surat Perintah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (sprintList.isEmpty)
                      const Text('Belum ada Surat Perintah')
                    else
                      ...sprintList.map(
                        (item) => Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            child: Text(item['nomor'] ?? 'Tanpa nomor'),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Berita
                    const Text(
                      'Berita Terkini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (beritaList.isEmpty)
                      const Text('Belum ada berita')
                    else
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

                    // Ringkasan Personel Online
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${livePersonList.length}',
                            style: const TextStyle(
                              fontSize: 80,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'PETUGAS ONLINE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Personel Online',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (livePersonList.isEmpty)
                      const Text('Belum ada personel online')
                    else
                      ...livePersonList.map(
                        (person) => Card(
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
                                  person.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Login: ${person.login}'),
                                Text('Kesatuan: ${person.kesatuanNama}'),
                                Text(
                                  'Lokasi: ${person.latitude}, ${person.longitude}',
                                ),
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

  Widget _buildStatCard(String title, int value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
