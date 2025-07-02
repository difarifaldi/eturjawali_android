import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Ambil data dari shared preferences
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
