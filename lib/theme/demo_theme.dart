import 'package:elevenlabs_ui_matrix/theme/theme.dart';
import 'package:flutter/material.dart';

abstract class DemoTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: const ColorScheme.light(),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      extensions: const [
        MatrixColorsExtension(
          on: MatrixColors.lightOn,
          off: MatrixColors.lightOff,
        ),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      extensions: const [
        MatrixColorsExtension(
          on: MatrixColors.darkOn,
          off: MatrixColors.darkOff,
        ),
      ],
    );
  }
}

extension DemoThemeX on BuildContext {
  MatrixColorsExtension get matrixColors =>
      Theme.of(this).extension<MatrixColorsExtension>()!;
}
