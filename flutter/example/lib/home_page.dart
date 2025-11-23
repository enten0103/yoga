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
