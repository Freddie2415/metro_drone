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
  late Subdivision _subdivision = subdivisions.first;
  final Map<int, List<Subdivision>> _subdivisions = {
    1: Subdivision.subdivisionsForWholeNote,
    2: Subdivision.subdivisionsForHalfNote,
    4: Subdivision.subdivisionsForQuarterNote,
    8: Subdivision.subdivisionsForEighthNote,
    16: Subdivision.subdivisionsForSixteenthNote,
  };

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

  List<Subdivision> get subdivisions =>
      _subdivisions[timeSignatureDenominator] ??
      Subdivision.subdivisionsForQuarterNote;

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

    if (![1, 2, 4, 8, 16].contains(denominator)) {
      throw ArgumentError('BPM must be in [1,2,4,8, 16]');
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
