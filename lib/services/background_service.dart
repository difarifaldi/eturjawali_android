import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../api_service.dart';

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

void startTrackingTimer(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
) {
  trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance &&
        !(await service.isForegroundService())) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();

      flutterLocalNotificationsPlugin.show(
        notificationId,
        'Tracking aktif',
        'Lokasi: ${position.latitude}, ${position.longitude}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'Tracking Location',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final sprintId = prefs.getInt('sprintId');

      print("user_id: $userId");
      print("sprint_id: $sprintId");

      if (userId != null && sprintId != null) {
        await ApiService.sendTrackingData(
          userId: userId,
          sprintId: sprintId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      print("[TRACKING ERROR] $e");
    }
  });
}

Timer? trackingTimer;
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Listener untuk update sprintId
  service.on('updateSprintId').listen((event) async {
    final prefs = await SharedPreferences.getInstance();
    final newSprintId = event?['sprintId'];
    if (newSprintId != null) {
      await prefs.setInt('sprintId', newSprintId);

      if (trackingTimer == null || !trackingTimer!.isActive) {
        print("▶️ Memulai tracking timer baru karena sprintId diperbarui");
        startTrackingTimer(service, flutterLocalNotificationsPlugin);
      }
    } else {
      await prefs.remove('sprintId');

      //  Stop timer jika sprintId null
      trackingTimer?.cancel();
      trackingTimer = null;
      print("⛔ Timer tracking dihentikan karena sprintId = null");
    }
  });

  // Lanjutkan tracking jika sprintId masih ada
  final prefs = await SharedPreferences.getInstance();
  final existingSprintId = prefs.getInt('sprintId');
  if (existingSprintId != null) {
    print("📦 Melanjutkan tracking karena sprintId masih ada");
    if (trackingTimer == null || !trackingTimer!.isActive) {
      startTrackingTimer(service, flutterLocalNotificationsPlugin);
    }
  }
}
