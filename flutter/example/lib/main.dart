import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

import 'home_page.dart';
import 'examples/basic_layout_page.dart';
import 'examples/scrolling_page.dart';
import 'examples/nested_layout_page.dart';
import 'examples/flex_properties_page.dart';
import 'examples/spacing_page.dart';
import 'examples/display_page.dart';
import 'examples/web_defaults_page.dart';
import 'examples/margin_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initYoga();
  }

  Future<void> _initYoga() async {
    // Initialize platform if needed (e.g. load DLLs)
    // The plugin does this lazily usually, but good to trigger.
    await FlutterYoga().getPlatformVersion();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoga Layout Examples',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/basic': (context) => const BasicLayoutPage(),
        '/scrolling': (context) => const ScrollingPage(),
        '/nested': (context) => const NestedLayoutPage(),
        '/flex_properties': (context) => const FlexPropertiesPage(),
        '/spacing': (context) => const SpacingPage(),
        '/display': (context) => const DisplayPage(),
        '/web_defaults': (context) => const WebDefaultsPage(),
        '/margin': (context) => const MarginPage(),
      },
    );
  }
}
