import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'metro_drone_platform_interface.dart';

/// Реализация [MetroDronePlatform], использующая метод-каналы.
class MethodChannelMetroDrone extends MetroDronePlatform {
  /// Канал для вызова нативных методов.
  @visibleForTesting
  final methodChannel = const MethodChannel('metro_drone');

  /// Канал для получения событий от нативной платформы.
  final eventChannel = const EventChannel('metro_drone/events');

  Stream<Map<String, dynamic>>? _stateStream;

  @override
  Stream<Map<String, dynamic>> get stateStream {
    _stateStream ??= eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
    return _stateStream!;
  }

  @override
  Future<void> start() async {
    await methodChannel.invokeMethod('start');
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod('stop');
  }

  @override
  Future<void> tap() async {
    await methodChannel.invokeMethod('tap');
  }

  @override
  Future<void> setBpm(int bpm) async {
    await methodChannel.invokeMethod('setBpm', bpm);
  }

  @override
  Future<void> setTimeSignature({
    required int numerator,
    required int denominator,
  }) async {
    await methodChannel.invokeMethod('setTimeSignature', {
      'numerator': numerator,
      'denominator': denominator,
    });
  }
}
