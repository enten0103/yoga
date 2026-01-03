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

## CSS 对齐与测试原则（HtmlImage sizing）
- 默认 natural size 一定会声明：测试里给 `HtmlImage.naturalPixelSize/naturalPixelScale`，避免异步 header probing 影响布局时序。
- 预期对齐 CSS/MDN（replaced element sizing 的最小集合）：
  - `width/height` 同时指定：允许拉伸（不强制保持比例）。
  - 只指定一个轴、另一个轴为 `auto`：按 natural ratio 推导 `auto` 轴，且必须用“父约束夹紧后的 used 尺寸”推导（避免 clamp 后仍按原始 CSS 值推导）。
  - `auto/auto`：使用 natural logical size（受父约束影响时保持比例收缩）。
  - `%`：仅在对应轴 parent constraint bounded 时解析（否则按 `auto` 路径处理）。
- 测试结构：优先用 `HtmlDiv/HtmlText/HtmlImage` 搭结构；若测试目标是复现 Flutter `BoxConstraints`（如 maxWidth/maxHeight 夹紧），允许最小 `SizedBox/ConstrainedBox` 作为“约束夹具”。

## 测试与示例（复现/回归优先看）
- 测试结构约定：能用 `HtmlDiv/HtmlText/HtmlImage` 搭出来的布局结构，优先用它们；尽量少用 `SizedBox/Container/DecoratedBox/Center` 等 Flutter 原生布局组件（保留 `Directionality/MaterialApp` 这类测试外壳即可；若需要施加真实 Flutter `BoxConstraints` 来复现父约束夹紧，可用最小的 `SizedBox/ConstrainedBox` 作为“约束夹具”）。
- 单测：`flutter/test/*.dart`（高密度覆盖 box model、border-image、inline 文本/图片换行、基线等）。
  - 行内排版/图片换行：`flutter/test/inline_text_image_wrap_test.dart`
  - text-indent/line-height/测量对齐：`flutter/test/display_inline_test.dart` + `flutter/lib/src/html_div/text_measure.dart` 的 `measureTextLineCount`
  - HtmlImage 基线回归（inline wrapper + line-height）：`flutter/test/html_image_inline_baseline_test.dart`
- Example Gallery：`flutter/example/lib/main.dart` + `flutter/example/lib/pages/*`（大部分页面都有对应 HTML 对照在 `flutter/example/html/pages/*`）。
- 集成测试：`flutter/example/integration_test/inline_text_align_page_test.dart`（用 `RepaintBoundary` 像素扫描验证 text-align/inline 混排）。

## 常用命令（Windows）
- Flutter 单测：`cd flutter && flutter test`
- Example 运行：`cd flutter/example && flutter run`（或 repo 根目录 `yarn windows`）
- Example widget tests：`cd flutter/example && flutter test`
- Example 集成测试：`cd flutter/example && flutter test integration_test/inline_text_align_page_test.dart`

## Yoga FFI（Windows）
- 入口：`flutter/lib/src/yoga_ffi.dart`；Windows 动态库默认 `flutter_yoga_plugin.dll`，可用环境变量 `FLUTTER_YOGA_DLL_PATH` 覆盖。
