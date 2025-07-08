import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
    await requestLocationPermission();
    await _handleLocationPermission(); // ⬅️ Minta izin lokasi
    await openAutostartSettings();
    await openBatteryOptimizationSettings();
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Opsional: beri jeda animasi
    await checkLoginStatus(); // ⬅️ Setelah dapat izin, lanjut cek login
  }

  Future<void> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showAlertDialog(
        'Layanan lokasi tidak aktif. Aktifkan terlebih dahulu.',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _showAlertDialog(
          'Izin lokasi ditolak. Aplikasi tidak dapat berjalan tanpa izin ini.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showAlertDialog(
        'Izin lokasi ditolak permanen. Harap izinkan dari pengaturan.',
      );
      return;
    }

    print('✅ Izin lokasi diberikan');
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

  Future<void> _showAlertDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izin Lokasi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
