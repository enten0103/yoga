#ifndef FLUTTER_PLUGIN_FLUTTER_YOGA_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_YOGA_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_yoga {

class FlutterYogaPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterYogaPlugin();

  virtual ~FlutterYogaPlugin();

  // Disallow copy and assign.
  FlutterYogaPlugin(const FlutterYogaPlugin&) = delete;
  FlutterYogaPlugin& operator=(const FlutterYogaPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_yoga

#endif  // FLUTTER_PLUGIN_FLUTTER_YOGA_PLUGIN_H_
