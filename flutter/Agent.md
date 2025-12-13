# Agent Status Report

**Date:** 2025-12-13
**Project:** Flutter HTML/CSS Layout Engine

## Project Description
This project aims to implement a rendering model in Flutter that mimics HTML and CSS layout behaviors. The goal is to provide widgets that allow developers to build UIs using familiar web concepts like `div`, `border`, `box-sizing`, and flexible sizing units (pixels, percentages, auto), plus common decoration and paint-time effects.

## Architecture

### Core Components (`lib/`)
*   **`HtmlDiv`**: The fundamental building block widget. It extends `MultiChildRenderObjectWidget` and creates a `RenderHtmlDiv` render object.
*   **`RenderHtmlDiv`**: Handles the layout and painting logic.
    *   **Layout**: Calculates dimensions based on `HtmlSize` strategies (Fixed, Percent, Auto, Min/Max/FitContent) and `HtmlBoxSizing` rules.
    *   **Painting**: Draws borders/background/box-shadow and supports paint-only transforms.
*   **`HtmlSize`**: Abstract class defining sizing strategies.
*   **`HtmlBorder`**: Defines border properties (width, style, color).
*   **`HtmlBorderImage`**: CSS `border-image` 数据模型与绘制支持。
    *   **API**: `source(image) / slice / width / outset / repeatX / repeatY`。
    *   **Rendering**: 基于 9-slice（四角 + 四边 + 可选 fill 中心）绘制；支持 `stretch/repeat/round/space`；与 `borderRadius` clip 对齐。
*   **Yoga Integration**: The project leverages `yoga_ffi.dart` for underlying Flexbox layout capabilities, providing a bridge to the C++ Yoga layout engine.

### Unified Value Types
*   **`HtmlLength`**: Unifies length-like values across APIs.
    *   Units: `px`, `%`, `auto`.
    *   Resolution: `resolvePx(reference: ...)`.
*   **`HtmlLengthOffset`**: A 2D pair of `HtmlLength` (`dx/dy`) used for offsets like background-position, box-shadow offset, and transform-origin offset.

### CSS-like Models
*   **`HtmlBackground`**: `color`, `image`, `repeatX/repeatY`, `size` (`auto/contain/cover/explicit`), `position` (alignment + `HtmlLengthOffset`), `clip` (`borderBox/paddingBox`).
*   **`HtmlBoxShadow`**: Multi-layer shadows (supports percentage offsets via `HtmlLengthOffset`; inset is approximated).
*   **`HtmlTransform`**: Paint-only transform (layout unaffected); hit-test uses inverse transform; origin is `originAlignment + originOffset(HtmlLengthOffset)`.
*   **`HtmlMargin`**: Supports px/%/auto via `HtmlLength`, vertical margin collapsing, and horizontal `auto` distribution.

### Testing (`test/`)
*   Unit and Widget tests ensure that layout calculations match CSS specifications.
*   Specific tests for `box-sizing` (border-box vs content-box) and border rendering.

### Example App (`example/`)
*   A gallery application demonstrating various layout scenarios.
*   Each example page corresponds to a specific test case to ensure visual verification matches logic verification.

## Current Progress

### Completed Features
1.  **`HtmlDiv` Widget**:
    *   Basic block layout behavior.
    *   Support for `width` and `height` properties.
2.  **Sizing Models**:
    *   `FixedSize`: Pixel-perfect sizing.
    *   `PercentSize`: Relative sizing to parent.
    *   `AutoSize`: Adapts to content or constraints.
    *   `MinContent`, `MaxContent`, `FitContent`: Intrinsic sizing logic.
3.  **Borders & Decoration**:
    *   `border` property support.
    *   Styles: `solid`, `dashed`, `dotted`, `double`, `hidden`.
    *   Widths: Fixed, Percent, Keywords (thin, medium, thick).
    *   **Mixed Borders**: Support for individual side configuration (top, right, bottom, left).
    *   **Border Radius**: Support for rounded corners (uniform and individual) with `HtmlBorderRadius`.
    *   **Border Image**: 支持 CSS `border-image` 系列能力（`source/slice/width/outset/repeat`），并遵循 `border-style: hidden` 时不绘制。
4.  **Box Model**:
    *   `box-sizing` support:
        *   `content-box` (default): Width/Height applies to content only.
        *   `border-box`: Width/Height includes padding and border.
5.  **Quality Assurance**:
    *   Comprehensive test suite added.
    *   Example app updated with Chinese localization.
    *   `flutter analyze` 0 issues.
    *   Added tests for `border-image`（布局不受影响、圆角裁剪/绘制不报错）与 example 导航用例。

6.  **Background / Box Shadow / Transform / Margin**:
    *   **Background**: image tiling, size/position (px/%), clip and borderRadius-safe painting.
    *   **Box-Shadow**: multiple layers; percentage offset support; inset approximation.
    *   **Transform**: paint-only transform + correct hit testing.
    *   **Margin**: vertical margin collapsing; horizontal `auto`.

### Recent Work Summary (2025-12)
*   **API Implementation**: 在 `flutter/lib/html_div.dart` 新增 `HtmlBorderImage` 与相关 value types（px/%/number/auto、fill）。
*   **Render Integration**: `RenderHtmlDiv` 通过 `ImageProvider.resolve` 接入 `ImageStream`，按 9-slice 绘制边框图片并支持 `repeatX/repeatY`。
*   **Example Gallery**: 新增 `Border-Image` 示例页并在首页增加入口；example `pubspec.yaml` 注册 `assets/wallhaven.png` 作为样例资源。
*   **Tests**: 新增 `flutter/test/border_image_test.dart`；更新 example 的 `widget_test.dart` 与当前 UI 保持一致。

*   **Unified lengths**: Migrated margin/background-size/background-position/transform-origin/box-shadow offset to `HtmlLength` / `HtmlLengthOffset`.
*   **Percent rules**:
    *   `margin: %` resolves against containing block width (CSS behavior).
    *   `background-position` offset resolves against target rect width/height.
    *   `background-size: explicit` resolves width/height against target rect width/height respectively.
    *   `transform-origin` and `box-shadow` offsets resolve against the box size.

### Next Steps
*   Implement `padding` support in `HtmlDiv`.
*   Integrate `HtmlDiv` more deeply with Yoga FFI for complex Flexbox layouts (row/column directions, alignment).
*   Extend `border-image` 覆盖面：补齐更多 CSS 组合边界（极端 slice 值、非均匀 width/outset、与 mixed border 的交互）。

