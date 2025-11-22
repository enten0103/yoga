import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_yoga/flutter_yoga.dart';
import 'package:flutter_yoga/flutter_yoga_platform_interface.dart';
import 'package:flutter_yoga/flutter_yoga_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterYogaPlatform
    with MockPlatformInterfaceMixin
    implements FlutterYogaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterYogaPlatform initialPlatform = FlutterYogaPlatform.instance;

  test('$MethodChannelFlutterYoga is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterYoga>());
  });

  test('getPlatformVersion', () async {
    FlutterYoga flutterYogaPlugin = FlutterYoga();
    MockFlutterYogaPlatform fakePlatform = MockFlutterYogaPlatform();
    FlutterYogaPlatform.instance = fakePlatform;

    expect(await flutterYogaPlugin.getPlatformVersion(), '42');
  });
}
