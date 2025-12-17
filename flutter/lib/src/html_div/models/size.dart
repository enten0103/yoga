/// Size model used by [HtmlDiv] and [HtmlImage].
///
/// This is intentionally small and CSS-inspired.
abstract class HtmlSize {
  const HtmlSize();
}

class FixedSize extends HtmlSize {
  final double value;
  const FixedSize(this.value);
}

class PercentSize extends HtmlSize {
  final double value;
  const PercentSize(this.value);
}

class MaxContent extends HtmlSize {
  const MaxContent();
}

class MinContent extends HtmlSize {
  const MinContent();
}

class FitContent extends HtmlSize {
  const FitContent();
}

class AutoSize extends HtmlSize {
  const AutoSize();
}
