import 'package:flutter_test/flutter_test.dart';
import 'package:metro_drone/metro_drone_method_channel.dart';
import 'package:metro_drone/metro_drone_platform_interface.dart';
import 'package:metro_drone/models/subdivision.dart';
import 'package:metro_drone/models/tick_type.dart';
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
  Future<void> setTimeSignature(
      {required int numerator, required int denominator}) {
    // TODO: implement setTimeSignature
    throw UnimplementedError();
  }

  @override
  Future<void> setSubdivision(Subdivision value) {
    // TODO: implement setSubdivision
    throw UnimplementedError();
  }

  @override
  Future<void> setTickType({
    required int tickIndex,
    required TickType tickType,
  }) {
    // TODO: implement setTickType
    throw UnimplementedError();
  }

  @override
  Future<void> setNextTickType({required int tickIndex}) {
    // TODO: implement setNextTickType
    throw UnimplementedError();
  }

  @override
  Future<void> initialize([dynamic data]) {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> getCurrentState() {
    // TODO: implement getCurrentState
    throw UnimplementedError();
  }
}

void main() {
  final MetroDronePlatform initialPlatform = MetroDronePlatform.instance;

  test('$MethodChannelMetroDrone is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMetroDrone>());
  });
}
