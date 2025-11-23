# Flutter Yoga

A powerful Flutter plugin that brings the [Yoga Layout](https://yogalayout.com/) engine to Flutter. This plugin allows you to build complex, flexible layouts using the same Flexbox API found in React Native and CSS, with additional enhancements for Web-like behavior.

## Features

*   **Full Flexbox Support**: Implements the complete Flexbox specification via Yoga (Flex Direction, Wrap, Justify Content, Align Items, etc.).
*   **CSS-like Styling**:
    *   **Borders**: Support for `solid`, `dashed`, `dotted` styles, and **Border Images**.
    *   **Border Radius**: Full support for rounded corners, including **percentage values** (e.g., `50%` for circles) and individual corner control.
    *   **Box Shadows**: Support for multiple shadows with blur, spread, and offset.
    *   **Box Sizing**: Switch between `border-box` and `content-box`.
*   **Web Defaults**: Optional mode to match Web/CSS default values (e.g., `flexShrink: 1`).
*   **Margin Collapsing**: Supports CSS-style margin collapsing (Sibling, Parent-Child, and Negative margins).
*   **Display Properties**: Supports `block`, `inline`, `inline-block`, and `none`.
*   **Overflow Control**: Support for `overflow: hidden` to clip content to rounded borders.
*   **High Performance**: Uses FFI to bind directly to the native C++ Yoga library.

## Installation

### Option 1: From GitHub (Recommended)

Add `flutter_yoga` to your `pubspec.yaml` using the GitHub repository:

```yaml
dependencies:
  flutter_yoga:
    git:
      url: https://github.com/enten0103/yoga.git
      path: flutter
      ref: main  # Or specific commit/tag
```

### Option 2: Local Path

If you have cloned the repository locally:

```yaml
dependencies:
  flutter_yoga:
    path: path/to/yoga/flutter
```

### After Installation

Run `flutter pub get` to fetch the package, then import it in your Dart files:

```dart
import 'package:flutter_yoga/flutter_yoga.dart';
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
      width: YogaValue.point(300),
      height: YogaValue.point(300),
      children: [
        YogaItem(
          width: YogaValue.point(100),
          height: YogaValue.point(100),
          margin: YogaEdgeInsets.only(bottom: YogaValue.point(20)),
          child: Container(color: Colors.red),
        ),
        YogaItem(
          flexGrow: 1,
          width: YogaValue.point(100),
          child: Container(color: Colors.blue),
        ),
      ],
    );
  }
}
```

## Styling & Layout

### 1. Borders & Radius

Flutter Yoga supports advanced border styling, including non-solid styles and percentage-based radii.

```dart
YogaItem(
  width: YogaValue.point(150),
  height: YogaValue.point(150),
  border: YogaBorder(
    // Dashed Border
    all: YogaBorderSide(
      width: 4,
      color: Colors.purple,
      style: YogaBorderStyle.dashed,
    ),
    // 50% Radius (Circle)
    borderRadius: YogaBorderRadius.all(YogaValue.percent(50)),
  ),
  child: Container(color: Colors.purple.shade50),
)
```

### 2. Overflow & Clipping

You can clip content to the border radius using `overflow: hidden`.

```dart
YogaItem(
  width: YogaValue.point(100),
  height: YogaValue.point(100),
  overflow: YogaOverflow.hidden, // Clips child to border radius
  border: YogaBorder(
    borderRadius: YogaBorderRadius.circular(20),
  ),
  child: Image.network('...'),
)
```

### 3. Box Sizing

Control how width and height are calculated.

*   **`YogaBoxSizing.borderBox`** (Default): Size includes padding and border.
*   **`YogaBoxSizing.contentBox`**: Size is content only; padding and border are added on top.

```dart
YogaItem(
  width: YogaValue.point(100),
  boxSizing: YogaBoxSizing.contentBox,
  border: YogaBorder(all: YogaBorderSide(width: 10)),
  // Total rendered width will be 120px (100 + 10 left + 10 right)
  child: ...,
)
```

### 4. Border Images

Full support for CSS `border-image`.

```dart
YogaItem(
  border: YogaBorder(
    image: YogaBorderImage(
      source: NetworkImage('...'),
      slice: YogaEdgeInsets.all(YogaValue.point(30)),
      repeat: YogaBorderImageRepeat.round,
    ),
  ),
  child: ...,
)
```

## Web Compatibility Features

### 1. Web Defaults

By default, Yoga uses values that differ slightly from the Web (e.g., `flexShrink` defaults to 0). You can enable Web-like defaults by setting `useWebDefaults: true`.

```dart
YogaLayout(
  useWebDefaults: true, // flexShrink defaults to 1
  children: [ ... ],
)
```

### 2. Margin Collapsing

Enable CSS-style margin collapsing to replicate Web behavior where vertical margins between adjacent elements merge.

```dart
YogaLayout(
  enableMarginCollapsing: true,
  flexDirection: YGFlexDirection.column,
  children: [
    YogaItem(margin: YogaEdgeInsets.only(bottom: YogaValue.point(20))),
    YogaItem(margin: YogaEdgeInsets.only(top: YogaValue.point(20))),
    // Result: 20px gap (max of 20 and 20), not 40px.
  ],
)
```

### 3. Display Properties

*   **`YogaDisplay.flex`** (Default)
*   **`YogaDisplay.none`**: Removes item from layout.
*   **`YogaDisplay.block`**: Forces 100% width (unless set).
*   **`YogaDisplay.inline` / `YogaDisplay.inlineBlock`**: Width determined by content.

## API Reference

### YogaLayout

| Property | Type | Default | Description |
|---|---|---|---|
| `flexDirection` | `int` | `column` | `YGFlexDirection.row`, `column`, `rowReverse`, `columnReverse`. |
| `justifyContent` | `int` | `flexStart` | `YGJustify.flexStart`, `center`, `spaceBetween`, etc. |
| `alignItems` | `int` | `stretch` | `YGAlign.stretch`, `flexStart`, `center`, etc. |
| `flexWrap` | `int` | `noWrap` | `YGWrap.noWrap`, `wrap`, `wrapReverse`. |
| `width` / `height` | `YogaValue` | `auto` | Explicit size of the container. |
| `padding` | `YogaEdgeInsets` | `zero` | Padding inside the container. |
| `useWebDefaults` | `bool` | `false` | Enables Web-like default values. |
| `enableMarginCollapsing` | `bool` | `false` | Enables CSS margin collapsing logic. |

### YogaItem

| Property | Type | Description |
|---|---|---|
| `flexGrow` | `double` | Growth factor. |
| `flexShrink` | `double` | Shrink factor. |
| `flexBasis` | `double` | Initial main size. |
| `display` | `YogaDisplay` | Layout behavior (`flex`, `block`, `inline`, `none`). |
| `width` / `height` | `YogaValue` | Explicit size (`point`, `percent`, `auto`). |
| `margin` | `YogaEdgeInsets` | Outer spacing. |
| `border` | `YogaBorder` | Border styling, radius, and image. |
| `boxSizing` | `YogaBoxSizing` | `borderBox` or `contentBox`. |
| `boxShadow` | `List<YogaBoxShadow>` | List of shadows. |
| `overflow` | `YogaOverflow` | `visible` or `hidden` (clips content). |
| `alignSelf` | `int` | Overrides `alignItems` for this item. |

### Data Types

#### YogaValue
Represents a value in the Yoga layout system.
*   `YogaValue.point(double value)`: A specific number of points (pixels).
*   `YogaValue.percent(double value)`: A percentage of the parent's size.
*   `YogaValue.auto()`: Calculated automatically by the layout engine.
*   `YogaValue.undefined()`: The value is undefined.

#### YogaEdgeInsets
Immutable set of offsets in each of the four cardinal directions.
*   `YogaEdgeInsets.all(YogaValue value)`: All offsets are value.
*   `YogaEdgeInsets.symmetric({vertical, horizontal})`: Symmetrical vertical and horizontal offsets.
*   `YogaEdgeInsets.only({left, top, right, bottom})`: Only the given values non-zero.

#### YogaBorder
A border of a box, comprised of four sides and a border radius.
*   `top`, `right`, `bottom`, `left`: Physical sides (`YogaBorderSide`).
*   `start`, `end`: Logical sides (inline-start/end).
*   `all`: Global side overriding others if not specified.
*   `borderRadius`: `YogaBorderRadius` for corners.
*   `image`: `YogaBorderImage` for border images.

#### YogaBorderRadius
A set of immutable radii for each corner of a rectangle.
*   `YogaBorderRadius.all(YogaValue radius)`: All corners have the same radius.
*   `YogaBorderRadius.circular(double radius)`: Convenience for point values.
*   `topLeft`, `topRight`, `bottomLeft`, `bottomRight`: Individual corner radii.

#### YogaBorderSide
A side of a border.
*   `color`: Color of the side.
*   `width`: Width of the side.
*   `style`: `YogaBorderStyle` (solid, dashed, dotted, etc.).

#### YogaBoxShadow
A shadow cast by a box.
*   `color`: Color of the shadow.
*   `offsetDX`, `offsetDY`: Horizontal/Vertical offset (`YogaValue`).
*   `blurRadius`: Blur radius (`YogaValue`).
*   `spreadRadius`: Spread radius (`YogaValue`).

## License

MIT

