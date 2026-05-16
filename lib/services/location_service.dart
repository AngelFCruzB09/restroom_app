import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> determinarPosicion() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación han sido denegados');
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return Future.error(
        'Los permisos de ubicación han sido denegados permanentemente',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
