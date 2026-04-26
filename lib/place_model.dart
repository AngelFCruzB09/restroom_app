class RestroomLocal {
  final String name;
  final String id;
  final String description;
  final double lat;
  final double lng;
  final bool tienerestroom;
  final bool esAccesible;

  RestroomLocal({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.tienerestroom,
    required this.esAccesible,
  });
  factory RestroomLocal.fromJson(Map<String, dynamic> json) {
    return RestroomLocal(
      id: json['id'] ?? '',
      name: json['displayName']?['text'] ?? 'Sin nombre',
      description: json['editorialSummary']?['text'] ?? 'Sin descripción',
      lat: json['location']?['latitude'] ?? 0.0,
      lng: json['location']?['longitude'] ?? 0.0,
      tienerestroom: json['restroom'] ?? false,
      esAccesible: json['accessibilityOptions']?['wheelchairAccessibleRestroom'] ?? false,
    );
  }
}
