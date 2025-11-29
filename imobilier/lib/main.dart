import 'package:flutter/material.dart';
import './pages/map_page.dart';
import './pages/profile.dart';
import './pages/about.dart';
import './pages/signup.dart';

void main() {
  runApp(const MyApp());
}

// Simule l'état de connexion
bool isLoggedIn = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Immobilier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      initialRoute: isLoggedIn ? "/home" : "/signup",
      routes: {
        "/signup": (context) => const SignupPage(),
        "/home": (context) => const MapPageWrapper(),
        "/profile": (context) => ProfilePage(user: {}),
        "/map": (context) => const MapPageWrapper(),
        "/about": (context) => AboutPage(user: {}),
      },
    );
  }
}

class MapPageWrapper extends StatelessWidget {
  const MapPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, "/signup"));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MapPage(user: {});
  }
}
