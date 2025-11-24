import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class HtmlReplicaPage extends StatelessWidget {
  const HtmlReplicaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTML Replica')),
      body: YogaLayout(
        padding: YogaEdgeInsets.all(YogaValue.point(20)),
        children: [
          YogaItem(
            maxWidth: YogaValue.point(800),
            border: YogaBorder.all(color: Colors.grey.shade300, width: 1),
            child: YogaLayout(
              padding: YogaEdgeInsets.all(YogaValue.point(20)),
              children: [
                // h3
                YogaItem(
                  margin: YogaEdgeInsets.only(bottom: YogaValue.point(10)),
                  child: const Text(
                    '简介',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // hr
                YogaItem(
                  height: YogaValue.point(1),
                  margin: YogaEdgeInsets.symmetric(
                    vertical: YogaValue.point(10),
                  ),
                  child: Container(color: Colors.grey.shade300),
                ),
                // p1
                YogaItem(
                  margin: YogaEdgeInsets.only(bottom: YogaValue.point(10)),
                  child: const Text(
                    '学期末的脚步渐渐逼近。伽耶即将参加入学考试，我们则要面对音乐祭的最后准备工作。这时，因为华园老师以前参加的管弦乐团因为人手不足，PNO的成员被找去帮忙。然而音乐会偏偏选在情人节举行！来自所有成员的巧克力总攻击让我应接不暇。',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
                // p2
                YogaItem(
                  margin: YogaEdgeInsets.only(bottom: YogaValue.point(10)),
                  child: const Text(
                    '可是这段甜蜜的时光并不长久。为了解救处于解散危机的管弦乐团，我决定邀请他们参加音乐祭。一定要用无懈可击的演奏来宣示乐团的复苏！',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
                // p3
                YogaItem(
                  child: const Text(
                    '激情四溢的恋爱合奏，超高纯度青春故事，第四集！',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
