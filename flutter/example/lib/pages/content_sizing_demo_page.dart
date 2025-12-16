import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class ContentSizingDemoPage extends StatelessWidget {
  const ContentSizingDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HtmlDiv 内容尺寸示例')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. MinContent with Text (Wraps at words)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.grey[200],
                child: HtmlDiv(
                  width: const MinContent(),
                  height: const AutoSize(),
                  border: HtmlBorder.all(color: Colors.blue),
                  children: [const Text('Hello World This Is A Test')],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '2. MaxContent with Text (No wrapping)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  color: Colors.grey[200],
                  child: HtmlDiv(
                    width: const MaxContent(),
                    height: const AutoSize(),
                    border: HtmlBorder.all(color: Colors.green),
                    children: [const Text('Hello World This Is A Test')],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '3. FitContent (Unconstrained - behaves like Max)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.grey[200],
                child: HtmlDiv(
                  width: const FitContent(),
                  height: const AutoSize(),
                  border: HtmlBorder.all(color: Colors.orange),
                  children: [const Text('Hello World This Is A Long String')],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '4. FitContent (Constrained - shrinks)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 100,
                child: Container(
                  color: Colors.grey[200],
                  child: HtmlDiv(
                    width: const FitContent(),
                    height: const AutoSize(),
                    border: HtmlBorder.all(color: Colors.red),
                    children: [const Text('Hello World This Is A Long String')],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '5. FitContent + maxWidth (Clamps smaller than available)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 160,
                child: Container(
                  color: Colors.grey[200],
                  child: HtmlDiv(
                    width: const FitContent(),
                    maxWidth: const FixedSize(80),
                    height: const AutoSize(),
                    border: HtmlBorder.all(color: Colors.teal),
                    children: [const Text('Hello World This Is A Long String')],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '6. FitContent + minWidth (Still constrained by parent)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 100,
                child: Container(
                  color: Colors.grey[200],
                  child: HtmlDiv(
                    width: const FitContent(),
                    minWidth: const FixedSize(180),
                    height: const AutoSize(),
                    border: HtmlBorder.all(color: Colors.brown),
                    children: [const Text('Hello World This Is A Long String')],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '7. Nested MinContent',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.grey[200],
                child: HtmlDiv(
                  width: const MinContent(),
                  height: const AutoSize(),
                  border: HtmlBorder.all(color: Colors.purple),
                  children: [
                    HtmlDiv(
                      width: const FixedSize(50),
                      height: const FixedSize(30),
                      border: HtmlBorder.all(color: Colors.black),
                    ),
                    HtmlDiv(
                      width: const FixedSize(100),
                      height: const FixedSize(30),
                      border: HtmlBorder.all(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
