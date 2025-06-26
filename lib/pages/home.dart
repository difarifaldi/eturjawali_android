import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/live_person.dart'; // import model baru

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
  List<LivePerson> livePersonList = []; // tambahan
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
      //final kegiatan = await ApiService.fetchKegiatanTerakhir(widget.userId);
      final live = await ApiService.fetchLivePersonel(); // tambahan

      setState(() {
        sprintList = sprin;
        beritaList = berita;
        livePersonList = live;
        // kegiatanList = kegiatan;
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

                    // Bagian Berita
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

                    // Bagian Kegiatan Terakhir
                    // const Text(
                    //   'Kegiatan Terakhir',
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // if (kegiatanList.isEmpty)
                    //   const Text('Belum ada kegiatan')
                    // else
                    //   ...kegiatanList.map(
                    //     (item) => Card(
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
                    //               item['jenis'] ?? 'Tanpa nama',
                    //               style: const TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Text(item['waktu_simpan'] ?? 'Tanpa tanggal'),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    const SizedBox(height: 32),

                    // Bagian Personel Live
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${livePersonList.length}',
                            style: TextStyle(
                              fontSize: 80,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              height: 1, // Mengurangi jarak antar baris
                            ),
                          ),
                          const Text(
                            'PETUGAS ONLINE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1, // Supaya menempel ke atas
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
}
