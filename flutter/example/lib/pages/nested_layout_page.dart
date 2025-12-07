import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class NestedLayoutPage extends StatelessWidget {
  const NestedLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 嵌套布局')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HtmlDiv(
            width: const FixedSize(200),
            height: const AutoSize(),
            children: [
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(50),
              ),
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
