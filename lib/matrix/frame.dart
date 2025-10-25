part of 'matrix.dart';

/// {@template frame}
/// A 2D array where each value represents the brightness of a [Matrix] dot
/// (0 = off, 1 = full brightness).
/// {@endtemplate}
extension type Frame._(List<List<double>> data) {
  /// {@macro frame}
  factory Frame(List<List<double>> data) {
    assert(data.isNotEmpty, 'Data must not be empty');
    final refWidth = data.first.length;
    for (final row in data) {
      assert(row.isNotEmpty, 'Row must not be empty');
      assert(
        row.length == refWidth,
        'Rows has to have equal number of elements',
      );
    }
    return Frame._(data);
  }

  /// Frame width.
  int get width => data.first.length;

  /// Frame height.
  int get height => data.length;

  /// Frame size.
  Size get size => Size(width.toDouble(), height.toDouble());

  /// Returns a copy of the frame.
  Frame copy() => Frame(List.generate(height, (i) => data[i].toList()));

  /// Frame row.
  List<double> operator [](int i) => data[i];
}
