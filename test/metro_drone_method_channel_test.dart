import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_drone/metro_drone_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMetroDrone platform = MethodChannelMetroDrone();
  const MethodChannel channel = MethodChannel('metro_drone');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });
}
