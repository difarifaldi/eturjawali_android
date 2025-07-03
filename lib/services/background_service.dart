import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const notificationChannelId = 'location_tracking';
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Tracking Location',
    description: 'Tracking lokasi berjalan',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Tracking berjalan',
      initialNotificationContent: 'Mengirim lokasi setiap 5 detik',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      notificationChannelId,
      'Tracking Location',
      icon: 'ic_bg_service_small', // Tanpa .png
      ongoing: true,
    ),
  );

  // Update Sprint
  service.on('updateSprintId').listen((event) async {
    final prefs = await SharedPreferences.getInstance();
    final newSprintId = event?['sprintId'];
    if (newSprintId != null) {
      await prefs.setInt('sprintId', newSprintId);
      print("🔄 sprintId diperbarui di background service: $newSprintId");
    } else {
      await prefs.remove('sprintId');
      print("🧹 sprintId dihapus dari SharedPreferences di background service");
    }
  });

  // Time periodic
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance &&
        !(await service.isForegroundService())) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();

      // Tampilkan notifikasi
      flutterLocalNotificationsPlugin.show(
        notificationId,
        'Tracking aktif',
        'Lokasi: ${position.latitude}, ${position.longitude}',
        notificationDetails,
      );

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final sprintId = prefs.getInt('sprintId');

      print("user_id: $userId");
      print("sprint_id: $sprintId");
      if (userId != null && sprintId != null) {
        final body = {
          "id_pengguna": userId,
          "id_sprin": sprintId.toString(),
          "latitude": position.latitude,
          "longitude": position.longitude,
          "lambung": "",
          "T": 0,
          "J": 0,
          "W": 0,
          "L": 0,
          "partner": [],
        };

        final response = await http.post(
          Uri.parse(
            'https://eturjawali.korlantas.polri.go.id/api/v2/api/track',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        print("[TRACKING] Response: ${response.statusCode}");
      }
    } catch (e) {
      print("[TRACKING ERROR] $e");
    }
  });
}
