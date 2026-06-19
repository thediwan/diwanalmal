/// A single point in a chart series — label on the axis + numeric value.
///
/// Use [ChartPointKind] to mark semantic extremes so the chart can apply
/// the correct financial color without coupling the mapper to AppColors.
enum ChartPointKind {
  /// Standard data point — no special highlight.
  normal,

  /// Highest-spend bar — rendered in AppColors.expense (risk signal).
  max,

  /// Lowest non-zero bar — rendered in muted sky-blue.
  min,
}

class ChartSeriesPoint {
  const ChartSeriesPoint({
    required this.label,
    required this.value,
    this.kind = ChartPointKind.normal,
  });

  final String label;
  final double value;
  final ChartPointKind kind;

  bool get isMax => kind == ChartPointKind.max;
  bool get isMin => kind == ChartPointKind.min;

  /// Tag max/min across a list of points.
  ///
  /// Points with value == 0 are never tagged min — a zero spend day
  /// carries no semantic meaning in fintech.
  static List<ChartSeriesPoint> fromValues({
    required List<String> labels,
    required List<double> values,
  }) {
    assert(labels.length == values.length);

    if (labels.isEmpty) return const [];

    double? maxVal;
    double? minVal;
    int maxIdx = -1;
    int minIdx = -1;

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      if (v <= 0) continue;
      if (maxVal == null || v > maxVal) {
        maxVal = v;
        maxIdx = i;
      }
      if (minVal == null || v < minVal) {
        minVal = v;
        minIdx = i;
      }
    }

    return List.generate(labels.length, (i) {
      final ChartPointKind kind;
      if (i == maxIdx) {
        kind = ChartPointKind.max;
      } else if (i == minIdx && minIdx != maxIdx) {
        kind = ChartPointKind.min;
      } else {
        kind = ChartPointKind.normal;
      }
      return ChartSeriesPoint(label: labels[i], value: values[i], kind: kind);
    });
  }
}
