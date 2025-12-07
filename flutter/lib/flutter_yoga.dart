import 'flutter_yoga_platform_interface.dart';

export 'html_div.dart';

class FlutterYoga {
  Future<String?> getPlatformVersion() {
    return FlutterYogaPlatform.instance.getPlatformVersion();
  }
}
