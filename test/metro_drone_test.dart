import 'package:flutter_test/flutter_test.dart';
import 'package:metro_drone/metro_drone_method_channel.dart';
import 'package:metro_drone/metro_drone_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMetroDronePlatform
    with MockPlatformInterfaceMixin
    implements MetroDronePlatform {
  @override
  Future<void> start() {
    // TODO: implement start
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }

  @override
  // TODO: implement isPlayingStream
  Stream<bool> get isPlayingStream => throw UnimplementedError();

  @override
  // TODO: implement bpmStream
  Stream<int> get bpmStream => throw UnimplementedError();

  @override
  Future<void> tap() {
    // TODO: implement tap
    throw UnimplementedError();
  }

  @override
  Future<void> setBpm(int bpm) {
    // TODO: implement setBpm
    throw UnimplementedError();
  }

  @override
  // TODO: implement stateStream
  Stream<Map<String, dynamic>> get stateStream => throw UnimplementedError();

  @override
  Future<void> setTimeSignature({required int numerator, required int denominator}) {
    // TODO: implement setTimeSignature
    throw UnimplementedError();
  }
}

void main() {
  final MetroDronePlatform initialPlatform = MetroDronePlatform.instance;

  test('$MethodChannelMetroDrone is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMetroDrone>());
  });
}
