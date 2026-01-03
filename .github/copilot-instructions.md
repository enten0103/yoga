# Copilot instructions (Yoga Flutter / html_div)

本仓库是 Yoga 的 monorepo；团队日常工作重点在 `flutter/`：用 Flutter 实现 HTML/CSS-like 的 `HtmlDiv/HtmlImage/HtmlText`，其中 `display:flex` 通过 Yoga FFI 走 flexbox。

## 入口与结构（先看这些）
- `flutter/lib/html_div.dart`: `library;` + `part` 组装（widgets/render/models 辅助）。
- `flutter/lib/src/html_div/widgets.dart`: `HtmlDiv`/`HtmlImage` widget → `RenderHtmlDiv/RenderHtmlImage` 输入一一对应。
- `flutter/lib/src/html_div/models/*` + `models/models.dart`: CSS-like 值对象（`HtmlLength`/`HtmlLengthOffset`/box model/background/border/border-image 等）。
- `flutter/lib/src/html_div/renders/*`: RenderHtmlDiv 的分区实现：
  - Yoga flex: `renders/html_div_layout_yoga.dart`
  - 非 flex 的统一行内排版: `renders/html_div_inline_paragraph.dart`
  - 背景/边框/阴影/transform: `renders/html_div_*_paint.dart`, `renders/html_div_transform_hit_test.dart`
  - 图片流: `renders/html_div_image_streams.dart`

## html_div 的关键约定（避免踩坑）
- `HtmlDiv` 会规范化 children：`Text` → `HtmlText`；“透明 inline wrapper”（inline 且样式全默认）会被拍扁，除非它有 key。
- `RenderHtmlDiv` 布局分流：
  - `display:flex`：优先复用 `_sharedYoga`；失败后设置 `_sharedYogaUnavailable`，后续直接降级（避免重复异常成本）。
  - 非 flex：使用 `TextPainter + placeholder spans` 做“统一 paragraph”来获得更像浏览器的换行/基线；`textIndent` 通过首个 placeholder 实现。
  - “break-all”：仅对长且无空白、且非 CJK 的文本注入 `\u200B`（Windows 字形/测量稳定性依赖这一点）。
- 百分比规则：margin/padding 的 `%` 按 containing block 的“宽度”解析（CSS 行为）。
- 图片：`HtmlImage.naturalPixelSize/naturalPixelScale` 可避免异步探测；否则走 `flutter/lib/src/image_size_hint*.dart`。

## 如何加/改一个 CSS-like 能力（按现有管线走）
`models/*` → 在 `HtmlDiv/HtmlImage` 增参数 → `updateRenderObject` 传入 → `Render*` 增字段+setter → 放到对应 `renders/html_div_*.dart` 分区实现（按邻近 setter 选择 `markNeedsLayout()` vs `markNeedsPaint()`）。

## 测试与示例（复现/回归优先看）
- 单测：`flutter/test/*.dart`（高密度覆盖 box model、border-image、inline 文本/图片换行、基线等）。
  - 行内排版/图片换行：`flutter/test/inline_text_image_wrap_test.dart`
  - text-indent/line-height/测量对齐：`flutter/test/display_inline_test.dart` + `flutter/lib/src/html_div/text_measure.dart` 的 `measureTextLineCount`
- Example Gallery：`flutter/example/lib/main.dart` + `flutter/example/lib/pages/*`（大部分页面都有对应 HTML 对照在 `flutter/example/html/pages/*`）。
- 集成测试：`flutter/example/integration_test/inline_text_align_page_test.dart`（用 `RepaintBoundary` 像素扫描验证 text-align/inline 混排）。

## 常用命令（Windows）
- Flutter 单测：`cd flutter && flutter test`
- Example 运行：`cd flutter/example && flutter run`（或 repo 根目录 `yarn windows`）
- Example widget tests：`cd flutter/example && flutter test`
- Example 集成测试：`cd flutter/example && flutter test integration_test/inline_text_align_page_test.dart`

## Yoga FFI（Windows）
- 入口：`flutter/lib/src/yoga_ffi.dart`；Windows 动态库默认 `flutter_yoga_plugin.dll`，可用环境变量 `FLUTTER_YOGA_DLL_PATH` 覆盖。
