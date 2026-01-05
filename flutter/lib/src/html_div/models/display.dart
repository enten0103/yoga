enum HtmlDisplay { block, inline, flex }

enum HtmlFlexDirection { row, rowReverse, column, columnReverse }

enum HtmlJustifyContent {
  flexStart,
  center,
  flexEnd,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}

enum HtmlAlignItems { stretch, flexStart, center, flexEnd, baseline }

enum HtmlAlignSelf { auto, stretch, flexStart, center, flexEnd, baseline }

enum HtmlFlexWrap { noWrap, wrap, wrapReverse }

enum HtmlTextAlign { start, center, end, justify }

/// CSS-like overflow-wrap.
///
/// - [normal]: do not create extra line break opportunities.
/// - [anywhere]: allow breaking long unbroken runs (similar to CSS
///   `overflow-wrap:anywhere` / `word-break:break-all` for our simplified model).
enum HtmlOverflowWrap { normal, anywhere }
