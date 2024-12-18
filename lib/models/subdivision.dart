import 'package:collection/collection.dart';

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
      restPattern: (map['restPattern'] as List)
          .map((e) => bool.parse(e.toString()))
          .toList(),
      durationPattern: (map['durationPattern'] as List)
          .map((e) => double.parse(e.toString()))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subdivision &&
        other.name == name &&
        other.description == description &&
        const ListEquality().equals(other.restPattern, restPattern) &&
        const ListEquality().equals(other.durationPattern, durationPattern);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        const ListEquality().hash(restPattern) ^
        const ListEquality().hash(durationPattern);
  }

  @override
  String toString() {
    return name;
  }
}
