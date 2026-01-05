import 'package:flutter/material.dart';
import 'package:flutter_yoga/html_div.dart';

class PToc001CopyPage extends StatelessWidget {
  const PToc001CopyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('p-toc-001 复刻')),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: HtmlDiv(
          // Approximate browser defaults: body has padding/margins.
          padding: const HtmlPadding.all(HtmlLength.px(8)),
          children: [
            // <div style="margin: 0 auto; width:fit-content;">
            HtmlDiv(
              width: const FitContent(),
              margin: const HtmlMargin.horizontalAuto(
                top: HtmlLength.px(0),
                bottom: HtmlLength.px(0),
              ),
              children: [
                // <h3>C O N T E N T S</h3>
                HtmlDiv(
                  margin: const HtmlMargin.only(
                    top: HtmlLength.px(16),
                    bottom: HtmlLength.px(16),
                  ),
                  textAlign: HtmlTextAlign.center,
                  children: const [
                    HtmlText(
                      'C O N T E N T S',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),

                // <div style="margin: 0 auto;">
                HtmlDiv(
                  children: [
                    // <div>
                    HtmlDiv(
                      children: [
                        // <div style="display: flex;margin:0 auto;">
                        HtmlDiv(
                          display: HtmlDisplay.flex,
                          alignItems: HtmlAlignItems.flexStart,
                          children: [
                            // <div> (numbers)
                            HtmlDiv(
                              children: const [
                                // <p>1</p> ... <p>7</p>
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [HtmlText('1')],
                                ),
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [HtmlText('2')],
                                ),
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [HtmlText('3')],
                                ),
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [HtmlText('4')],
                                ),
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [HtmlText('5')],
                                ),
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [HtmlText('6')],
                                ),
                                HtmlDiv(children: [HtmlText('7')]),
                              ],
                            ),

                            // <div> (titles)
                            HtmlDiv(
                              margin: const HtmlMargin.only(
                                left: HtmlLength.px(24),
                              ),
                              children: const [
                                // <p>Menthol Light的<span>红</span>蝶</p>
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [
                                    HtmlText('Menthol Light的'),
                                    HtmlText(
                                      '红',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    HtmlText('蝶'),
                                  ],
                                ),
                                // <p>Horizont Light的黑<span>蝶</span></p>
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [
                                    HtmlText('Horizont Light的黑'),
                                    HtmlText(
                                      '蝶',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                // <p>王与年迈的野<span>兽</span></p>
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [
                                    HtmlText('王与年迈的野'),
                                    HtmlText(
                                      '兽',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                // <p>甜蜜的<span>血</span>腥情人节</p>
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [
                                    HtmlText('甜蜜的'),
                                    HtmlText(
                                      '血',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    HtmlText('腥情人节'),
                                  ],
                                ),
                                // <p>Maestro的条件</p>
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [HtmlText('Maestro的条件')],
                                ),
                                // <p>镜之<span>国</span>的地图</p>
                                HtmlDiv(
                                  margin: HtmlMargin.only(
                                    bottom: HtmlLength.px(12),
                                  ),
                                  children: [
                                    HtmlText('镜之'),
                                    HtmlText(
                                      '国',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    HtmlText('的地图'),
                                  ],
                                ),
                                // <p>当<span>春</span>天来临，你会——</p>
                                HtmlDiv(
                                  children: [
                                    HtmlText('当'),
                                    HtmlText(
                                      '春',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    HtmlText('天来临，你'),
                                    HtmlDiv(
                                      // Treat the trailing punctuation as an
                                      // atomic inline box so it won't be
                                      // orphaned at line start.
                                      display: HtmlDisplay.inline,
                                      width: MaxContent(),
                                      children: [HtmlText('会吗吗吗')],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
