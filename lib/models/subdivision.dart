class Subdivision {
  final String name;
  final String description;
  final List<bool> restPattern;
  final List<double> durationPattern;

  Subdivision({
    required this.name,
    required this.description,
    required this.restPattern,
    required this.durationPattern,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "restPattern": restPattern,
      "durationPattern": durationPattern,
    };
  }

  factory Subdivision.fromMap(Map<String, dynamic> map) {
    return Subdivision(
      name: map['name'] as String,
      description: map['description'] as String,
      restPattern: map['restPattern'] as List<bool>,
      durationPattern: map['durationPattern'] as List<double>,
    );
  }

  @override
  String toString() {
    return name;
  }
}
