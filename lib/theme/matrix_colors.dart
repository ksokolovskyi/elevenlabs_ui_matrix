import 'package:flutter/material.dart';

abstract final class MatrixColors {
  static const lightOn = Color(0xFF0A0A0A);

  static const lightOff = Color(0xFF737373);

  static const darkOn = Color(0xFFFAFAFA);

  static const darkOff = Color(0xFFA1A1A1);
}

class MatrixColorsExtension extends ThemeExtension<MatrixColorsExtension> {
  const MatrixColorsExtension({
    required this.on,
    required this.off,
  });

  final Color on;

  final Color off;

  @override
  MatrixColorsExtension copyWith({
    Color? on,
    Color? off,
  }) {
    return MatrixColorsExtension(
      on: on ?? this.on,
      off: off ?? this.off,
    );
  }

  @override
  MatrixColorsExtension lerp(MatrixColorsExtension? other, double t) {
    if (other is! MatrixColorsExtension) {
      return this;
    }

    return MatrixColorsExtension(
      on: Color.lerp(on, other.on, t)!,
      off: Color.lerp(off, other.off, t)!,
    );
  }
}
