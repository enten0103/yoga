# Copilot instructions (Yoga repo)

## Focus: `flutter/` (team priority)
- The `flutter/` folder is a Flutter plugin package; the main value is the HTML/CSS-like layout & rendering engine implemented in Dart and backed by Yoga via FFI.
- Public surface:
  - `flutter/lib/flutter_yoga.dart` exports `flutter/lib/html_div.dart`.
  - `flutter/lib/html_div.dart` defines the `library;` and composes the implementation via `part` files.

## Flutter architecture (how code is organized)
- Widgets live in `flutter/lib/src/html_div/widgets.dart` (`HtmlDiv`, `HtmlImage`) and map 1:1 to the render object inputs.
- Value models live in `flutter/lib/src/html_div/models/*` and are re-exported by `flutter/lib/src/html_div/models/models.dart`.
  - Use `HtmlLength` / `HtmlLengthOffset` for px/%/auto and 2D offsets (`models/length.dart`).
  - Margin/padding percent resolves against containing block width (`models/margin_padding.dart`).
- Rendering/layout is split by concern into `flutter/lib/src/html_div/renders/*`:
  - Yoga layout: `renders/html_div_layout_yoga.dart` (tries a shared `Yoga()` instance; disables Yoga if unavailable).
  - Paint: border/background/box-shadow (`renders/html_div_*_paint.dart`).
  - Transform hit testing: `renders/html_div_transform_hit_test.dart`.
  - Image stream lifecycle: `renders/html_div_image_streams.dart`.

## Flutter workflows
- Run Flutter unit/widget tests: `cd flutter && flutter test` (tests live in `flutter/test/*_test.dart`).
- Run the example app: `cd flutter/example && flutter run` (repo root shortcut: `yarn windows`).

## FFI + platform notes (important for Windows dev)
- The Yoga FFI layer is `flutter/lib/src/yoga_ffi.dart`.
  - Android loads `libyoga.so`.
  - Windows loads `flutter_yoga_plugin.dll` and also checks common build output paths.
  - You can override the DLL location via env var `FLUTTER_YOGA_DLL_PATH`.
  - Other platforms currently throw `UnimplementedError('Platform not supported')` (higher layers may fall back by marking Yoga unavailable).

## Conventions for adding/changing features
- Add a CSS-like capability by following the existing “model -> widget -> render” flow:
  1) Add/extend a model in `flutter/lib/src/html_div/models/` and export it from `models/models.dart`.
  2) Thread it through `HtmlDiv` (constructor + `updateRenderObject`) and store it on `RenderHtmlDiv`.
  3) Implement behavior in the appropriate render `part` file; use `markNeedsLayout()` vs `markNeedsPaint()` consistently with existing setters.
  4) Add/adjust tests under `flutter/test/` (see `background_test.dart`, `margin_test.dart`, `border_image_test.dart`).
- Image provider quirks: header-byte probing and scale hints go through `flutter/lib/src/image_size_hint.dart` with conditional IO/web implementations; update both sides if adding provider support.

## When you must touch the C++ core
- Only change `yoga/` if the Flutter FFI boundary requires it; C++ unit tests are under `tests/` and runnable via `unit_tests.bat` / `./unit_tests`.
