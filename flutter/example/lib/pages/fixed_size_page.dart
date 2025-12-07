import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class FixedSizePage extends StatelessWidget {
  const FixedSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 固定尺寸布局')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(100),
            height: const FixedSize(100),
          ),
        ),
      ),
    );
  }
}
