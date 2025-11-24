import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class DisplayInteractionPage extends StatefulWidget {
  const DisplayInteractionPage({super.key});

  @override
  State<DisplayInteractionPage> createState() => _DisplayInteractionPageState();
}

class _DisplayInteractionPageState extends State<DisplayInteractionPage> {
  // Container properties
  bool _isRow = true;
  bool _isWrap = true;

  // Items
  final List<_ItemConfig> _items = [
    _ItemConfig(type: _ItemType.block, text: 'Block 1'),
    _ItemConfig(type: _ItemType.inline, text: 'Inline 1'),
    _ItemConfig(type: _ItemType.inline, text: 'Inline 2'),
    _ItemConfig(type: _ItemType.block, text: 'Block 2'),
    _ItemConfig(type: _ItemType.inline, text: 'Inline 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display Interaction')),
      body: Column(
        children: [
          _buildHtmlSimulation(),
          _buildControls(),
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: SingleChildScrollView(
                child: YogaLayout(
                  // To simulate a "Flow" container that supports both block and inline items correctly,
                  // we typically need Row + Wrap.
                  // If we use Column (default Block), everything stacks.
                  display: YogaDisplay.flex,
                  flexDirection: _isRow
                      ? YGFlexDirection.row
                      : YGFlexDirection.column,
                  flexWrap: _isWrap ? YGWrap.wrap : YGWrap.noWrap,
                  alignItems: YGAlign
                      .flexStart, // Don't stretch by default to see inline effect
                  padding: YogaEdgeInsets.all(YogaValue.point(10)),
                  children: _items.map((item) => _buildItem(item)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlSimulation() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HTML Structure: <p>222<span>21dw</span>213</p>',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: YogaLayout(
                // This outer layout represents the document flow (vertical)
                display: YogaDisplay.block,
                children: [
                  // The <p> tag
                  YogaLayout(
                    // Internal layout: Inline flow
                    // With new defaults (Row + Wrap), Inline children (width: auto) will flow horizontally.
                    display: YogaDisplay.block,
                    padding: YogaEdgeInsets.all(YogaValue.point(10)),
                    border: YogaBorder.all(color: Colors.grey, width: 1),
                    alignItems: YGAlign.baseline, // Align text to baseline
                    children: [
                      YogaItem(
                        child: const Text(
                          "222",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      YogaItem(
                        display: YogaDisplay.inline,
                        margin: YogaEdgeInsets.symmetric(
                          horizontal: YogaValue.point(5),
                        ),
                        child: Container(
                          color: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: const Text(
                            "21dw",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      YogaItem(
                        child: const Text(
                          "213",
                          style: TextStyle(fontSize: 20),
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

  Widget _buildControls() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Container Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Text('Direction: '),
                    DropdownButton<bool>(
                      value: _isRow,
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Row')),
                        DropdownMenuItem(value: false, child: Text('Column')),
                      ],
                      onChanged: (v) => setState(() => _isRow = v!),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Wrap: '),
                    Switch(
                      value: _isWrap,
                      onChanged: (v) => setState(() => _isWrap = v),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const Text(
              'Add Items',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _addItem(_ItemType.block),
                  child: const Text('Add Block'),
                ),
                ElevatedButton(
                  onPressed: () => _addItem(_ItemType.inline),
                  child: const Text('Add Inline'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _items.clear()),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(_ItemConfig item) {
    final isBlock = item.type == _ItemType.block;
    return YogaItem(
      display: isBlock ? YogaDisplay.block : YogaDisplay.inline,
      margin: YogaEdgeInsets.all(YogaValue.point(4)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isBlock ? Colors.green.shade200 : Colors.blue.shade200,
          border: Border.all(color: Colors.black54),
        ),
        child: Text(
          '${item.text}\n(${isBlock ? "Block" : "Inline"})',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _addItem(_ItemType type) {
    setState(() {
      final count = _items.where((i) => i.type == type).length + 1;
      _items.add(
        _ItemConfig(
          type: type,
          text: '${type == _ItemType.block ? "Block" : "Inline"} $count',
        ),
      );
    });
  }
}

enum _ItemType { block, inline }

class _ItemConfig {
  final _ItemType type;
  final String text;

  _ItemConfig({required this.type, required this.text});
}
