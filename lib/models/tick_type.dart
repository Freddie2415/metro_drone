enum TickType {
  silence,
  regular,
  accent,
  strongAccent;

  static TickType? fromString(String value) {
    return TickType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TickType.regular,
    );
  }

  static List<TickType> fromList(List<String> values) {
    return values
        .map((value) => TickType.fromString(value))
        .whereType<TickType>()
        .toList();
  }

  // Конвертация TickType в строку
  String toStringValue() {
    return toString().split('.').last;
  }
}
