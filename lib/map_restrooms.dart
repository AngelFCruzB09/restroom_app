import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:restroom_app/place_model.dart';
import 'package:restroom_app/places_service.dart';
import 'package:restroom_app/location_service.dart';

class MapRestrooms extends StatefulWidget {
  const MapRestrooms({super.key});

  @override
  State<MapRestrooms> createState() => _MapRestroomsState();
}

class _MapRestroomsState extends State<MapRestrooms> {
  static const LatLng _centerMerida = LatLng(
    20.9705938613977,
    -89.62029365893679,
  );
  static const double _initialZoom = 15.0;

  LatLng _currentPosition = _centerMerida;
  List<RestroomLocal> _listaBanos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarBanos();
  }

  Future<void> _cargarBanos() async {
    try {
      try {
        final position = await LocationService().determinarPosicion();
        _currentPosition = LatLng(position.latitude, position.longitude);
      } catch (e) {
        debugPrint('No se pudo obtener la ubicación o permisos denegados: $e');
      }

      final lista = await RestroomService().findRestrooms(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      if (mounted) {
        setState(() {
          _listaBanos = lista;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar los baños: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Baños'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMap(),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: _initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.restroom_app',
        ),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = _listaBanos.map((bano) {
      return Marker(
        point: LatLng(bano.lat, bano.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _mostrarDetalles(context, bano),
          child: Icon(
            Icons.wc,
            color: bano.esAccesible ? Colors.blue : Colors.red,
            size: 40,
          ),
        ),
      );
    }).toList();
    markers.add(
      Marker(
        point: _currentPosition,
        width: 40,
        height: 40,
        child: Icon(Icons.circle, color: Colors.blue, size: 30),
      ),
    );
    return markers;
  }

  void _mostrarDetalles(BuildContext context, RestroomLocal bano) {
    showDialog(
      context: context,
      builder: (context) => _RestroomDetailDialog(bano: bano),
    );
  }
}

class _RestroomDetailDialog extends StatelessWidget {
  final RestroomLocal bano;

  const _RestroomDetailDialog({required this.bano});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(bano.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(bano.description),
          const SizedBox(height: 10),
          Text(
            bano.tienerestroom ? "Tiene baños" : "No tiene baños",
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
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
