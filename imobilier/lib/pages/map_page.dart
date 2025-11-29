import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/app_drawer.dart';
import 'about.dart';
import 'profile.dart';

class MapPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const MapPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map – Biens Immobiliers"),
        backgroundColor: Colors.orange,
      ),
      drawer: AppDrawer(
        user: user,
        onItemSelected: (index) {
          Navigator.pop(context); 
          switch (index) {
            case 0: 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MapPage(user: user)),
              );
              break;
            case 1: 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
              );
              break;
            case 2: 
              Navigator.pushNamed(context, "/settings", arguments: user);
              break;
            case 3: 
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MapPage(user: user)),
        );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutPage(user: user)),
              );
              break;
            case 5:
              Navigator.pushReplacementNamed(context, "/signup");
              break;
          }
        },
      ),

      body: FlutterMap(
        options: MapOptions(
          center: LatLng(36.8065, 10.1815), 
          zoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(36.8065, 10.1815),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
