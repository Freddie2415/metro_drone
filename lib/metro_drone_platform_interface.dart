import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'metro_drone_method_channel.dart';
import 'models/subdivision.dart';
import 'models/tick_type.dart';

abstract class MetroDronePlatform extends PlatformInterface {
  /// Конструктор [MetroDronePlatform].
  MetroDronePlatform() : super(token: _token);

  static final Object _token = Object();

  static MetroDronePlatform _instance = MethodChannelMetroDrone();

  /// Экземпляр платформенной реализации [MetroDronePlatform].
  static MetroDronePlatform get instance => _instance;

  /// Установка пользовательской реализации платформы.
  static set instance(MetroDronePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Метод запуска метронома.
  Future<void> start() {
    throw UnimplementedError('start() has not been implemented.');
  }

  /// Метод остановки метронома.
  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Stream<Map<String, dynamic>> get stateStream {
    throw UnimplementedError('stateStream has not been implemented.');
  }

  Future<void> tap() {
    throw UnimplementedError('tap has not been implemented.');
  }

  Future<void> setBpm(int bpm) async {
    throw UnimplementedError('setBpm has not been implemented.');
  }

  Future<void> setTimeSignature({
    required int numerator,
    required int denominator,
  }) async {
    throw UnimplementedError('setTimeSignature has not been implemented.');
  }

  Future<void> setSubdivision(Subdivision value) {
    throw UnimplementedError('setSubdivision has not been implemented.');
  }

  Future<void> setTickType({
    required int tickIndex,
    required TickType tickType,
  }) {
    throw UnimplementedError('setTickType has not been implemented.');
  }

  Future<void> setNextTickType({required int tickIndex}) {
    throw UnimplementedError('setNextTickType has not been implemented.');
  }

  Future<void> initialize([dynamic data]) async {
    throw UnimplementedError('initialize has not been implemented.');
  }

  Future<void> getCurrentState() async {
    throw UnimplementedError('getCurrentState has not been implemented.');
  }
}
