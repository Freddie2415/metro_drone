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

  static final List<Subdivision> subdivisionsForWholeNote = [
    Subdivision(
      name: "Whole Note",
      description: "One whole note spanning the entire duration",
      restPattern: [true],
      durationPattern: [1.0],
    ),
    Subdivision(
      name: "2 Half Notes",
      description: "Two half notes dividing the whole note",
      restPattern: [true, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "Half Rest, Half Note",
      description: "First half silent, second half played",
      restPattern: [false, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "4 Quarter Notes",
      description: "Four quarter notes evenly dividing the whole note",
      restPattern: [true, true, true, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "Quarter Rest, Quarter Note, Quarter Rest, Quarter Note",
      description: "Alternating rests and notes for four quarters",
      restPattern: [false, true, false, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "2 Quarter Notes, 1 Half Note",
      description: "Two quarter notes followed by one half note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.25, 0.5],
    ),
    Subdivision(
      name: "1 Half Note, 2 Quarter Notes",
      description: "One half note followed by two quarter notes",
      restPattern: [true, true, true],
      durationPattern: [0.5, 0.25, 0.25],
    ),
    Subdivision(
      name: "Dotted Half Note, Quarter Note",
      description: "Dotted half note followed by one quarter note",
      restPattern: [true, true],
      durationPattern: [0.75, 0.25],
    ),
    Subdivision(
      name: "Quarter Note, Dotted Half Note",
      description: "One quarter note followed by a dotted half note",
      restPattern: [true, true],
      durationPattern: [0.25, 0.75],
    ),
    Subdivision(
      name: "Quarter Note, Half Note, Quarter Note",
      description: "Quarter note, half note, and another quarter note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.5, 0.25],
    ),
    Subdivision(
      name: "3 Triplet Half Notes",
      description: "Three evenly divided triplet half notes",
      restPattern: [true, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Half Rest, 2 Triplet Half Notes",
      description: "First triplet rest, followed by two triplet half notes",
      restPattern: [false, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Half Note, Rest, Triplet Half Note",
      description:
          "Triplet half note, followed by rest, then another triplet half note",
      restPattern: [true, false, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "2 Triplet Half Notes, Triplet Half Rest",
      description: "Two triplet half notes, then one triplet rest",
      restPattern: [true, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Half Rest, Triplet Half Note, Triplet Half Rest",
      description: "Triplet rest, triplet note, and another triplet rest",
      restPattern: [false, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Quintuplet Half Notes",
      description: "Five evenly divided quintuplet half notes",
      restPattern: [true, true, true, true, true],
      durationPattern: [0.2, 0.2, 0.2, 0.2, 0.2],
    ),
    Subdivision(
      name: "Septuplet Half Notes",
      description: "Seven evenly divided septuplet half notes",
      restPattern: [true, true, true, true, true, true, true],
      durationPattern: [1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7],
    ),
  ];

  static final  List<Subdivision> subdivisionsForHalfNote = [
    Subdivision(
      name: "Half Note",
      description: "One half note spanning the entire duration",
      restPattern: [true],
      durationPattern: [1.0],
    ),
    Subdivision(
      name: "2 Quarter Notes",
      description: "Two quarter notes dividing the half note",
      restPattern: [true, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "Quarter Rest, Quarter Note",
      description: "First quarter silent, second quarter played",
      restPattern: [false, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "4 Eighth Notes",
      description: "Four eighth notes evenly dividing the half note",
      restPattern: [true, true, true, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "Eighth Rest, Eighth Note, Eighth Rest, Eighth Note",
      description: "Alternating rests and notes for eighths",
      restPattern: [false, true, false, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "2 Eighth Notes, 1 Quarter Note",
      description: "Two eighth notes followed by one quarter note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.25, 0.5],
    ),
    Subdivision(
      name: "1 Quarter Note, 2 Eighth Notes",
      description: "One quarter note followed by two eighth notes",
      restPattern: [true, true, true],
      durationPattern: [0.5, 0.25, 0.25],
    ),
    Subdivision(
      name: "Dotted Quarter Note, Eighth Note",
      description: "Dotted quarter note followed by one eighth note",
      restPattern: [true, true],
      durationPattern: [0.75, 0.25],
    ),
    Subdivision(
      name: "Eighth Note, Dotted Quarter Note",
      description: "One eighth note followed by a dotted quarter note",
      restPattern: [true, true],
      durationPattern: [0.25, 0.75],
    ),
    Subdivision(
      name: "Eighth Note, Quarter Note, Eighth Note",
      description: "Eighth note, quarter note, and another eighth note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.5, 0.25],
    ),
    Subdivision(
      name: "3 Triplet Quarter Notes",
      description: "Three evenly divided triplet quarter notes",
      restPattern: [true, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Quarter Note Rest, 2 Triplet Quarter Notes",
      description: "First triplet rest, followed by two triplet quarter notes",
      restPattern: [false, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Quarter Note, Rest, Triplet Quarter Note",
      description:
          "Triplet quarter note, followed by rest, then another triplet quarter note",
      restPattern: [true, false, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "2 Triplet Quarter Notes, Triplet Quarter Note Rest",
      description: "Two triplet quarter notes, then one triplet rest",
      restPattern: [true, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name:
          "Triplet Quarter Note Rest, Triplet Quarter Note, Triplet Quarter Note Rest",
      description: "Triplet rest, triplet note, and another triplet rest",
      restPattern: [false, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Quintuplet Quarter Notes",
      description: "Five evenly divided quintuplet quarter notes",
      restPattern: [true, true, true, true, true],
      durationPattern: [0.2, 0.2, 0.2, 0.2, 0.2],
    ),
    Subdivision(
      name: "Septuplet Quarter Notes",
      description: "Seven evenly divided septuplet quarter notes",
      restPattern: [true, true, true, true, true, true, true],
      durationPattern: [1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7],
    ),
  ];

  static final List<Subdivision> subdivisionsForQuarterNote = [
    Subdivision(
      name: "Quarter Note",
      description: "One quarter note spanning the entire duration",
      restPattern: [true],
      durationPattern: [1.0],
    ),
    Subdivision(
      name: "2 Eighth Notes",
      description: "Two eighth notes dividing the quarter note",
      restPattern: [true, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "Eighth Rest, Eighth Note",
      description: "First eighth silent, second eighth played",
      restPattern: [false, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "4 Sixteenth Notes",
      description: "Four sixteenth notes evenly dividing the quarter note",
      restPattern: [true, true, true, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "Sixteenth Rest, Sixteenth Note, Sixteenth Rest, Sixteenth Note",
      description: "Alternating rests and notes for sixteenth notes",
      restPattern: [false, true, false, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "2 Sixteenth Notes, 1 Eighth Note",
      description: "Two sixteenth notes followed by one eighth note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.25, 0.5],
    ),
    Subdivision(
      name: "1 Eighth Note, 2 Sixteenth Notes",
      description: "One eighth note followed by two sixteenth notes",
      restPattern: [true, true, true],
      durationPattern: [0.5, 0.25, 0.25],
    ),
    Subdivision(
      name: "Dotted Eighth Note, Sixteenth Note",
      description: "Dotted eighth note followed by one sixteenth note",
      restPattern: [true, true],
      durationPattern: [0.75, 0.25],
    ),
    Subdivision(
      name: "Sixteenth Note, Dotted Eighth Note",
      description: "One sixteenth note followed by a dotted eighth note",
      restPattern: [true, true],
      durationPattern: [0.25, 0.75],
    ),
    Subdivision(
      name: "Sixteenth Note, Eighth Note, Sixteenth Note",
      description: "Sixteenth note, eighth note, and another sixteenth note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.5, 0.25],
    ),
    Subdivision(
      name: "3 Triplet Eighth Notes",
      description: "Three evenly divided triplet eighth notes",
      restPattern: [true, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Eighth Note Rest, 2 Triplet Eighth Notes",
      description: "First triplet rest, followed by two triplet eighth notes",
      restPattern: [false, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Eighth Note, Rest, Triplet Eighth Note",
      description: "Triplet eighth note, followed by rest, then another triplet eighth note",
      restPattern: [true, false, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "2 Triplet Eighth Notes, Triplet Eighth Note Rest",
      description: "Two triplet eighth notes, then one triplet rest",
      restPattern: [true, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Eighth Note Rest, Triplet Eighth Note, Triplet Eighth Note Rest",
      description: "Triplet rest, triplet note, and another triplet rest",
      restPattern: [false, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Quintuplet Eighth Notes",
      description: "Five evenly divided quintuplet eighth notes",
      restPattern: [true, true, true, true, true],
      durationPattern: [0.2, 0.2, 0.2, 0.2, 0.2],
    ),
    Subdivision(
      name: "Septuplet Eighth Notes",
      description: "Seven evenly divided septuplet eighth notes",
      restPattern: [true, true, true, true, true, true, true],
      durationPattern: [1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7],
    ),
  ];

  static final List<Subdivision> subdivisionsForEighthNote = [
    Subdivision(
      name: "Eighth Note",
      description: "One eighth note spanning the entire duration",
      restPattern: [true],
      durationPattern: [1.0],
    ),
    Subdivision(
      name: "2 Sixteenth Notes",
      description: "Two sixteenth notes dividing the eighth note",
      restPattern: [true, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "Sixteenth Rest, Sixteenth Note",
      description: "First sixteenth silent, second sixteenth played",
      restPattern: [false, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "4 Thirty-Second Notes",
      description: "Four thirty-second notes evenly dividing the eighth note",
      restPattern: [true, true, true, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "Thirty-Second Rest, Thirty-Second Note, Thirty-Second Rest, Thirty-Second Note",
      description: "Alternating rests and notes for thirty-second notes",
      restPattern: [false, true, false, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "2 Thirty-Second Notes, 1 Sixteenth Note",
      description: "Two thirty-second notes followed by one sixteenth note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.25, 0.5],
    ),
    Subdivision(
      name: "1 Sixteenth Note, 2 Thirty-Second Notes",
      description: "One sixteenth note followed by two thirty-second notes",
      restPattern: [true, true, true],
      durationPattern: [0.5, 0.25, 0.25],
    ),
    Subdivision(
      name: "Dotted Sixteenth Note, Thirty-Second Note",
      description: "Dotted sixteenth note followed by one thirty-second note",
      restPattern: [true, true],
      durationPattern: [0.75, 0.25],
    ),
    Subdivision(
      name: "Thirty-Second Note, Dotted Sixteenth Note",
      description: "One thirty-second note followed by a dotted sixteenth note",
      restPattern: [true, true],
      durationPattern: [0.25, 0.75],
    ),
    Subdivision(
      name: "Thirty-Second Note, Sixteenth Note, Thirty-Second Note",
      description: "Thirty-second note, sixteenth note, and another thirty-second note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.5, 0.25],
    ),
    Subdivision(
      name: "3 Triplet Sixteenth Notes",
      description: "Three evenly divided triplet sixteenth notes",
      restPattern: [true, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Sixteenth Note Rest, 2 Triplet Sixteenth Notes",
      description: "First triplet rest, followed by two triplet sixteenth notes",
      restPattern: [false, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Sixteenth Note, Rest, Triplet Sixteenth Note",
      description: "Triplet sixteenth note, followed by rest, then another triplet sixteenth note",
      restPattern: [true, false, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "2 Triplet Sixteenth Notes, Triplet Sixteenth Note Rest",
      description: "Two triplet sixteenth notes, then one triplet rest",
      restPattern: [true, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Sixteenth Note Rest, Triplet Sixteenth Note, Triplet Sixteenth Note Rest",
      description: "Triplet rest, triplet note, and another triplet rest",
      restPattern: [false, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Quintuplet Sixteenth Notes",
      description: "Five evenly divided quintuplet sixteenth notes",
      restPattern: [true, true, true, true, true],
      durationPattern: [0.2, 0.2, 0.2, 0.2, 0.2],
    ),
    Subdivision(
      name: "Septuplet Sixteenth Notes",
      description: "Seven evenly divided septuplet sixteenth notes",
      restPattern: [true, true, true, true, true, true, true],
      durationPattern: [1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7],
    ),
  ];

  static final List<Subdivision> subdivisionsForSixteenthNote = [
    Subdivision(
      name: "Sixteenth Note",
      description: "One sixteenth note spanning the entire duration",
      restPattern: [true],
      durationPattern: [1.0],
    ),
    Subdivision(
      name: "2 Thirty-Second Notes",
      description: "Two thirty-second notes dividing the sixteenth note",
      restPattern: [true, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "Thirty-Second Rest, Thirty-Second Note",
      description: "First thirty-second silent, second thirty-second played",
      restPattern: [false, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "4 Sixty-Fourth Notes",
      description: "Four sixty-fourth notes evenly dividing the sixteenth note",
      restPattern: [true, true, true, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "Sixty-Fourth Rest, Sixty-Fourth Note, Sixty-Fourth Rest, Sixty-Fourth Note",
      description: "Alternating rests and notes for sixty-fourth notes",
      restPattern: [false, true, false, true],
      durationPattern: [0.25, 0.25, 0.25, 0.25],
    ),
    Subdivision(
      name: "2 Sixty-Fourth Notes, 1 Thirty-Second Note",
      description: "Two sixty-fourth notes followed by one thirty-second note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.25, 0.5],
    ),
    Subdivision(
      name: "1 Thirty-Second Note, 2 Sixty-Fourth Notes",
      description: "One thirty-second note followed by two sixty-fourth notes",
      restPattern: [true, true, true],
      durationPattern: [0.5, 0.25, 0.25],
    ),
    Subdivision(
      name: "Dotted Thirty-Second Note, Sixty-Fourth Note",
      description: "Dotted thirty-second note followed by one sixty-fourth note",
      restPattern: [true, true],
      durationPattern: [0.75, 0.25],
    ),
    Subdivision(
      name: "Sixty-Fourth Note, Dotted Thirty-Second Note",
      description: "One sixty-fourth note followed by a dotted thirty-second note",
      restPattern: [true, true],
      durationPattern: [0.25, 0.75],
    ),
    Subdivision(
      name: "Sixty-Fourth Note, Thirty-Second Note, Sixty-Fourth Note",
      description: "Sixty-fourth note, thirty-second note, and another sixty-fourth note",
      restPattern: [true, true, true],
      durationPattern: [0.25, 0.5, 0.25],
    ),
    Subdivision(
      name: "3 Triplet Thirty-Second Notes",
      description: "Three evenly divided triplet thirty-second notes",
      restPattern: [true, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Thirty-Second Note Rest, 2 Triplet Thirty-Second Notes",
      description: "First triplet rest, followed by two triplet thirty-second notes",
      restPattern: [false, true, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Thirty-Second Note, Rest, Triplet Thirty-Second Note",
      description: "Triplet thirty-second note, followed by rest, then another triplet thirty-second note",
      restPattern: [true, false, true],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "2 Triplet Thirty-Second Notes, Triplet Thirty-Second Note Rest",
      description: "Two triplet thirty-second notes, then one triplet rest",
      restPattern: [true, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Triplet Thirty-Second Note Rest, Triplet Thirty-Second Note, Triplet Thirty-Second Note Rest",
      description: "Triplet rest, triplet note, and another triplet rest",
      restPattern: [false, true, false],
      durationPattern: [0.333, 0.333, 0.333],
    ),
    Subdivision(
      name: "Quintuplet Thirty-Second Notes",
      description: "Five evenly divided quintuplet thirty-second notes",
      restPattern: [true, true, true, true, true],
      durationPattern: [0.2, 0.2, 0.2, 0.2, 0.2],
    ),
    Subdivision(
      name: "Septuplet Thirty-Second Notes",
      description: "Seven evenly divided septuplet thirty-second notes",
      restPattern: [true, true, true, true, true, true, true],
      durationPattern: [1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7, 1 / 7],
    ),
  ];

}
