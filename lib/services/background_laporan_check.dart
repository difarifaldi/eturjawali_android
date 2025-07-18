import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void backgroundLaporanCheck() async {
  final prefs = await SharedPreferences.getInstance();

  // ✅ Tambahkan ini untuk memeriksa apakah sprint sedang aktif
  final sprintId = prefs.getInt('sprintId');
  if (sprintId == null) {
    print('[ALARM_MANAGER]  Tidak ada sprintId aktif, notifikasi dibatalkan');
    return;
  }

  final notif = FlutterLocalNotificationsPlugin();

  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('ic_bg_service_small'),
  );
  await notif.initialize(initSettings);

  final now = DateTime.now().millisecondsSinceEpoch;
  final lastLaporan = prefs.getInt('last_report_time') ?? 0;
  final lastNotif = prefs.getInt('lastNotifTimestamp') ?? 0;

  if (now - lastLaporan > 3 * 60 * 1000 && now - lastNotif > 3 * 60 * 1000) {
    await notif.show(
      999,
      'Belum Isi Laporan',
      'Anda belum mengisi laporan dalam 3 menit terakhir.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Notifikasi Laporan',
          channelDescription: 'Peringatan untuk mengisi laporan',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_bg_service_small',
        ),
      ),
      payload: 'laporan',
    );
    await prefs.setInt('lastNotifTimestamp', now);
    print('[ALARM_MANAGER]  Notifikasi dikirim via alarm manager');
  } else {
    print('[ALARM_MANAGER]  Tidak perlu kirim notifikasi');
  }
}
