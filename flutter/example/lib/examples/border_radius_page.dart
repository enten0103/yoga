import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class BorderRadiusPage extends StatelessWidget {
  const BorderRadiusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Border Radius Examples')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('Uniform Radius (20px)'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(150),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 5, color: Colors.blue),
                      borderRadius: YogaBorderRadius.circular(20),
                    ),
                    child: Container(
                      color: Colors.blue.shade100,
                      child: const Center(child: Text('Radius 20')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Individual Corners'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(150),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(150),
                    border: const YogaBorder(
                      all: YogaBorderSide(width: 5, color: Colors.green),
                      borderRadius: YogaBorderRadius(
                        topLeft: YogaValue.point(40),
                        bottomRight: YogaValue.point(40),
                      ),
                    ),
                    child: Container(
                      color: Colors.green.shade100,
                      child: const Center(child: Text('TL/BR 40')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('With Image (Clipped)'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(150),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(150),
                    overflow: YogaOverflow.hidden,
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 5, color: Colors.red),
                      borderRadius: YogaBorderRadius.circular(75), // Circle
                      image: YogaBorderImage(
                        source: const NetworkImage(
                          'https://i2.hdslb.com/bfs/archive/54524c52fa98adb5d3ebe3454a0b6a56c8f7c4e1.jpg@672w_378h_1c_!web-home-common-cover.avif',
                        ),
                        slice: const YogaEdgeInsets.all(YogaValue.point(30)),
                        width: const YogaEdgeInsets.all(YogaValue.point(20)),
                        repeat: YogaBorderImageRepeat.round,
                      ),
                    ),
                    child: Container(
                      color: Colors.purple.shade50,
                      child: const Center(child: Text('Dashed Radius')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Dashed Rounded Border'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(150),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(
                        width: 4,
                        color: Colors.purple,
                        style: YogaBorderStyle.dashed,
                      ),
                      borderRadius: YogaBorderRadius.circular(20),
                    ),
                    child: Container(
                      color: Colors.purple.shade50,
                      child: const Center(child: Text('Dashed Radius')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Percentage Radius (50%)'),
              const SizedBox(height: 10),
              YogaLayout(
                width: YogaValue.point(150),
                height: YogaValue.point(150),
                children: [
                  YogaItem(
                    width: YogaValue.point(150),
                    height: YogaValue.point(150),
                    border: const YogaBorder(
                      all: YogaBorderSide(width: 5, color: Colors.orange),
                      borderRadius: YogaBorderRadius.all(YogaValue.percent(50)),
                    ),
                    child: Container(
                      color: Colors.orange.shade100,
                      child: const Center(child: Text('50%')),
                    ),
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
