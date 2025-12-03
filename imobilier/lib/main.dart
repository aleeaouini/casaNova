import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/map_page.dart';
import './pages/profile.dart';
import './pages/about.dart';
import './pages/signup.dart';
import './pages/landing.dart';
import 'pages/home.dart';

bool isLoggedIn = false; // Simulated login status

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load onboarding status
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenLanding = prefs.getBool('hasSeenLanding') ?? false;

  runApp(MyApp(hasSeenLanding: hasSeenLanding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenLanding;

  const MyApp({super.key, required this.hasSeenLanding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Immobilier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),

      // Decide start route based on onboarding and login status
      initialRoute: hasSeenLanding
          ? (isLoggedIn ? "/home" : "/signup")
          : "/landing1",

      routes: {

        "/landing1": (context) => const OnboardingScreen(),
        "/signup": (context) => const SignupPage(),
         '/home': (context) => const HomeScreen(user: {},),
        "/profile": (context) => ProfilePage(user: {}),
        "/map": (context) => const MapPageWrapper(),
        "/about": (context) => AboutPage(user: {}),
      },
    );
  }
}

// Wrapper ensuring user is logged in before accessing map
class MapPageWrapper extends StatelessWidget {
  const MapPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      // Redirect to signup if user is not logged in
      Future.microtask(
          () => Navigator.pushReplacementNamed(context, "/signup"));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MapPage(user: {});
  }
}
