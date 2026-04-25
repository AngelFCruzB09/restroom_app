import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapRestrooms extends StatefulWidget {
  const MapRestrooms({super.key});

  @override
  State<MapRestrooms> createState() => _MapRestroomsState();
}

class _MapRestroomsState extends State<MapRestrooms> {
  final LatLng _centerMerida = LatLng(20.9705938613977, -89.62029365893679);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Baños'),
        backgroundColor: Colors.blue,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: _centerMerida, initialZoom: 12),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.restroom_app',
          ),
        ],
      ),
    );
  }
}
