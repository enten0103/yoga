import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class SpacingPage extends StatefulWidget {
  const SpacingPage({super.key});

  @override
  State<SpacingPage> createState() => _SpacingPageState();
}

class _SpacingPageState extends State<SpacingPage> {
  double _margin = 10;
  double _padding = 20;
  double _borderWidth = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spacing (Margin/Padding/Border)')),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Container(
                  color: Colors.white,
                  child: YogaLayout(
                    width: 300,
                    height: 300,
                    flexDirection: YGFlexDirection.column,
                    justifyContent: YGJustify.flexStart,
                    alignItems: YGAlign.stretch,
                    padding: EdgeInsets.all(_padding),
                    borderWidth: EdgeInsets.all(_borderWidth),
                    children: [
                      // We need to visualize the border since Yoga only reserves space.
                      // We can put a Container behind it? No, YogaLayout is a RenderObject.
                      // The YogaLayout widget itself doesn't paint.
                      // So the "borderWidth" just pushes content in.
                      // To visualize it, we wrap the content in a Container that paints the border?
                      // But YogaLayout controls the layout.

                      // For this demo, we just show that the space is reserved.
                      // The blue box is the child.
                      // The white area is the YogaLayout container.
                      // The padding pushes the blue box in.
                      // The border width also pushes the blue box in (additive to padding in terms of content box).
                      YogaItem(
                        height: 50,
                        margin: EdgeInsets.all(_margin),
                        child: Container(
                          color: Colors.blue,
                          child: const Center(child: Text("Item 1 (Margin)")),
                        ),
                      ),
                      YogaItem(
                        flexGrow: 1,
                        child: Container(
                          color: Colors.green,
                          child: const Center(child: Text("Item 2 (Fill)")),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Note: Yoga 'borderWidth' reserves layout space but does not paint. "
              "In Flutter, you would typically use a Container with decoration to paint the border, "
              "and let Yoga handle the layout sizing.",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSlider(
            "Padding (Container)",
            _padding,
            0,
            50,
            (val) => setState(() => _padding = val),
          ),
          _buildSlider(
            "Border Width (Container)",
            _borderWidth,
            0,
            20,
            (val) => setState(() => _borderWidth = val),
          ),
          _buildSlider(
            "Margin (Item 1)",
            _margin,
            0,
            30,
            (val) => setState(() => _margin = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 30, child: Text(value.toStringAsFixed(0))),
      ],
    );
  }
}
