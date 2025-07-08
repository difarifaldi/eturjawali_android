import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

import '../api_service.dart';

const notificationChannelId = 'location_tracking';
const notificationId = 888;

Future<void> openBatteryOptimizationSettings() async {
  final intent = AndroidIntent(
    action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
  );
  await intent.launch();
}

Future<void> openAutostartSettings() async {
  final intent = AndroidIntent(
    action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
    data: 'package:com.example.eturjawali_android',
  );
  await intent.launch();
}

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.whileInUse) {
    print(
      "[PERMISSION] Lokasi hanya diizinkan saat app digunakan. Perlu background access.",
    );
  } else if (permission == LocationPermission.always) {
    print("[PERMISSION] Lokasi diizinkan di background (👍)");
  }
}

@pragma('vm:entry-point')
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
      autoStartOnBoot: true,
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

Future<void> startTrackingLoop(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
) async {
  print("[DEBUG] 🚀 Loop DIMULAI");

  final prefs = await SharedPreferences.getInstance();

  while (true) {
    try {
      print("[LOOP] Loop masih berjalan");

      if (service is AndroidServiceInstance) {
        final isForeground = await service.isForegroundService();
        if (!isForeground) {
          await service.setAsForegroundService();
        }
      }

      Position? position;
      try {
        print("[DEBUG] 🔍 Meminta lokasi realtime...");
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        );
      } catch (e) {
        print("[GPS ERROR] Gagal ambil lokasi realtime: $e");
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        print("[TRACKING] Lokasi tidak tersedia, skip...");
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      // Tampilkan notifikasi lokasi
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

      final userId = prefs.getInt('userId');
      final sprintId = prefs.getInt('sprintId');

      print("[TRACKING] userId: $userId, sprintId: $sprintId");

      if (userId != null && sprintId != null) {
        try {
          final response = await ApiService.sendTrackingData(
            userId: userId,
            sprintId: sprintId,
            latitude: position.latitude,
            longitude: position.longitude,
          );
          print("[TRACKING] Response setelah kirim: $response");
        } catch (e, stack) {
          print("[TRACKING ERROR] Gagal kirim ke server: $e");
          print("[STACK] $stack");
        }
      } else {
        print(
          "[TRACKING] Tidak ada sprintId/userId, hanya tampilkan notifikasi.",
        );
      }

      await Future.delayed(const Duration(seconds: 5));
    } catch (e, stack) {
      print("[TRACKING ERROR] $e");
      print("[STACK TRACE] $stack");
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WakelockPlus.enable();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final prefs = await SharedPreferences.getInstance();

  // Loop tracking akan berjalan terus, tetapi hanya kirim data jika sprintId != null
  unawaited(startTrackingLoop(service, flutterLocalNotificationsPlugin));

  // Dengarkan update sprintId
  service.on('updateSprintId').listen((event) async {
    final newSprintId = event?['sprintId'];
    if (newSprintId != null) {
      await prefs.setInt('sprintId', newSprintId);
      print("📥 SprintId diperbarui: $newSprintId");
    } else {
      await prefs.remove('sprintId');
      print("❌ SprintId dihapus");
    }
  });

  // Debug loop untuk menunjukkan service tetap hidup
  Timer.periodic(const Duration(minutes: 5), (_) {
    print("[SERVICE] Background loop still alive...");
  });
}
