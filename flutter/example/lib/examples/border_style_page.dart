import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class BorderStylePage extends StatelessWidget {
  const BorderStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Border Style Examples')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('Solid (Default)'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(100),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(100),
                    border: const YogaBorder(
                      all: YogaBorderSide(
                        width: 5,
                        color: Colors.blue,
                        style: YogaBorderStyle.solid,
                      ),
                    ),
                    child: Container(color: Colors.blue.shade100),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Dashed'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(100),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(100),
                    border: const YogaBorder(
                      all: YogaBorderSide(
                        width: 5,
                        color: Colors.red,
                        style: YogaBorderStyle.dashed,
                      ),
                    ),
                    child: Container(color: Colors.red.shade100),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Dotted'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(100),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(100),
                    border: const YogaBorder(
                      all: YogaBorderSide(
                        width: 8,
                        color: Colors.green,
                        style: YogaBorderStyle.dotted,
                      ),
                    ),
                    child: Container(color: Colors.green.shade100),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Mixed Styles'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(100),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(100),
                    border: const YogaBorder(
                      top: YogaBorderSide(
                        width: 5,
                        color: Colors.purple,
                        style: YogaBorderStyle.dashed,
                      ),
                      bottom: YogaBorderSide(
                        width: 5,
                        color: Colors.purple,
                        style: YogaBorderStyle.dotted,
                      ),
                      left: YogaBorderSide(
                        width: 10,
                        color: Colors.orange,
                        style: YogaBorderStyle.solid,
                      ),
                      right: YogaBorderSide(
                        width: 2,
                        color: Colors.black,
                        style: YogaBorderStyle.dashed,
                      ),
                    ),
                    child: Container(color: Colors.grey.shade200),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
