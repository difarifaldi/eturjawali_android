import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../models/giat.dart';
import 'giat_detail_page.dart';

class AllGiatPage extends StatefulWidget {
  final int userId;

  const AllGiatPage({super.key, required this.userId});

  @override
  State<AllGiatPage> createState() => _AllGiatPageState();
}

class _AllGiatPageState extends State<AllGiatPage> {
  List<Giat> allGiat = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int offset = 0;
  final int limit = 10;
  final ScrollController _scrollController = ScrollController();
  bool hasMore = true;

  final TextEditingController _keywordController = TextEditingController();
  String? selectedJenis;
  DateTime? dateFrom;
  DateTime? dateTo;
  bool isSearchVisible = false; // untuk toggle UI search

  @override
  void initState() {
    super.initState();
    loadAllGiat();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> loadAllGiat() async {
    if (isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    try {
      final data = await ApiService.fetchAllGiat(
        userId: widget.userId,
        limit: limit,
        offset: offset,
        keyword: _keywordController.text,
        jenis: selectedJenis,
        from: dateFrom,
        to: dateTo,
      );

      setState(() {
        allGiat.addAll(data);
        offset += data.length;
        hasMore = data.length == limit;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() => isLoadingMore = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat kegiatan: $e')));
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      loadAllGiat();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kegiatan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => isSearchVisible = !isSearchVisible);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isSearchVisible) _buildSearchForm(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: allGiat.length + (hasMore ? 1 : 0),
                    itemBuilder: _buildItem,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == allGiat.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final item = allGiat[index];
    final dateTimeString = item.time != null
        ? DateFormat('dd MMM yyyy HH:mm:ss').format(
            DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(item.time!) != null
                  ? int.parse(item.time!) * 1000
                  : 0,
            ).toLocal(),
          )
        : '-';

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GiatDetailPage(
                  giatId: int.parse(item.id),
                  userId: widget.userId,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  dateTimeString,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(item.sprintNo ?? '-', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              Text(item.desc ?? '-', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                item.workingUnitName ?? '-',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _keywordController,
            decoration: const InputDecoration(
              labelText: 'Kata kunci',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedJenis,
            decoration: const InputDecoration(labelText: 'Jenis Kegiatan'),
            items: const ['PENGATURAN', 'PENJAGAAN', 'PENGAWALAN', 'PATROLI']
                .map(
                  (jenis) => DropdownMenuItem(value: jenis, child: Text(jenis)),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedJenis = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        dateFrom = picked.start;
                        dateTo = picked.end;
                      });
                    }
                  },
                  child: Text(
                    (dateFrom != null && dateTo != null)
                        ? '${DateFormat('dd/MM/yyyy').format(dateFrom!)} - ${DateFormat('dd/MM/yyyy').format(dateTo!)}'
                        : 'Pilih Rentang Tanggal',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              offset = 0;
              allGiat.clear();
              hasMore = true;
              setState(() => isLoading = true);
              loadAllGiat();
            },
            icon: const Icon(Icons.search),
            label: const Text('Cari'),
          ),
        ],
      ),
    );
  }
}
