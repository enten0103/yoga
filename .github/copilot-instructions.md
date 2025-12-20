# Copilot instructions (Yoga repo)

## Big picture (monorepo)
- `yoga/`: C++20 flexbox layout engine (the source of truth).
- Bindings/consumers:
  - `flutter/`: Flutter plugin + HTML/CSS-like layout/rendering engine (Dart) backed by Yoga via FFI.
  - `javascript/`: `yoga-layout` WebAssembly bindings (Emscripten + CMake; uses `just-scripts`).
  - `java/`: Android/JNI bindings + Gradle build.
- Tests + tooling:
  - `tests/`: C++ unit tests (`yogatests`).
  - `gentest/`: generates many layout tests from HTML fixtures.

## Critical workflows
- C++ unit tests:
  - Windows: `unit_tests.bat [Debug|Release]` (builds `tests/build` then runs `yogatests.exe`).
  - macOS/Linux: `./unit_tests [Debug|Release]`.
  - VS Code debugging is wired via `.vscode/launch.json` + the “Build Unit Tests” task.
- Generated tests (layout fixtures → expected results):
  - Add fixtures under `gentest/fixtures/`.
  - From repo root: `yarn install`, then `yarn gentest` (uses Selenium/Chrome to render fixtures).

## Focus: `flutter/` (team priority)
- Public surface:
  - `flutter/lib/flutter_yoga.dart` exports `flutter/lib/html_div.dart`.
  - `flutter/lib/html_div.dart` declares `library;` and composes implementation via `part` files.
- Architecture/conventions:
  - Models in `flutter/lib/src/html_div/models/*`, re-exported by `flutter/lib/src/html_div/models/models.dart`.
    - Use `HtmlLength` / `HtmlLengthOffset` for px/%/auto values.
    - Percent margin/padding resolves against containing block width.
  - Widgets in `flutter/lib/src/html_div/widgets.dart` (`HtmlDiv`, `HtmlImage`) map 1:1 to render object inputs.
  - Render behavior is split into `flutter/lib/src/html_div/renders/*` (layout/paint/hit-test/image streams).
  - Add a CSS-like feature using the existing flow: model → `HtmlDiv`/`updateRenderObject` → `RenderHtmlDiv` field+setter → behavior in the relevant `part`; use `markNeedsLayout()` vs `markNeedsPaint()` like neighboring setters.
- Flutter commands:
  - Tests: `cd flutter && flutter test`.
  - Example app: `cd flutter/example && flutter run` (shortcut: `yarn windows`).

## Flutter FFI + Windows notes
- Yoga FFI is in `flutter/lib/src/yoga_ffi.dart`.
  - Android loads `libyoga.so`.
  - Windows loads `flutter_yoga_plugin.dll` and checks common local build output paths.
  - Override DLL path via `FLUTTER_YOGA_DLL_PATH`.
  - Other platforms currently throw `UnimplementedError('Platform not supported')` (higher layers may disable Yoga and continue).

## JavaScript/WASM notes
- `javascript/` uses `just.config.cjs` to fetch/activate Emscripten into `javascript/.emsdk`, then runs CMake builds.
- `yoga-layout` users must manually free nodes/configs created via `Yoga.*.create()` (see `javascript/README.md`).
