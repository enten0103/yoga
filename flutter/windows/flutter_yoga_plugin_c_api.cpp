#include "include/flutter_yoga/flutter_yoga_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_yoga_plugin.h"

void FlutterYogaPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_yoga::FlutterYogaPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
