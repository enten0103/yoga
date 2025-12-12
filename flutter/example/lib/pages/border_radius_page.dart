import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class BorderRadiusPage extends StatelessWidget {
  const BorderRadiusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv Border Radius')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Uniform Radius (10px)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(100),
                border: HtmlBorder.all(color: Colors.blue, width: const FixedBorderWidth(5)),
                borderRadius: const HtmlBorderRadius.all(Radius.circular(10)),
                children: [Center(child: Text("Box"))],
              ),
              const SizedBox(height: 20),

              const Text('2. Individual Corners', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(100),
                border: HtmlBorder.all(color: Colors.green, width: const FixedBorderWidth(5)),
                borderRadius: const HtmlBorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                children: [Center(child: Text("Box"))],
              ),
              const SizedBox(height: 20),

              const Text('3. Dashed Border with Radius', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(100),
                border: HtmlBorder.all(
                  color: Colors.orange,
                  width: const FixedBorderWidth(3),
                  style: HtmlBorderStyle.dashed,
                ),
                borderRadius: const HtmlBorderRadius.all(Radius.circular(15)),
                children: [Center(child: Text("Box"))],
              ),
              const SizedBox(height: 20),

              const Text('4. Double Border with Radius', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              HtmlDiv(
                width: const FixedSize(100),
                height: const FixedSize(100),
                border: HtmlBorder.all(
                  color: Colors.purple,
                  width: const FixedBorderWidth(6),
                  style: HtmlBorderStyle.double,
                ),
                borderRadius: const HtmlBorderRadius.all(Radius.circular(15)),
                children: [Center(child: Text("Box"))],
              ),
              const SizedBox(height: 20),
              
              const Text('5. Elliptical Radius', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              HtmlDiv(
                width: const FixedSize(150),
                height: const FixedSize(100),
                border: HtmlBorder.all(color: Colors.red, width: const FixedBorderWidth(4)),
                borderRadius: const HtmlBorderRadius.all(Radius.elliptical(40, 20)),
                children: [Center(child: Text("Box"))],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
