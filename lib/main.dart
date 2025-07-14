import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth/login_page.dart';
import 'pages/home.dart';
import 'pages/splash_page.dart';
import 'pages/laporan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../services/background_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  print("🔥 MAIN isolate jalan");
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload == 'laporan') {
        final prefs = await SharedPreferences.getInstance();
        final isTimerRunning = prefs.getBool('isTimerRunning') ?? false;

        final startStr = prefs.getString('startTime');
        if (startStr != null) {
          final startTime = DateTime.tryParse(startStr);
          final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

          if (startTime != null) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => LaporanPage(
                  startTime: startTime,
                  isTimerRunning: isTimerRunning,
                  currentTime: currentTime,
                ),
              ),
            );
          }
        }
      }
    },
  );

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
      navigatorKey: navigatorKey,
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
