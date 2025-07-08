import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'auth/login_page.dart';
import 'pages/home.dart';
import 'pages/splash_page.dart';

import '../services/background_service.dart';

void main() async {
  print("🔥 MAIN isolate jalan");
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  WakelockPlus.enable();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('[FLUTTER ERROR] ${details.exception}');
    print('[STACK] ${details.stack}');
  };

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
