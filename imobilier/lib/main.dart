import 'package:flutter/material.dart';
import 'package:imobilier/pages/signup.dart';
import 'package:imobilier/pages/map_page.dart';   

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Immobilier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),

      /// First page when app opens
      home: const SignupPage(),

      /// App Navigation Routes
      routes: {
        "/map": (context) => const MapPage(),   
      },
    );
  }
}
