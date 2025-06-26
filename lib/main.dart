import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'pages/home.dart';

void main() {
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
      initialRoute: '/login',
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
          );
        },
      },
    );
  }
}
