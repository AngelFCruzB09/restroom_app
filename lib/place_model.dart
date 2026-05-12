class RestroomLocal {
  final String name;
  final String id;
  final String description;
  final double lat;
  final double lng;
  final bool tienerestroom;
  final bool esAccesible;
  final String? tipoLugar;
  final bool? abiertoAhora;
  final List<String>? horarios;

  RestroomLocal({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.tienerestroom,
    required this.esAccesible,
    this.tipoLugar,
    this.abiertoAhora,
    this.horarios,
  });
  factory RestroomLocal.fromJson(Map<String, dynamic> json) {
    List<String>? horariosParsed;
    if (json['regularOpeningHours'] != null && json['regularOpeningHours']['weekdayDescriptions'] != null) {
      horariosParsed = List<String>.from(json['regularOpeningHours']['weekdayDescriptions']);
    }

    return RestroomLocal(
      id: json['id'] ?? '',
      name: json['displayName']?['text'] ?? 'Sin nombre',
      description: json['editorialSummary']?['text'] ?? 'Sin descripción',
      lat: json['location']?['latitude'] ?? 0.0,
      lng: json['location']?['longitude'] ?? 0.0,
      tienerestroom: json['restroom'] ?? false,
      esAccesible: json['accessibilityOptions']?['wheelchairAccessibleRestroom'] ?? false,
      tipoLugar: json['primaryType'],
      abiertoAhora: json['regularOpeningHours']?['openNow'],
      horarios: horariosParsed,
    );
  }
}
