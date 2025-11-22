# Flutter Yoga

A powerful Flutter plugin that brings the [Yoga Layout](https://yogalayout.com/) engine to Flutter. This plugin allows you to build complex, flexible layouts using the same Flexbox API found in React Native and CSS, with additional enhancements for Web-like behavior.

## Features

*   **Full Flexbox Support**: Implements the complete Flexbox specification via Yoga.
*   **Web Defaults**: Optional mode to match Web/CSS default values (e.g., `flexShrink: 1`).
*   **Margin Collapsing**: Supports CSS-style margin collapsing (Sibling, Parent-Child, and Negative margins).
*   **Display Properties**: Supports `block`, `inline`, `inline-block`, and `none`.
*   **High Performance**: Uses FFI to bind directly to the native C++ Yoga library.

## Installation

Add `flutter_yoga` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_yoga:
    path: ./ # Or git url
```

## Basic Usage

The core widget is `YogaLayout`, which acts as a container. Children can be wrapped in `YogaItem` to control their specific layout properties.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_yoga/flutter_yoga.dart';

class MyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return YogaLayout(
      flexDirection: YGFlexDirection.column,
      justifyContent: YGJustify.center,
      alignItems: YGAlign.center,
      width: 300,
      height: 300,
      children: [
        YogaItem(
          width: 100,
          height: 100,
          margin: EdgeInsets.only(bottom: 20),
          child: Container(color: Colors.red),
        ),
        YogaItem(
          flexGrow: 1,
          width: 100,
          child: Container(color: Colors.blue),
        ),
      ],
    );
  }
}
```

## Advanced Features

### 1. Web Defaults

By default, Yoga uses values that differ slightly from the Web (e.g., `flexShrink` defaults to 0). You can enable Web-like defaults by setting `useWebDefaults: true`.

```dart
YogaLayout(
  useWebDefaults: true, // flexShrink defaults to 1
  children: [
    // ...
  ],
)
```

### 2. Margin Collapsing

CSS-style margin collapsing is not enabled by default in Yoga. You can enable it to replicate Web behavior where vertical margins between adjacent elements merge.

Supported Collapsing Types:
*   **Sibling Collapsing**: Margins between adjacent siblings merge.
*   **Parent-Child Collapsing**: Top/Bottom margins of a parent and its first/last child merge if there is no border/padding separating them.
*   **Negative Margins**:
    *   Positive + Positive = `max(a, b)`
    *   Negative + Negative = `min(a, b)` (Most negative)
    *   Positive + Negative = `a + b`

```dart
YogaLayout(
  enableMarginCollapsing: true,
  flexDirection: YGFlexDirection.column,
  children: [
    YogaItem(
      margin: EdgeInsets.only(bottom: 20),
      child: Container(color: Colors.red),
    ),
    YogaItem(
      margin: EdgeInsets.only(top: 20), // Collapses with above: Result is 20px gap
      child: Container(color: Colors.blue),
    ),
  ],
)
```

### 3. Display Properties

`YogaItem` supports a `display` property to control layout behavior similar to CSS.

*   **`YogaDisplay.flex`** (Default): Standard Flexbox behavior.
*   **`YogaDisplay.none`**: The item is removed from the layout (takes up no space).
*   **`YogaDisplay.block`**: Forces the item to take up 100% width of its parent (unless width is explicitly set).
*   **`YogaDisplay.inline` / `YogaDisplay.inlineBlock`**: The item's width is determined by its content (auto).

```dart
YogaLayout(
  flexDirection: YGFlexDirection.row,
  flexWrap: YGWrap.wrap,
  children: [
    YogaItem(
      display: YogaDisplay.block, // Takes full width, forcing a new line
      child: Text("Block Item"),
    ),
    YogaItem(
      display: YogaDisplay.inlineBlock, // Takes content width
      child: Text("Inline Item 1"),
    ),
    YogaItem(
      display: YogaDisplay.inlineBlock, // Sits next to Item 1
      child: Text("Inline Item 2"),
    ),
    YogaItem(
      display: YogaDisplay.none, // Hidden
      child: Text("Hidden Item"),
    ),
  ],
)
```

## API Reference

### YogaLayout

| Property | Type | Default | Description |
|---|---|---|---|
| `flexDirection` | `int` | `column` | Direction of the main axis (`row`, `column`, etc.). |
| `justifyContent` | `int` | `flexStart` | Alignment along the main axis. |
| `alignItems` | `int` | `stretch` | Alignment along the cross axis. |
| `flexWrap` | `int` | `noWrap` | Whether children wrap to multiple lines. |
| `useWebDefaults` | `bool` | `false` | Enables Web-like default values. |
| `enableMarginCollapsing` | `bool` | `false` | Enables CSS margin collapsing logic. |

### YogaItem

| Property | Type | Description |
|---|---|---|
| `flexGrow` | `double` | How much the item should grow relative to others. |
| `flexShrink` | `double` | How much the item should shrink relative to others. |
| `flexBasis` | `double` | Initial main size of the item. |
| `display` | `YogaDisplay` | `flex`, `none`, `block`, `inline`, `inlineBlock`. |
| `width` / `height` | `double` | Explicit size. |
| `margin` | `EdgeInsets` | Outer spacing. |
| `borderWidth` | `EdgeInsets` | Border width (affects layout). |
| `alignSelf` | `int` | Overrides `alignItems` for this specific item. |

## License

MIT

