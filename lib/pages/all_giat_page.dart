import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../models/giat.dart';

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
      appBar: AppBar(title: const Text('Semua Kegiatan')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: allGiat.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        // Tanggal & waktu di pojok kanan atas
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Text(
                            dateTimeString,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.sprintNo ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item.desc ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
