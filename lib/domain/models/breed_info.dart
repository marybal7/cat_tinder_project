class BreedInfo {
  final String name;
  final String origin;
  final String temperament;
  final String description;
  final String lifespan;

  BreedInfo({
    required this.name,
    required this.origin,
    required this.temperament,
    required this.description,
    required this.lifespan,
  });

  factory BreedInfo.fromJson(Map<String, dynamic> json) {
    return BreedInfo(
      name: json['name'],
      origin: json['origin'],
      temperament: json['temperament'],
      description: json['description'],
      lifespan: json['life_span'],
    );
  }
}
