import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class BorderImagePage extends StatelessWidget {
  const BorderImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Border Image Examples')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Border Image Stretch'),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: YogaLayout(
                children: [
                  YogaItem(
                    width: const YogaValue.point(150),
                    height: const YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 20),
                      image: YogaBorderImage(
                        source: const NetworkImage(
                          'https://i2.hdslb.com/bfs/archive/54524c52fa98adb5d3ebe3454a0b6a56c8f7c4e1.jpg@672w_378h_1c_!web-home-common-cover.avif',
                        ),
                        slice: const YogaEdgeInsets.all(YogaValue.point(30)),
                        width: const YogaEdgeInsets.all(YogaValue.point(20)),
                        repeat: YogaBorderImageRepeat.stretch,
                      ),
                    ),
                    child: const Center(child: Text('Stretch')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Border Image Repeat'),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: YogaLayout(
                children: [
                  YogaItem(
                    width: const YogaValue.point(150),
                    height: const YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 20),
                      image: YogaBorderImage(
                        source: const NetworkImage(
                          'https://i2.hdslb.com/bfs/archive/54524c52fa98adb5d3ebe3454a0b6a56c8f7c4e1.jpg@672w_378h_1c_!web-home-common-cover.avif',
                        ),
                        slice: const YogaEdgeInsets.all(YogaValue.point(30)),
                        width: const YogaEdgeInsets.all(YogaValue.point(20)),
                        repeat: YogaBorderImageRepeat.repeat,
                      ),
                    ),
                    child: const Center(child: Text('Repeat')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Border Image Round'),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: YogaLayout(
                children: [
                  YogaItem(
                    width: const YogaValue.point(150),
                    height: const YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 20),
                      image: YogaBorderImage(
                        source: const NetworkImage(
                          'https://i2.hdslb.com/bfs/archive/54524c52fa98adb5d3ebe3454a0b6a56c8f7c4e1.jpg@672w_378h_1c_!web-home-common-cover.avif',
                        ),
                        slice: const YogaEdgeInsets.all(YogaValue.point(30)),
                        width: const YogaEdgeInsets.all(YogaValue.point(20)),
                        repeat: YogaBorderImageRepeat.round,
                      ),
                    ),
                    child: const Center(child: Text('Round')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Percentage Slice (33%)'),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: YogaLayout(
                children: [
                  YogaItem(
                    width: const YogaValue.point(150),
                    height: const YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 20),
                      image: YogaBorderImage(
                        source: const NetworkImage(
                          'https://i2.hdslb.com/bfs/archive/54524c52fa98adb5d3ebe3454a0b6a56c8f7c4e1.jpg@672w_378h_1c_!web-home-common-cover.avif',
                        ),
                        // 33% of image size
                        slice: const YogaEdgeInsets.all(YogaValue.percent(33)),
                        width: const YogaEdgeInsets.all(YogaValue.point(20)),
                        repeat: YogaBorderImageRepeat.stretch,
                      ),
                    ),
                    child: const Center(child: Text('Slice 33%')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Percentage Width (15%)'),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: YogaLayout(
                children: [
                  YogaItem(
                    width: const YogaValue.point(150),
                    height: const YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 20),
                      image: YogaBorderImage(
                        source: const NetworkImage(
                          'https://i2.hdslb.com/bfs/archive/54524c52fa98adb5d3ebe3454a0b6a56c8f7c4e1.jpg@672w_378h_1c_!web-home-common-cover.avif',
                        ),
                        slice: const YogaEdgeInsets.all(YogaValue.point(30)),
                        // 15% of element size (150 * 0.15 = 22.5)
                        width: const YogaEdgeInsets.all(YogaValue.percent(15)),
                        repeat: YogaBorderImageRepeat.stretch,
                      ),
                    ),
                    child: const Center(child: Text('Width 15%')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Border Image Outset (10px)'),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: YogaLayout(
                children: [
                  YogaItem(
                    width: const YogaValue.point(150),
                    height: const YogaValue.point(150),
                    border: YogaBorder(
                      all: const YogaBorderSide(width: 20),
                      image: YogaBorderImage(
                        source: const NetworkImage(
                          'https://i2.hdslb.com/bfs/archive/54524c52fa98adb5d3ebe3454a0b6a56c8f7c4e1.jpg@672w_378h_1c_!web-home-common-cover.avif',
                        ),
                        slice: const YogaEdgeInsets.all(YogaValue.point(30)),
                        width: const YogaEdgeInsets.all(YogaValue.point(20)),
                        outset: const YogaEdgeInsets.all(YogaValue.point(10)),
                        repeat: YogaBorderImageRepeat.stretch,
                      ),
                    ),
                    child: const Center(child: Text('Outset 10px')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
