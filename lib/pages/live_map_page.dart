import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../api_service.dart';
import '../models/live_person.dart';

class LiveMapPage extends StatefulWidget {
  final int userId;
  const LiveMapPage({super.key, required this.userId});

  @override
  State<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends State<LiveMapPage> {
  List<LivePerson> _personnel = [];
  final mapController = MapController();
  LatLng _center = LatLng(-6.2, 106.8); // Default to Jakarta

  @override
  void initState() {
    super.initState();
    _loadLivePersonnel();
  }

  Future<void> _loadLivePersonnel() async {
    try {
      final data = await ApiService.fetchLivePersonel(widget.userId);
      if (data.isNotEmpty) {
        setState(() {
          _personnel = data;
          _center = LatLng(data.first.latitude, data.first.longitude);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data personel: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personel Aktif")),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(center: _center, zoom: 13.0),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.eturjawali_android',
          ),
          MarkerLayer(
            markers: _personnel.map((p) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(p.latitude, p.longitude),
                child: Column(
                  children: [
                    const Icon(Icons.location_on, size: 36, color: Colors.red),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLivePersonnel,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
