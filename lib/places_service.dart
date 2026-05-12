import 'dart:convert';
import 'package:http/http.dart' as http;
import 'place_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RestroomService {
  final String apiKey = dotenv.env['GOOGLE_KEY'] ?? "";

  Future<List<RestroomLocal>> findRestrooms(
    double lat,
    double lng, {
    double radius = 500.0,
  }) async {
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:searchNearby',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.location,places.editorialSummary,places.restroom,places.accessibilityOptions,places.primaryType,places.regularOpeningHours',
      },
      body: jsonEncode({
        'includedTypes': [
          'restaurant',
          'gas_station',
          'cafe',
          'primary_school',
          'university',
        ],
        'locationRestriction': {
          'circle': {
            'center': {'latitude': lat, 'longitude': lng},
            'radius': radius,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> results = json['places'] ?? [];
      return results.map((json) => RestroomLocal.fromJson(json)).toList();
    } else {
      print('Error HTTP: ${response.statusCode} - ${response.body}');
      throw Exception("Error al cargar los baños");
    }
  }
}
