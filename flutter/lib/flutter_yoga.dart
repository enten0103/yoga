import 'flutter_yoga_platform_interface.dart';

export 'src/yoga_ffi.dart';

class FlutterYoga {
  Future<String?> getPlatformVersion() {
    return FlutterYogaPlatform.instance.getPlatformVersion();
  }
}
