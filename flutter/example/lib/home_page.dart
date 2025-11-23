import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yoga Layout Examples')),
      body: ListView(
        children: [
          _buildListTile(context, 'Basic Layout', '/basic'),
          _buildListTile(context, 'Scrolling', '/scrolling'),
          _buildListTile(context, 'Nested Layout', '/nested'),
          _buildListTile(
            context,
            'Flex Properties (Grow/Shrink/Basis)',
            '/flex_properties',
          ),
          _buildListTile(
            context,
            'Spacing (Margin/Padding/Border)',
            '/spacing',
          ),
          _buildListTile(context, 'Display (None/Flex)', '/display'),
          _buildListTile(context, 'Web Defaults', '/web_defaults'),
          _buildListTile(context, 'Margin Examples', '/margin'),
          _buildListTile(context, 'Padding Examples', '/padding'),
          _buildListTile(context, 'Box Shadow Examples', '/box_shadow'),
          _buildListTile(context, 'Border Image Examples', '/border_image'),
          _buildListTile(context, 'Border Style Examples', '/border_style'),
          _buildListTile(context, 'Border Radius Examples', '/border_radius'),
          _buildListTile(context, 'Box Sizing Examples', '/box_sizing'),
          _buildListTile(context, 'Transform Examples', '/transform'),
          _buildListTile(context, 'Min/Max Dimensions', '/min_max'),
          _buildListTile(context, 'Text Align', '/text_align'),
          _buildListTile(context, 'Background', '/background'),
          _buildListTile(context, 'Intrinsic Sizing', '/intrinsic_sizing'),
          _buildListTile(
            context,
            'Fit Content & Margin Auto',
            '/fit_content_margin_auto',
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
