import 'flutter_yoga_platform_interface.dart';

export 'src/yoga_ffi.dart';
export 'src/yoga_node.dart';
export 'src/widgets/yoga_layout.dart';
export 'src/rendering/yoga_layout.dart';

class FlutterYoga {
  Future<String?> getPlatformVersion() {
    return FlutterYogaPlatform.instance.getPlatformVersion();
  }
}
