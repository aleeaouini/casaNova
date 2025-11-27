import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map – Biens Immobiliers"),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(36.8065, 10.1815), // Tunis example
          initialZoom: 13,
        ),
        children: [
          // OpenStreetMap Layer
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),

          // Example Marker
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(36.8065, 10.1815),
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
