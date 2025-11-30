import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class TocExamplePage extends StatelessWidget {
  const TocExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TOC Example')),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: YogaLayout(
          scroll: true,
          padding: YogaEdgeInsets.all(YogaValue.point(20)),
          background: YogaBackground(color: Colors.white),
          width: YogaValue.percent(100),
          children: [
            YogaLayout(
              width: YogaValue.point(200),
              margin: YogaEdgeInsets.only(
                left: YogaValue.auto(),
                right: YogaValue.auto(),
                bottom: YogaValue.point(0),
                top: YogaValue.point(0),
              ),
              children: [
                YogaLayout(
                  children: [
                    YogaItem(
                      child: const Text(
                        'C O N T E N T S',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                YogaLayout(
                  display: YogaDisplay.flex,
                  margin: YogaEdgeInsets.only(
                    left: YogaValue.auto(),
                    right: YogaValue.auto(),
                    bottom: YogaValue.point(0),
                    top: YogaValue.point(0),
                  ),
                  children: [
                    YogaLayout(
                      children: [
                        YogaLayout(children: [YogaItem(child: Text("1"))]),
                        YogaLayout(children: [YogaItem(child: Text("2"))]),
                        YogaLayout(children: [YogaItem(child: Text("3"))]),
                        YogaLayout(children: [YogaItem(child: Text("4"))]),
                      ],
                    ),
                    YogaLayout(
                      children: [
                        YogaLayout(
                          children: [
                            YogaItem(child: Text("Menthol Light的")),
                            YogaLayout(
                              display: YogaDisplay.inline,
                              children: [YogaItem(child: Text("红"))],
                            ),
                            YogaItem(child: Text("蝶")),
                          ],
                        ),
                        YogaLayout(
                          children: [
                            YogaItem(child: Text("Horizont Light的黑")),
                            YogaLayout(
                              display: YogaDisplay.inline,
                              children: [YogaItem(child: Text("蝶"))],
                            ),
                          ],
                        ),
                        YogaLayout(
                          children: [
                            YogaItem(child: Text("Menthol Light的")),
                            YogaLayout(
                              display: YogaDisplay.inline,
                              children: [YogaItem(child: Text("红"))],
                            ),
                            YogaItem(child: Text("蝶")),
                          ],
                        ),
                        YogaLayout(
                          children: [
                            YogaItem(child: Text("Horizont Light的黑")),
                            YogaLayout(
                              display: YogaDisplay.inline,
                              children: [YogaItem(child: Text("蝶"))],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
