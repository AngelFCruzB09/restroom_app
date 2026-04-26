import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:restroom_app/place_model.dart';
import 'package:restroom_app/places_service.dart';

class MapRestrooms extends StatefulWidget {
  const MapRestrooms({super.key});

  @override
  State<MapRestrooms> createState() => _MapRestroomsState();
}

class _MapRestroomsState extends State<MapRestrooms> {
  final LatLng _centerMerida = LatLng(20.9705938613977, -89.62029365893679);
  List<RestroomLocal> _listaBanos = [];

  @override
  void initState() {
    super.initState();
    _cargarBanos();
  }

  Future<void> _cargarBanos() async {
    try {
      final lista = await RestroomService().findRestrooms(
        _centerMerida.latitude,
        _centerMerida.longitude,
      );
      setState(() {
        _listaBanos = lista;
      });
    } catch (e) {
      print('Error al cargar los baños: $e');
    }
  }

  void _mostrarDetalles(RestroomLocal bano) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bano.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(bano.description),
            SizedBox(height: 10),
            Text(
              bano.tienerestroom ? "Tiene baños " : "No tiene baños ",
              style: TextStyle(
                color: bano.tienerestroom ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar"),
          ),
        ],
      ),
    );
  }

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
          MarkerLayer(
            markers: _listaBanos
                .map(
                  (bano) => Marker(
                    point: LatLng(bano.lat, bano.lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _mostrarDetalles(bano),
                      child: Icon(
                        Icons.wc,
                        color: bano.esAccesible ? Colors.blue : Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
