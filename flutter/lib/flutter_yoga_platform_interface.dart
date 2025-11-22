import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_yoga_method_channel.dart';

abstract class FlutterYogaPlatform extends PlatformInterface {
  /// Constructs a FlutterYogaPlatform.
  FlutterYogaPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterYogaPlatform _instance = MethodChannelFlutterYoga();

  /// The default instance of [FlutterYogaPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterYoga].
  static FlutterYogaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterYogaPlatform] when
  /// they register themselves.
  static set instance(FlutterYogaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
