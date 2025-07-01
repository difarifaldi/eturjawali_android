import 'package:flutter/material.dart';
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
                final imageUrl = item.files.isNotEmpty
                    ? item.files.first.fileUrl
                    : null;
                final date = item.time != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        int.tryParse(item.time!) != null
                            ? int.parse(item.time!) * 1000
                            : 0,
                      ).toLocal().toString().split(' ')[0]
                    : '-';

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.desc ?? '-'),
                        Text(item.workingUnitName ?? '-'),
                        Text(date),
                      ],
                    ),
                    trailing: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                );
              },
            ),
    );
  }
}
