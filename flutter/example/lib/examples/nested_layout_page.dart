import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class NestedLayoutPage extends StatelessWidget {
  const NestedLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Layout (New API)')),
      body: Container(
        color: Colors.grey[200],
        child: YogaLayout(
          // Root Layout
          useWebDefaults: true,
          enableMarginCollapsing: true,
          flexDirection: YGFlexDirection.column,
          width: YogaValue.percent(100),
          height: YogaValue.percent(100),
          padding: const YogaEdgeInsets.all(YogaValue.point(20)),
          children: [
            // 1. Header (Nested YogaLayout with fixed height)
            YogaLayout(
              height: YogaValue.point(60),
              margin: const YogaEdgeInsets.only(bottom: YogaValue.point(20)),
              border: YogaBorder.all(
                color: Colors.blueGrey,
                width: 2,
                borderRadius: const YogaBorderRadius.all(YogaValue.point(8)),
              ),
              boxShadow: [
                YogaBoxShadow(
                  blurRadius: YogaValue.point(5),
                  color: Colors.black12,
                  offsetDY: YogaValue.point(2),
                ),
              ],
              justifyContent: YGJustify.center,
              alignItems: YGAlign.center,
              children: [
                YogaItem(
                  child: const Text(
                    "Header (Fixed Height)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // 2. Main Body (Nested YogaLayout with flexGrow: 1)
            YogaLayout(
              useWebDefaults: true,
              flexGrow: 1, // Fills remaining vertical space
              flexDirection: YGFlexDirection.row,
              children: [
                // 2.1 Sidebar (Nested YogaLayout with fixed width)
                YogaLayout(
                  width: YogaValue.point(100),
                  margin: const YogaEdgeInsets.only(right: YogaValue.point(20)),
                  padding: const YogaEdgeInsets.all(YogaValue.point(10)),
                  border: YogaBorder.all(
                    color: Colors.orange,
                    width: 1,
                    borderRadius: const YogaBorderRadius.all(
                      YogaValue.point(8),
                    ),
                  ),
                  justifyContent: YGJustify.flexStart,
                  alignItems: YGAlign.center,
                  children: [
                    YogaItem(
                      margin: const YogaEdgeInsets.only(
                        bottom: YogaValue.point(10),
                      ),
                      child: const Icon(Icons.home, color: Colors.orange),
                    ),
                    YogaItem(
                      margin: const YogaEdgeInsets.only(
                        bottom: YogaValue.point(10),
                      ),
                      child: const Icon(Icons.settings, color: Colors.orange),
                    ),
                    YogaItem(
                      child: const Icon(Icons.person, color: Colors.orange),
                    ),
                  ],
                ),

                // 2.2 Content Area (Nested YogaLayout with flexGrow: 1)
                YogaLayout(
                  margin: const YogaEdgeInsets.only(left: YogaValue.point(20)),
                  flexGrow: 1, // Fills remaining horizontal space
                  border: YogaBorder.all(
                    color: Colors.green,
                    width: 1,
                    borderRadius: const YogaBorderRadius.all(
                      YogaValue.point(8),
                    ),
                  ),
                  padding: const YogaEdgeInsets.all(YogaValue.point(10)),
                  flexDirection: YGFlexDirection.column,
                  children: [
                    YogaItem(
                      margin: const YogaEdgeInsets.only(
                        bottom: YogaValue.point(10),
                      ),
                      child: const Text(
                        "Main Content Area",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    YogaItem(
                      flexGrow: 1,
                      child: Container(
                        color: Colors.green.withValues(alpha: 0.1),
                        child: const Center(
                          child: Text(
                            "This content fills the remaining space inside the green box.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    // Nested Layout inside Content
                    YogaLayout(
                      height: YogaValue.point(50),
                      margin: const YogaEdgeInsets.only(
                        top: YogaValue.point(10),
                      ),
                      flexDirection: YGFlexDirection.row,
                      justifyContent: YGJustify.spaceBetween,
                      children: [
                        YogaItem(
                          width: YogaValue.pct(48),
                          height: YogaValue.percent(100),
                          border: YogaBorder.all(color: Colors.purple),
                          child: Text("Box A"),
                        ),
                        YogaItem(
                          width: YogaValue.pct(48),
                          height: YogaValue.percent(100),
                          border: YogaBorder.all(color: Colors.purple),
                          child: Text("Box B"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // 3. Footer (Nested YogaLayout)
            YogaLayout(
              height: YogaValue.point(40),
              margin: const YogaEdgeInsets.only(top: YogaValue.point(20)),
              border: YogaBorder(
                top: YogaBorderSide(color: Colors.grey, width: 1),
              ),
              justifyContent: YGJustify.center,
              alignItems: YGAlign.center,
              children: [
                YogaItem(
                  child: const Text(
                    "Footer",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
