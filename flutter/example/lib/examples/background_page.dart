import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class BackgroundPage extends StatelessWidget {
  const BackgroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Background Example')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Background Color',
              YogaLayout(
                display: YogaDisplay.flex,
                width: YogaValue.point(200),
                height: YogaValue.point(100),
                background: const YogaBackground(color: Colors.blue),
                justifyContent: YGJustify.center,
                alignItems: YGAlign.center,
                children: [
                  YogaItem(
                    child: const Text(
                      'Blue Background',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Background Image (Cover)',
              YogaLayout(
                display: YogaDisplay.flex,
                width: YogaValue.point(200),
                height: YogaValue.point(200),
                background: const YogaBackground(
                  image: AssetImage('assets/test.jpg'),
                  size: YogaBackgroundSize.cover(),
                ),
                justifyContent: YGJustify.center,
                alignItems: YGAlign.center,
                children: [
                  YogaItem(
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Cover',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Background Image (Contain, No Repeat)',
              YogaLayout(
                display: YogaDisplay.flex,
                width: YogaValue.point(200),
                height: YogaValue.point(200),
                background: const YogaBackground(
                  color: Colors.grey,
                  image: AssetImage('assets/test.jpg'),
                  size: YogaBackgroundSize.contain(),
                  repeat: ImageRepeat.noRepeat,
                  position: YogaBackgroundPosition.center,
                ),
                justifyContent: YGJustify.center,
                alignItems: YGAlign.center,
                children: [
                  YogaItem(
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Contain',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Background Origin (Padding Box vs Content Box)',
              YogaLayout(
                display: YogaDisplay.flex,
                flexDirection: YGFlexDirection.row,
                justifyContent: YGJustify.spaceAround,
                width: YogaValue.percent(100),
                children: [
                  YogaLayout(
                    width: YogaValue.point(150),
                    height: YogaValue.point(150),
                    padding: const YogaEdgeInsets.all(YogaValue.point(20)),
                    border: YogaBorder.all(
                      color: Colors.black.withValues(alpha: 0.5),
                      width: 10,
                    ),
                    background: const YogaBackground(
                      color: Colors.red,
                      origin: YogaBackgroundOrigin.paddingBox,
                    ),
                    children: [YogaItem(child: const Text('Padding Box'))],
                  ),
                  YogaLayout(
                    width: YogaValue.point(150),
                    height: YogaValue.point(150),
                    padding: const YogaEdgeInsets.all(YogaValue.point(20)),
                    border: YogaBorder.all(
                      color: Colors.black.withValues(alpha: 0.5),
                      width: 10,
                    ),
                    background: const YogaBackground(
                      color: Colors.green,
                      origin: YogaBackgroundOrigin.contentBox,
                    ),
                    children: [YogaItem(child: const Text('Content Box'))],
                  ),
                ],
              ),
            ),

            _buildSection(
              'Background Repeat',
              Column(
                children: [
                  _buildRepeatExample('Repeat (Default)', ImageRepeat.repeat),
                  _buildRepeatExample('Repeat X', ImageRepeat.repeatX),
                  _buildRepeatExample('Repeat Y', ImageRepeat.repeatY),
                  _buildRepeatExample('No Repeat', ImageRepeat.noRepeat),
                ],
              ),
            ),
            _buildSection(
              'Nested Backgrounds',
              YogaLayout(
                width: YogaValue.point(300),
                height: YogaValue.point(300),
                padding: const YogaEdgeInsets.all(YogaValue.point(20)),
                background: const YogaBackground(color: Colors.orangeAccent),
                justifyContent: YGJustify.center,
                alignItems: YGAlign.center,
                children: [
                  YogaLayout(
                    width: YogaValue.percent(80),
                    height: YogaValue.percent(80),
                    background: const YogaBackground(
                      color: Colors.blueAccent,
                      image: AssetImage('assets/test.jpg'),
                      size: YogaBackgroundSize.cover(),
                    ),
                    justifyContent: YGJustify.center,
                    alignItems: YGAlign.center,
                    children: [
                      YogaItem(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: const Text(
                            'Inner Layout',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.grey[200],
          padding: const EdgeInsets.all(10),
          child: content,
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildRepeatExample(String label, ImageRepeat repeat) {
    // Use AssetImage for all examples
    const ImageProvider imageProvider = AssetImage('assets/test.jpg');

    return YogaLayout(
      margin: const YogaEdgeInsets.only(bottom: YogaValue.point(10)),
      width: YogaValue.point(
        300,
      ), // Use fixed width to avoid potential layout issues with percent
      height: YogaValue.point(100),
      background: YogaBackground(
        color: Colors.grey[300],
        image: imageProvider,
        repeat: repeat,
        size: const YogaBackgroundSize.auto(),
      ),
      justifyContent: YGJustify.center,
      alignItems: YGAlign.center,
      children: [
        YogaItem(
          child: Container(
            color: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
