import 'package:flutter/material.dart';

class ThemeModePicker extends StatefulWidget {
  const ThemeModePicker({
    required this.themeMode,
    required this.onChanged,
    super.key,
  });

  final ThemeMode themeMode;

  final ValueChanged<ThemeMode> onChanged;

  @override
  State<ThemeModePicker> createState() => _ThemeModePickerState();
}

class _ThemeModePickerState extends State<ThemeModePicker> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      style: const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      onPressed: () {
        widget.onChanged(
          widget.themeMode == ThemeMode.light
              ? ThemeMode.dark
              : ThemeMode.light,
        );
      },
      icon: CustomPaint(
        size: const Size.square(24),
        painter: _IconPainter(
          color: IconTheme.of(context).color!,
        ),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // The following code is generated from SVG by https://fluttershapemaker.com.
    final path = Path()
      ..moveTo(3, 12)
      ..arcToPoint(
        const Offset(21, 12),
        radius: const Radius.elliptical(9, 9),
        largeArc: true,
        clockwise: false,
      )
      ..arcToPoint(
        const Offset(3, 12),
        radius: const Radius.elliptical(9, 9),
        largeArc: true,
        clockwise: false,
      )
      ..moveTo(12, 3)
      ..lineTo(12, 21)
      ..moveTo(12, 9)
      ..lineTo(16.65, 4.35)
      ..moveTo(12, 14.3)
      ..lineTo(19.37, 6.93)
      ..moveTo(12, 19.6)
      ..lineTo(20.85, 10.75);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) => oldDelegate.color != color;
}
