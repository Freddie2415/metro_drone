import 'dart:async';

import 'metro_drone_platform_interface.dart';

class MetroDrone {
  bool _isPlaying = false;
  int _bpm = 120;
  int _timeSignatureNumerator = 4;
  int _timeSignatureDenominator = 4;
  int _currentTick = 0;
  int _currentSubdivisionTick = 0;
  List<TickType> _tickTypes = List.generate(4, (_) => TickType.regular);
  List<Subdivision> _subdivisions = [
    Subdivision(
      name: "Quarter Notes",
      description: "One quarter note per beat",
      restPattern: [true],
      durationPattern: [1.0],
    ),
    Subdivision(
      name: "Eighth Notes",
      description: "Two eighth notes",
      restPattern: [true, true],
      durationPattern: [0.5, 0.5],
    ),
    Subdivision(
      name: "Triplet",
      description: "Three equal triplets",
      restPattern: [true, true, true],
      durationPattern: [0.33, 0.33, 0.33],
    ),
    Subdivision(
      name: "Dotted Eighth and Sixteenth",
      description: "Dotted eighth and sixteenth",
      restPattern: [true, true],
      durationPattern: [0.75, 0.25],
    ),
    Subdivision(
      name: "Swing",
      description: "Swing eighth notes (2/3 + 1/3)",
      restPattern: [true, true],
      durationPattern: [0.67, 0.33],
    ),
    Subdivision(
      name: "Rest and Eighth Note",
      description: "Rest, then eighth note",
      restPattern: [false, true],
      durationPattern: [0.5, 0.5],
    )
  ];
  Subdivision _selectedSubdivision = Subdivision(
    name: "Quarter Notes",
    description: "One quarter note per beat",
    restPattern: [true],
    durationPattern: [1.0],
  );

  final StreamController<bool> _isPlayingController =
      StreamController.broadcast();
  final StreamController<int> _bpmController = StreamController.broadcast();
  final StreamController<int> _currentTickController =
      StreamController.broadcast();

  bool get isPlaying => _isPlaying;

  int get bpm => _bpm;

  int get timeSignatureNumerator => _timeSignatureNumerator;

  int get timeSignatureDenominator => _timeSignatureDenominator;

  int get currentTick => _currentTick;

  int get currentSubdivisionTick => _currentSubdivisionTick;

  List<TickType> get tickTypes => _tickTypes;

  List<Subdivision> get subdivisions => _subdivisions;

  Subdivision get selectedSubdivision => _selectedSubdivision;

  /// Поток состояния.
  Stream<Map<String, dynamic>> get stateStream =>
      MetroDronePlatform.instance.stateStream;

  /// Поток isPlaying.
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  /// Поток bpm.
  Stream<int> get bpmStream => _bpmController.stream;

  /// Поток currentTick.
  Stream<int> get currentTickStream => _currentTickController.stream;

  /// Запускает метроном.
  Future<void> start() async {
    await MetroDronePlatform.instance.start();
  }

  /// Останавливает метроном.
  Future<void> stop() async {
    await MetroDronePlatform.instance.stop();
  }

  Future<void> tap() async {
    await MetroDronePlatform.instance.tap();
  }

  Future<void> setBpm(int bpm) async {
    if (bpm < 40 || bpm > 240) {
      throw ArgumentError('BPM must be between 40 and 240');
    }
    await MetroDronePlatform.instance.setBpm(bpm);
  }

  Future<void> setTimeSignatureBpm({
    required int numerator,
    required int denominator,
  }) async {
    if (numerator < 0 || numerator > 16) {
      throw ArgumentError('Numerator must be between 1 and 16');
    }

    if (![1, 2, 4, 8].contains(denominator)) {
      throw ArgumentError('BPM must be in [1,2,4,8]');
    }

    await MetroDronePlatform.instance.setTimeSignature(
      numerator: numerator,
      denominator: denominator,
    );
  }

  /// Подписка на поток для обновления локальных полей.
  void listenToStateUpdates() {
    stateStream.listen((event) {
      final newIsPlaying = event['isPlaying'] as bool? ?? _isPlaying;
      if (_isPlaying != newIsPlaying) {
        _isPlaying = newIsPlaying;
        _isPlayingController.add(_isPlaying);
      }

      final newBpm = event['bpm'] as int? ?? _bpm;
      if (_bpm != newBpm) {
        _bpm = newBpm;
        _bpmController.add(_bpm);
      }

      final newCurrentTick = event['currentTick'] as int? ?? _currentTick;
      if (_currentTick != newCurrentTick) {
        _currentTick = newCurrentTick;
        _currentTickController.add(_currentTick);
      }

      _currentSubdivisionTick =
          event['currentSubdivisionTick'] ?? _currentSubdivisionTick;
      _timeSignatureNumerator =
          event['timeSignatureNumerator'] ?? _timeSignatureNumerator;
      _timeSignatureDenominator =
          event['timeSignatureDenominator'] ?? _timeSignatureDenominator;

      print("onStateChanged: $event");
    });
  }

  /// Закрытие всех потоков при уничтожении объекта.
  void dispose() {
    _isPlayingController.close();
    _bpmController.close();
    _currentTickController.close();
  }
}

enum TickType {
  silence,
  regular,
  accent,
  strongAccent,
}

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
}
