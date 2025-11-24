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
import 'examples/padding_page.dart';
import 'examples/box_shadow_page.dart';
import 'examples/border_image_page.dart';
import 'examples/box_sizing_page.dart';
import 'examples/border_style_page.dart';
import 'examples/border_radius_page.dart';
import 'examples/transform_page.dart';
import 'examples/min_max_page.dart';
import 'examples/text_align_page.dart';
import 'examples/background_page.dart';
import 'examples/intrinsic_sizing_page.dart';
import 'examples/fit_content_margin_auto_page.dart';
import 'examples/html_replica_page.dart';
import 'examples/image_example_page.dart';
import 'examples/display_interaction_page.dart';

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
        '/padding': (context) => const PaddingPage(),
        '/box_shadow': (context) => const BoxShadowPage(),
        '/border_image': (context) => const BorderImagePage(),
        '/box_sizing': (context) => const BoxSizingPage(),
        '/border_style': (context) => const BorderStylePage(),
        '/border_radius': (context) => const BorderRadiusPage(),
        '/transform': (context) => const TransformPage(),
        '/min_max': (context) => const MinMaxPage(),
        '/text_align': (context) => const TextAlignPage(),
        '/background': (context) => const BackgroundPage(),
        '/intrinsic_sizing': (context) => const IntrinsicSizingPage(),
        '/fit_content_margin_auto': (context) =>
            const FitContentMarginAutoPage(),
        '/html_replica': (context) => const HtmlReplicaPage(),
        '/image_example': (context) => const ImageExamplePage(),
        '/display_interaction': (context) => const DisplayInteractionPage(),
      },
    );
  }
}
