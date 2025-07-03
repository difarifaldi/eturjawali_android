import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'auth/login_page.dart';
import 'pages/home.dart';
import 'pages/splash_page.dart';

Future<void> handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Periksa apakah layanan lokasi diaktifkan
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Layanan lokasi tidak aktif.');
    return;
  }

  // Periksa dan minta izin
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Izin lokasi ditolak.');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Izin lokasi ditolak permanen.');
    return;
  }

  print('Izin lokasi diberikan.');
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Eturjawali',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // ⬇ ganti jadi SplashPage
      home: const SplashPage(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return HomePage(
            userId: args['userId'],
            username: args['username'],
            unitId: args['unitId'],
            namaLengkap: args['nama'],
            kesatuanNama: args['kesatuan_nama'],
            email: args['email'],
            noMobile: args['no_mobile'],
            photo: args['photo'],
          );
        },
      },
    );
  }
}
