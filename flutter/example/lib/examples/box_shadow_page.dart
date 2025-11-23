import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class BoxShadowPage extends StatefulWidget {
  const BoxShadowPage({super.key});

  @override
  State<BoxShadowPage> createState() => _BoxShadowPageState();
}

class _BoxShadowPageState extends State<BoxShadowPage> {
  double _offsetXPercent = 10.0;
  double _offsetYPercent = 10.0;
  double _blurPercent = 5.0;
  double _spreadPercent = 0.0;
  bool _usePercent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Box Shadow Example')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: YogaLayout(
                  width: YogaValue.pct(100),
                  height: YogaValue.point(300),
                  justifyContent: YGJustify.center,
                  alignItems: YGAlign.center,
                  children: [
                    YogaItem(
                      width: YogaValue.pct(15),
                      height: YogaValue.point(150),
                      boxShadow: [
                        YogaBoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offsetDX: _usePercent
                              ? YogaValue.percent(_offsetXPercent)
                              : YogaValue.point(_offsetXPercent),
                          offsetDY: _usePercent
                              ? YogaValue.percent(_offsetYPercent)
                              : YogaValue.point(_offsetYPercent),
                          blurRadius: _usePercent
                              ? YogaValue.percent(_blurPercent)
                              : YogaValue.point(_blurPercent),
                          spreadRadius: _usePercent
                              ? YogaValue.percent(_spreadPercent)
                              : YogaValue.point(_spreadPercent),
                        ),
                      ],
                      child: Container(
                        color: Colors.blue,
                        child: const Center(
                          child: Text(
                            'Shadow Box',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    YogaItem(
                      width: YogaValue.point(150),
                      height: YogaValue.point(150),
                      boxShadow: [
                        YogaBoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offsetDX: _usePercent
                              ? YogaValue.percent(_offsetXPercent)
                              : YogaValue.point(_offsetXPercent),
                          offsetDY: _usePercent
                              ? YogaValue.percent(_offsetYPercent)
                              : YogaValue.point(_offsetYPercent),
                          blurRadius: _usePercent
                              ? YogaValue.percent(_blurPercent)
                              : YogaValue.point(_blurPercent),
                          spreadRadius: _usePercent
                              ? YogaValue.percent(_spreadPercent)
                              : YogaValue.point(_spreadPercent),
                        ),
                      ],
                      child: Container(
                        color: Colors.blue,
                        child: const Center(
                          child: Text(
                            'Shadow Box',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Unit: '),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Percent')),
                        ButtonSegment(value: false, label: Text('Point')),
                      ],
                      selected: {_usePercent},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          _usePercent = newSelection.first;
                          // Reset values to reasonable defaults when switching
                          if (_usePercent) {
                            _offsetXPercent = 10;
                            _offsetYPercent = 10;
                            _blurPercent = 5;
                            _spreadPercent = 0;
                          } else {
                            _offsetXPercent = 20;
                            _offsetYPercent = 20;
                            _blurPercent = 10;
                            _spreadPercent = 0;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSlider(
                  'Offset X',
                  _offsetXPercent,
                  -100,
                  100,
                  (v) => setState(() => _offsetXPercent = v),
                ),
                _buildSlider(
                  'Offset Y',
                  _offsetYPercent,
                  -100,
                  100,
                  (v) => setState(() => _offsetYPercent = v),
                ),
                _buildSlider(
                  'Blur Radius',
                  _blurPercent,
                  0,
                  50,
                  (v) => setState(() => _blurPercent = v),
                ),
                _buildSlider(
                  'Spread Radius',
                  _spreadPercent,
                  -50,
                  50,
                  (v) => setState(() => _spreadPercent = v),
                ),
              ],
            ),
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
        SizedBox(
          width: 100,
          child: Text(
            '$label: ${value.toStringAsFixed(1)}${_usePercent ? '%' : 'px'}',
          ),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
