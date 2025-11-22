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
              width: 300,
              height: 300,
              child: Container(
                color: Colors.white,
                child: YogaLayout(
                  flexDirection: YGFlexDirection.row,
                  justifyContent: YGJustify.spaceAround,
                  alignItems: YGAlign.center,
                  padding: const EdgeInsets.all(10),
                  children: [
                    YogaItem(
                      width: 80,
                      height: 80,
                      child: Container(color: Colors.red),
                    ),
                    YogaItem(
                      width: 80,
                      height: 200, // Taller item
                      child: Container(
                        color: Colors.blue,
                        child: YogaLayout(
                          flexDirection: YGFlexDirection.column,
                          justifyContent: YGJustify.spaceBetween,
                          padding: const EdgeInsets.all(5),
                          children: [
                            YogaItem(
                              height: 30,
                              child: Container(color: Colors.yellow),
                            ),
                            YogaItem(
                              height: 30,
                              child: Container(color: Colors.yellow),
                            ),
                          ],
                        ),
                      ),
                    ),
                    YogaItem(
                      width: 80,
                      height: 80,
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
