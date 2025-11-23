import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class NestedLayoutPage extends StatelessWidget {
  const NestedLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Layout')),
      body: Container(
        color: Colors.grey[200],
        child: YogaLayout(
          flexDirection: YGFlexDirection.column,
          justifyContent: YGJustify.center,
          alignItems: YGAlign.center,
          children: [
            YogaItem(
              width: YogaValue.pt(300),
              height: YogaValue.pt(300),
              child: Container(
                color: Colors.white,
                child: YogaLayout(
                  flexDirection: YGFlexDirection.row,
                  justifyContent: YGJustify.spaceAround,
                  alignItems: YGAlign.center,
                  padding: const YogaEdgeInsets.all(YogaValue.point(10)),
                  children: [
                    YogaItem(
                      width: YogaValue.pt(80),
                      height: YogaValue.pt(80),
                      child: Container(color: Colors.red),
                    ),
                    YogaItem(
                      width: YogaValue.pt(80),
                      height: YogaValue.pt(200), // Taller item
                      child: Container(
                        color: Colors.blue,
                        child: YogaLayout(
                          flexDirection: YGFlexDirection.column,
                          justifyContent: YGJustify.spaceBetween,
                          padding: const YogaEdgeInsets.all(YogaValue.point(5)),
                          children: [
                            YogaItem(
                              height: YogaValue.pt(30),
                              child: Container(color: Colors.yellow),
                            ),
                            YogaItem(
                              height: YogaValue.pt(30),
                              child: Container(color: Colors.yellow),
                            ),
                          ],
                        ),
                      ),
                    ),
                    YogaItem(
                      width: YogaValue.pt(80),
                      height: YogaValue.pt(80),
                      child: Container(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
