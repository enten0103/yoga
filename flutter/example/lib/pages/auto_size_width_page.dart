import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class AutoSizeWidthPage extends StatelessWidget {
  const AutoSizeWidthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 自动宽度')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Align(
              alignment: Alignment.topLeft,
              child: HtmlDiv(
                width: const AutoSize(),
                height: const FixedSize(50),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
