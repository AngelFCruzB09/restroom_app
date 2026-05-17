import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:restroom_app/model/place_model.dart';
import 'package:restroom_app/services/places_service.dart';
import 'package:restroom_app/services/location_service.dart';
import 'package:restroom_app/services/auth_service.dart';
import 'package:restroom_app/services/review_service.dart';
import 'package:restroom_app/screens/add_review_screen.dart';
import 'package:restroom_app/screens/login_screen.dart';
import 'package:rive/rive.dart';

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
      backgroundColor: _isLoading ? Colors.white : null,
      body: _isLoading
          ? Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: RiveAnimation.asset('assets/69-98-loading.riv'),
              ),
            )
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
            color: bano.tienerestroom ? Colors.blue : Colors.red,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: _RestroomBottomSheet(bano: bano),
        );
      },
    );
  }
}

class _RestroomBottomSheet extends StatefulWidget {
  final RestroomLocal bano;

  const _RestroomBottomSheet({required this.bano});

  @override
  State<_RestroomBottomSheet> createState() => _RestroomBottomSheetState();
}

class _RestroomBottomSheetState extends State<_RestroomBottomSheet> {
  bool _horariosExpandidos = false;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    try {
      final resenas = await ReviewService().obtenerResenas(widget.bano.id);
      if (mounted) {
        setState(() {
          _reviews = resenas;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar reseñas: $e');
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  String _traducirTipo(String? tipo) {
    if (tipo == null) return "Lugar";
    switch (tipo) {
      case 'restaurant':
        return 'Restaurante';
      case 'gas_station':
        return 'Gasolinera';
      case 'cafe':
        return 'Cafetería';
      case 'primary_school':
        return 'Escuela Primaria';
      case 'university':
        return 'Universidad';
      default:
        return tipo.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bano = widget.bano;
    final tipoLugarStr = _traducirTipo(bano.tipoLugar);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          // Indicador de arrastre
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Encabezado
          Text(
            bano.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            tipoLugarStr,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),

          // Disponibilidad de baño
          Row(
            children: [
              Icon(
                bano.tienerestroom ? Icons.check_circle : Icons.cancel,
                color: bano.tienerestroom ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  bano.tienerestroom
                      ? "Tiene baños disponibles"
                      : "No tiene baños",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (bano.description.isNotEmpty &&
              bano.description != 'Sin descripción') ...[
            const SizedBox(height: 10),
            Text(
              bano.description,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],

          const Divider(height: 30),

          // Horarios
          if (bano.horarios != null && bano.horarios!.isNotEmpty) ...[
            InkWell(
              onTap: () {
                setState(() {
                  _horariosExpandidos = !_horariosExpandidos;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blueGrey[700]),
                    const SizedBox(width: 10),
                    Text(
                      bano.abiertoAhora == true
                          ? "Abierto ahora"
                          : (bano.abiertoAhora == false
                                ? "Cerrado ahora"
                                : "Horarios"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: bano.abiertoAhora == true
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _horariosExpandidos
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
            if (_horariosExpandidos) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 34.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bano.horarios!
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Text(h, style: const TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const Divider(height: 30),
          ],

          // Reseñas
          const Text(
            "Reseñas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _isLoadingReviews
              ? const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
              : _reviews.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(Icons.star_border,
                                color: Colors.orange, size: 30),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sé el primero en opinar",
                          style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        ),
                      ],
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final resena = _reviews[index];
                        final rating = resena['rating'] as int? ?? 0;
                        final comment = resena['comment']?.toString() ?? '';
                        final profile = resena['profiles'];
                        final username = (profile is Map && profile['username'] != null)
                            ? profile['username']
                            : 'Usuario anónimo';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: Colors.grey[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.blue[100],
                                      child: Icon(Icons.person,
                                          size: 18, color: Colors.blue[800]),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        username,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (starIndex) => Icon(
                                          starIndex < rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (comment.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    comment,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[800]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 20),

          // Botón Escribir Reseña
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (AuthService().isAuthenticated) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddReviewScreen(bano: bano),
                    ),
                  );
                  _cargarResenas();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Aviso"),
                        content: const Text(
                          "Debes iniciar sesión para escribir una reseña.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text("Iniciar sesión"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              icon: const Icon(Icons.rate_review),
              label: const Text(
                "Escribir una reseña",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
