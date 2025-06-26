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

  double _percent(int jumlah) {
    if (statistik == null || statistik!.statOnline == 0) return 0;
    return (jumlah / statistik!.statOnline) * 100;
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, ${widget.username}!',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 24),

                    // SURAT PERINTAH
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Surat Perintah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (sprintList.isEmpty)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Belum Ada Surat Perintah'),
                        ),
                      )
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

                    // BERITA
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Berita Terkini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (beritaList.isEmpty)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Belum Ada Berita'),
                        ),
                      )
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

                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${livePersonList.length}',
                            style: const TextStyle(
                              fontSize: 60,
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
                    const SizedBox(height: 24),

                    // TOTAL ONLINE
                    if (statistik != null) ...[
                      _buildStatistikCard(
                        icon: Icons.pan_tool,
                        label: 'PENGATURAN',
                        jumlah: statistik!.statPengaturan,
                        percent: _percent(statistik!.statPengaturan),
                      ),
                      const SizedBox(height: 12),
                      _buildStatistikCard(
                        icon: Icons.shield,
                        label: 'PENJAGAAN',
                        jumlah: statistik!.statPenjagaan,
                        percent: _percent(statistik!.statPenjagaan),
                      ),
                      const SizedBox(height: 12),
                      _buildStatistikCard(
                        icon: Icons.directions_car,
                        label: 'PENGAWALAN',
                        jumlah: statistik!.statPengawalan,
                        percent: _percent(statistik!.statPengawalan),
                      ),
                      const SizedBox(height: 12),
                      _buildStatistikCard(
                        icon: Icons.local_police,
                        label: 'PATROLI',
                        jumlah: statistik!.statPatroli,
                        percent: _percent(statistik!.statPatroli),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // LIVE PERSONNEL LIST
                    // const Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Text(
                    //     'Personel Online',
                    //     style: TextStyle(
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // if (livePersonList.isEmpty)
                    //   const Text('Belum ada personel online')
                    // else
                    //   ...livePersonList.map(
                    //     (person) => Card(
                    //       elevation: 4,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(16),
                    //       ),
                    //       child: Container(
                    //         width: double.infinity,
                    //         padding: const EdgeInsets.all(16.0),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               person.nama,
                    //               style: const TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //             Text('Login: ${person.login}'),
                    //             Text('Kesatuan: ${person.kesatuanNama}'),
                    //             Text(
                    //               'Lokasi: ${person.latitude}, ${person.longitude}',
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatistikCard({
    required IconData icon,
    required String label,
    required int jumlah,
    required double percent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  jumlah.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (match) => '${match[1]}.',
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${percent.toStringAsFixed(1).replaceAll('.', ',')}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
