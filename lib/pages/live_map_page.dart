import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
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

  final PopupController _popupController = PopupController();

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

  List<Marker> _buildMarkers() {
    final markers = _personnel.map((p) {
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(p.latitude, p.longitude),
        child: Image.asset(
          'assets/images/ic_ev_lantas.png',
          width: 40,
          height: 40,
        ),
      );
    }).toList();

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personel Aktif")),
      body: PopupScope(
        popupController: _popupController,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(center: _center, zoom: 13.0),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.eturjawali_android',
            ),
            _personnel.isNotEmpty
                ? MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      disableClusteringAtZoom: 16,
                      size: const Size(40, 40),
                      markers: _buildMarkers(),
                      polygonOptions: const PolygonOptions(
                        borderColor: Colors.blueAccent,
                        color: Colors.black12,
                        borderStrokeWidth: 3,
                      ),
                      popupOptions: PopupOptions(
                        popupController: _popupController,
                        popupBuilder: (context, marker) =>
                            const Text(""), // nanti bisa diisi
                      ),
                      builder: (context, markers) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(), // jika belum ada data
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadLivePersonnel,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
