import 'dart:async';

import 'package:collection/collection.dart';

import 'metro_drone_platform_interface.dart';
import 'models/subdivision.dart';
import 'models/tick_type.dart';

class MetroDrone {
  bool _isPlaying = false;
  int _bpm = 120;
  int _timeSignatureNumerator = 4;
  int _timeSignatureDenominator = 4;
  int _currentTick = 0;
  int _currentSubdivisionTick = 0;
  List<TickType> _tickTypes = List.generate(4, (_) => TickType.regular);
  Subdivision _subdivision = Subdivision(
    name: "Quarter Notes",
    description: "One quarter note per beat",
    restPattern: [true],
    durationPattern: [1.0],
  );
  final List<Subdivision> _subdivisions = [
    Subdivision(
        name: "Quarter Notes",
        description: "One quarter note per beat",
        restPattern: [true],
        durationPattern: [1.0]),
    Subdivision(
        name: "Eighth Notes",
        description: "Two eighth notes",
        restPattern: [true, true],
        durationPattern: [0.5, 0.5]),
    Subdivision(
        name: "Sixteenth Notes",
        description: "Four equal sixteenth notes",
        restPattern: [true, true, true, true],
        durationPattern: [0.25, 0.25, 0.25, 0.25]),
    Subdivision(
        name: "Triplet",
        description: "Three equal triplets",
        restPattern: [true, true, true],
        durationPattern: [0.33, 0.33, 0.33]),
    Subdivision(
        name: "Swing",
        description: "Swing eighth notes (2/3 + 1/3)",
        restPattern: [true, true],
        durationPattern: [0.67, 0.33]),
    Subdivision(
        name: "Rest and Eighth Note",
        description: "Rest followed by an eighth note",
        restPattern: [false, true],
        durationPattern: [0.5, 0.5]),
    Subdivision(
        name: "Dotted Eighth and Sixteenth",
        description: "Dotted eighth and one sixteenth note",
        restPattern: [true, true],
        durationPattern: [0.75, 0.25]),
    Subdivision(
        name: "16th Note & Dotted Eighth",
        description: "One sixteenth note and one dotted eighth",
        restPattern: [true, true],
        durationPattern: [0.25, 0.75]),
    Subdivision(
        name: "2 Sixteenth Notes & Eighth Note",
        description: "Two sixteenth notes and one eighth note",
        restPattern: [true, true, true],
        durationPattern: [0.25, 0.25, 0.5]),
    Subdivision(
        name: "Eighth Note & 2 Sixteenth Notes",
        description: "One eighth note and two sixteenth notes",
        restPattern: [true, true, true],
        durationPattern: [0.5, 0.25, 0.25]),
    Subdivision(
        name: "16th Rest and Notes",
        description: "Alternating silence and sixteenth notes",
        restPattern: [false, true, false, true],
        durationPattern: [0.25, 0.25, 0.25, 0.25]),
    Subdivision(
        name: "16th Note, Eighth Note, 16th Note",
        description: "Sixteenth, eighth, and sixteenth notes",
        restPattern: [true, true, true],
        durationPattern: [0.25, 0.5, 0.25]),
    Subdivision(
        name: "2 Triplets & Triplet Rest",
        description: "Two triplets followed by a rest",
        restPattern: [true, true, false],
        durationPattern: [0.33, 0.33, 0.33]),
    Subdivision(
        name: "Triplet Rest & 2 Triplets",
        description: "Rest for triplet and two triplet notes",
        restPattern: [false, true, true],
        durationPattern: [0.33, 0.33, 0.33]),
    Subdivision(
        name: "Triplet Rest, Triplet, Triplet Rest",
        description: "Rest, triplet, and rest",
        restPattern: [false, true, false],
        durationPattern: [0.33, 0.33, 0.33]),
    Subdivision(
        name: "Quintuplets",
        description: "Five equal notes in one beat",
        restPattern: [true, true, true, true, true],
        durationPattern: [0.2, 0.2, 0.2, 0.2, 0.2]),
    Subdivision(
        name: "Septuplets",
        description: "Seven equal notes in one beat",
        restPattern: [true, true, true, true, true, true, true],
        durationPattern: [0.14, 0.14, 0.14, 0.14, 0.14, 0.14, 0.14])
  ];

  final StreamController<bool> _isPlayingController =
      StreamController.broadcast();

  final StreamController<int> _bpmController = StreamController.broadcast();

  final StreamController<int> _timeSignatureNumeratorController =
      StreamController.broadcast();

  final StreamController<int> _timeSignatureDenominatorController =
      StreamController.broadcast();

  final StreamController<int> _currentTickController =
      StreamController.broadcast();

  final StreamController<int> _currentSubdivisionTickController =
      StreamController.broadcast();

  final StreamController<Subdivision> _subdivisionController =
      StreamController.broadcast();

  final StreamController<List<TickType>> _tickTypesController =
      StreamController.broadcast();

  StreamSubscription? _stateStreamSubscription;
  StreamSubscription? _ticksStreamSubscription;

  bool get isPlaying => _isPlaying;

  int get bpm => _bpm;

  int get timeSignatureNumerator => _timeSignatureNumerator;

  int get timeSignatureDenominator => _timeSignatureDenominator;

  int get currentTick => _currentTick;

  int get currentSubdivisionTick => _currentSubdivisionTick;

  List<TickType> get tickTypes => _tickTypes;

  List<Subdivision> get subdivisions => _subdivisions;

  Subdivision get subdivision => _subdivision;

  /// Поток состояния.
  Stream<Map<String, dynamic>> get stateStream =>
      MetroDronePlatform.instance.stateStream;

  /// Поток тиков.
  Stream<Map<String, int>> get ticksStream =>
      MetroDronePlatform.instance.ticksStream;

  /// Поток isPlaying.
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  /// Поток bpm.
  Stream<int> get bpmStream => _bpmController.stream;

  Stream<int> get timeSignatureNumeratorStream =>
      _timeSignatureNumeratorController.stream;

  Stream<int> get timeSignatureDenominatorStream =>
      _timeSignatureDenominatorController.stream;

  /// Поток currentTick.
  Stream<int> get currentTickStream => _currentTickController.stream;

  Stream<int> get currentSubdivisionTickStream =>
      _currentSubdivisionTickController.stream;

  Stream<Subdivision> get subdivisionStream => _subdivisionController.stream;

  Stream<List<TickType>> get tickTypesStream => _tickTypesController.stream;

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
    if (bpm < 20 || bpm > 400) {
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
    _stateStreamSubscription?.cancel();
    _stateStreamSubscription = stateStream.listen((event) {
      final newIsPlaying = event['isPlaying'] as bool? ?? _isPlaying;
      if (_isPlaying != newIsPlaying) {
        _isPlaying = newIsPlaying;
        _isPlayingController.add(_isPlaying);
      }

      final newBpm = event['bpm'] as int? ?? _bpm;
      if (_bpm != newBpm) {
        _bpm = newBpm;
        _bpmController.add(_bpm);
        print("BPM: $bpm");
      }

      final newTimeSignatureNumerator =
          event['timeSignatureNumerator'] as int? ?? _timeSignatureNumerator;
      if (_timeSignatureNumerator != newTimeSignatureNumerator) {
        _timeSignatureNumerator = newTimeSignatureNumerator;
        _timeSignatureNumeratorController.add(newTimeSignatureNumerator);
        print("TimeSignatureNumerator: $timeSignatureNumerator");
      }

      final newTimeSignatureDenominator =
          event['timeSignatureDenominator'] as int? ??
              _timeSignatureDenominator;
      if (_timeSignatureDenominator != newTimeSignatureDenominator) {
        _timeSignatureDenominator = newTimeSignatureDenominator;
        _timeSignatureDenominatorController.add(newTimeSignatureDenominator);
        print("TimeSignatureNumerator: $timeSignatureDenominator");
      }

      if (event.containsKey("subdivision")) {
        final subdivisionMap = event['subdivision'].cast<String, dynamic>();
        final newSubdivision = Subdivision.fromMap(subdivisionMap);
        if (_subdivision.name != newSubdivision.name &&
            _subdivision.description != newSubdivision.description &&
            _subdivision.restPattern != newSubdivision.restPattern &&
            _subdivision.durationPattern != newSubdivision.durationPattern) {
          _subdivision = newSubdivision;
          _subdivisionController.add(_subdivision);
          print("Subdivision: $subdivision");
        }
      }

      if (event.containsKey('tickTypes') && event['tickTypes'] is List) {
        final tickTypesString =
            (event['tickTypes'] as List).map((e) => e.toString()).toList();
        final newTickTypes = TickType.fromList(tickTypesString);

        if (!const ListEquality().equals(newTickTypes, _tickTypes)) {
          _tickTypes = newTickTypes;
          _tickTypesController.add(newTickTypes);
          print("TickTypes: $tickTypes");
        }
      }
    });

    _ticksStreamSubscription?.cancel();
    _ticksStreamSubscription = ticksStream.listen((value) {
      if (value.containsKey("currentTick") &&
          value.containsKey("currentSubdivisionTick")) {
        _currentTick = value["currentTick"] as int;
        _currentSubdivisionTick = value["currentSubdivisionTick"] as int;
        _currentTickController.add(_currentTick);
        _currentSubdivisionTickController.add(_currentSubdivisionTick);
        print("Tick: $currentTick SubdivisionTick: $currentSubdivisionTick");
      }
    });

    getCurrentState();
  }

  Future<void> setSubdivision(Subdivision value) async {
    await MetroDronePlatform.instance.setSubdivision(value);
  }

  Future<void> setTickType({
    required int tickIndex,
    required TickType tickType,
  }) async {
    await MetroDronePlatform.instance.setTickType(
      tickIndex: tickIndex,
      tickType: tickType,
    );
  }

  Future<void> setNextTickType({required int tickIndex}) async {
    await MetroDronePlatform.instance.setNextTickType(tickIndex: tickIndex);
  }

  /// Закрытие всех потоков при уничтожении объекта.
  void dispose() {
    _stateStreamSubscription?.cancel();
    _ticksStreamSubscription?.cancel();
    _isPlayingController.close();
    _bpmController.close();
    _currentTickController.close();
  }

  Future<void> initialize({
    int bpm = 120,
    int timeSignatureNumerator = 4,
    int timeSignatureDenominator = 4,
    Subdivision? subdivision,
    List<TickType>? tickTypes,
  }) async {
    final subdivisionMap = subdivision?.toMap() ??
        Subdivision(
          name: "Quarter Notes",
          description: "One quarter note per beat",
          restPattern: [true],
          durationPattern: [1.0],
        ).toMap();

    final tickTypesStringList = tickTypes
            ?.map((e) => e.toStringValue())
            .toList() ??
        List.generate(
            timeSignatureNumerator, (_) => TickType.regular.toStringValue());

    Map<String, dynamic> initData = {
      "bpm": bpm,
      "timeSignatureNumerator": timeSignatureNumerator,
      "timeSignatureDenominator": timeSignatureDenominator,
      "subdivision": subdivisionMap,
      "tickTypes": tickTypesStringList,
    };
    await MetroDronePlatform.instance.initialize(initData);
  }

  Future<void> getCurrentState() async {
    await MetroDronePlatform.instance.getCurrentState();
  }
}
