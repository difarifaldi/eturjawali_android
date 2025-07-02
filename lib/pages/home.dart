import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../models/live_person.dart';
import '../models/statistik.dart';
import '../models/sprint.dart';
import '../models/berita.dart';
import '../models/giat.dart';
import 'profile_page.dart';
import 'all_giat_page.dart';
import 'sprint_detail_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final int userId;
  final int unitId;
  final String namaLengkap;
  final String kesatuanNama;
  final String email;
  final String noMobile;
  final String photo;

  const HomePage({
    super.key,
    required this.username,
    required this.userId,
    required this.unitId,
    required this.namaLengkap,
    required this.kesatuanNama,
    required this.email,
    required this.noMobile,
    required this.photo,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Sprint> sprintList = [];
  List<Berita> beritaList = [];
  List<LivePerson> livePersonList = [];
  List<Giat> giatList = [];
  Statistik? statistik;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final sprin = await ApiService.fetchSprint(widget.userId);
      final berita = await ApiService.fetchBerita(widget.unitId, widget.userId);
      final live = await ApiService.fetchLivePersonel(widget.userId);
      final stats = await ApiService.fetchStatistik(widget.userId);
      final giat = await ApiService.fetchKegiatanTerakhir(widget.userId);

      setState(() {
        sprintList = sprin;
        beritaList = berita;
        livePersonList = live;
        giatList = giat;
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

  double get _totalKegiatan =>
      statistik!.statPengaturan.toDouble() +
      statistik!.statPenjagaan.toDouble() +
      statistik!.statPengawalan.toDouble() +
      statistik!.statPatroli.toDouble();

  double _percent(int jumlah) {
    if (_totalKegiatan == 0) return 0;
    return (jumlah / _totalKegiatan) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('e-Turjawali', style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              }
              if (value == 'profile') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      nama: widget.namaLengkap,
                      email: widget.email,
                      noMobile: widget.noMobile,
                      photo: widget.photo,
                      username: widget.username,
                      kesatuanNama: widget.kesatuanNama,
                      userId: widget.userId,
                    ),
                  ),
                );
                if (result == true) {
                  loadData(); // refresh data setelah update profil
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              // Tambahkan menu lain nanti, misalnya "Profile"
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadData,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // agar bisa ditarik meskipun tidak scrollable penuh
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.namaLengkap} - ${widget.username}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.kesatuanNama,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
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
                          (item) => InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SprintDetailPage(),
                                ),
                              );
                            },
                            child: Card(
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
                                      item.subject,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(item.nomor),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy HH:mm:ss').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(item.startDate) * 1000,
                                        ).toLocal(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.workingUnitName} • ${item.getFormattedDate()}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),

                      // Giat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kegiatan Terakhir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AllGiatPage(userId: widget.userId),
                                ),
                              );
                            },
                            child: const Text('Selengkapnya'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      giatList.isEmpty
                          ? Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                child: const Text('Belum Ada Kegiatan'),
                              ),
                            )
                          : SizedBox(
                              height: 380,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: giatList.length,
                                itemBuilder: (context, index) {
                                  final item = giatList[index];
                                  final imageUrl = item.files.isNotEmpty
                                      ? item.files.first.fileUrl
                                      : null;

                                  final formattedDate = item.time != null
                                      ? DateFormat(
                                          'dd MMM yyyy HH:mm:ss',
                                        ).format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            int.tryParse(item.time!) != null
                                                ? int.parse(item.time!) * 1000
                                                : 0,
                                          ).toLocal(),
                                        )
                                      : '-';

                                  return Container(
                                    width: 250,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),

                                                // Gambar jika ada
                                                if (imageUrl != null)
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Image.network(
                                                      imageUrl,
                                                      height: 180,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Icon(
                                                            Icons.broken_image,
                                                            size: 80,
                                                          ),
                                                    ),
                                                  )
                                                else
                                                  const SizedBox(
                                                    height: 180,
                                                    child: Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(height: 8),

                                                Text(
                                                  item.workingUnitName ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(item.desc ?? '-'),

                                                const SizedBox(
                                                  height: 28,
                                                ), // beri ruang di bawah
                                              ],
                                            ),
                                          ),

                                          // Tanggal di pojok kanan bawah
                                          Positioned(
                                            right: 12,
                                            bottom: 12,
                                            child: Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 32),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Personel Aktif',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                    ],
                  ),
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
