import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'home.dart';
import '../services/background_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await handleLocationPermission(); // ⬅️ Tetap minta izin lokasi dulu

    await Future.delayed(const Duration(milliseconds: 500));

    await showConfirmDialog(
      context,
      title: 'Izinkan Alarm Presisi',
      content:
          'Untuk memastikan pengingat berjalan tepat waktu, aplikasi butuh izin alarm presisi. Buka pengaturan?',
      onConfirm: openExactAlarmPermissionSettings,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    await showConfirmDialog(
      context,
      title: 'Izinkan Autostart',
      content:
          'Agar aplikasi tetap aktif di latar belakang, izinkan aplikasi berjalan otomatis saat perangkat dinyalakan.',
      onConfirm: openAutostartSettings,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    await showConfirmDialog(
      context,
      title: 'Nonaktifkan Optimasi Baterai',
      content:
          'Optimasi baterai bisa menghentikan tracking. Izinkan aplikasi berjalan tanpa pembatasan baterai.',
      onConfirm: openBatteryOptimizationSettings,
    );

    await Future.delayed(const Duration(seconds: 1));
    await checkLoginStatus(); // ⬅️ Lanjut login
  }

  Future<void> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lewati'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: const Text('Buka'),
          ),
        ],
      ),
    );
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username');
      final unitId = prefs.getInt('unitId');
      final nama = prefs.getString('nama');
      final kesatuanNama = prefs.getString('kesatuan_nama');
      final email = prefs.getString('email');
      final noMobile = prefs.getString('no_mobile');
      final photo = prefs.getString('photo');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            userId: userId!,
            username: username ?? '',
            unitId: unitId ?? 0,
            namaLengkap: nama ?? '',
            kesatuanNama: kesatuanNama ?? '',
            email: email ?? '',
            noMobile: noMobile ?? '',
            photo: photo ?? '',
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Menyiapkan aplikasi...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
