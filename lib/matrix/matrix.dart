import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

part 'frame.dart';
part 'frames.dart';

/// {@template matrix}
/// A retro dot-matrix display widget with circular cells and smooth
/// animations.
///
/// Perfect for retro displays, indicators, and audio visualizations.
/// {@endtemplate}
class Matrix extends StatefulWidget {
  /// {@macro matrix}
  Matrix({
    required this.size,
    required this.gap,
    required this.frames,
    required this.onColor,
    required this.offColor,
    this.fps = 12,
    this.play = true,
    this.loop = true,
    super.key,
  }) : assert(frames.isNotEmpty, 'At least one frame has to be specified.'),
       assert(() {
         final refSize = frames.first.size;
         for (final frame in frames.skip(1)) {
           if (frame.size != refSize) {
             return false;
           }
         }
         return true;
       }(), 'All frames must have identical size.'),
       assert(fps > 0, 'FPS value has to be greater than zero.');

  /// The size of the single dot.
  final double size;

  /// The space between dots, both horizontal and vertical.
  final double gap;

  /// Frames per second for animation.
  ///
  /// Defaults to `12`.
  final int fps;

  /// Color of the on dots.
  final Color onColor;

  /// Color of the off dots.
  final Color offColor;

  /// Whether animation should be played.
  ///
  /// This option will be ignored if the size of the [frames] list is 1.
  ///
  /// Defaults to `true`.
  final bool play;

  /// Whether to loop the animation.
  ///
  /// If this option is set to `false` then animation will be stopped as soon
  /// as all [frames] were shown.
  ///
  /// Defaults to `true`.
  final bool loop;

  /// List of frames for animation.
  ///
  /// At least one frame has to be specified.
  final List<Frame> frames;

  @override
  State<Matrix> createState() => _MatrixState();
}

class _MatrixState extends State<Matrix>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _collectionEquality = DeepCollectionEquality();

  late final Ticker _ticker = createTicker(_onTick);

  final _frameIndex = ValueNotifier<int>(0);

  Duration _elapsedTime = Duration.zero;
  var _accumulator = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant Matrix oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_collectionEquality.equals(oldWidget.frames, widget.frames) ||
        oldWidget.play != widget.play ||
        oldWidget.loop != widget.loop) {
      _frameIndex.value = 0;
      _elapsedTime = Duration.zero;
      _accumulator = 0;

      _updateAnimation();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _elapsedTime = Duration.zero;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _frameIndex.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    if (widget.play && widget.frames.length > 1) {
      if (!_ticker.isActive) {
        _ticker.start().ignore();
      }
    } else {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsedTime) {
    assert(widget.play, 'Ticker can run only when play is set.');

    final frameInterval = 1000 / widget.fps;

    if (_elapsedTime == Duration.zero) {
      _elapsedTime = elapsedTime;
    }

    final deltaTime = elapsedTime - _elapsedTime;
    _elapsedTime = elapsedTime;
    _accumulator += deltaTime.inMilliseconds;

    if (_accumulator >= frameInterval) {
      _accumulator -= frameInterval;

      var nextFrameIndex = _frameIndex.value + 1;

      if (nextFrameIndex >= widget.frames.length) {
        if (!widget.loop) {
          _ticker.stop();
          return;
        }

        nextFrameIndex = 0;
      }

      _frameIndex.value = nextFrameIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.frames.first.width;
    final height = widget.frames.first.height;

    return Center(
      heightFactor: 1,
      widthFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(
          Size(
            width * (widget.size + widget.gap) - widget.gap,
            height * (widget.size + widget.gap) - widget.gap,
          ),
        ),
        child: AspectRatio(
          aspectRatio: width / height,
          child: ValueListenableBuilder(
            valueListenable: _frameIndex,
            builder: (context, frameIndex, child) {
              final frame = widget.frames[frameIndex];
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: widget.gap,
                children: [
                  for (var i = 0; i < height; i++)
                    Expanded(
                      child: Row(
                        spacing: widget.gap,
                        children: [
                          for (var j = 0; j < width; j++)
                            Expanded(
                              child: _Dot(
                                value: frame[i][j],
                                onColor: widget.onColor,
                                offColor: widget.offColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({
    required this.value,
    required this.onColor,
    required this.offColor,
  });

  final double value;

  final Color onColor;

  final Color offColor;

  @override
  State<_Dot> createState() => __DotState();
}

class __DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  late final _scaleTween = Tween<double>();
  late final Animation<double> _scale = _scaleTween
      .chain(
        CurveTween(curve: const Interval(0, 150 / 350, curve: Curves.easeOut)),
      )
      .animate(_controller);

  late final _opacityTween = Tween<double>();
  late final Animation<double> _opacity = _opacityTween
      .chain(
        CurveTween(curve: const Interval(0, 350 / 350, curve: Curves.easeOut)),
      )
      .animate(_controller);

  bool get _isActive => widget.value > 0.5;

  bool get _isOn => widget.value > 0.05;

  double get _targetScale => _isActive ? 0.99 : 0.9;

  double get _targetOpacity => _isOn ? widget.value.clamp(0.0, 1.0) : 0.1;

  @override
  void initState() {
    super.initState();
    _scaleTween
      ..begin = _targetScale
      ..end = _targetScale;
    _opacityTween
      ..begin = _targetOpacity
      ..end = _targetOpacity;
  }

  @override
  void didUpdateWidget(_Dot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _scaleTween
        ..begin = _scale.value
        ..end = _targetScale;
      _opacityTween
        ..begin = _opacity.value
        ..end = _targetOpacity;
      _controller.forward(from: 0).ignore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPainter(
        repaint: _controller,
        isActive: _isActive,
        isOn: _isOn,
        onColor: widget.onColor,
        offColor: widget.offColor,
        scale: _scale,
        opacity: _opacity,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter({
    required super.repaint,
    required this.isActive,
    required this.isOn,
    required this.onColor,
    required this.offColor,
    required this.scale,
    required this.opacity,
  });

  final bool isActive;

  final bool isOn;

  final Color onColor;

  final Color offColor;

  final Animation<double> scale;

  final Animation<double> opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;

    final scale = this.scale.value;
    final opacity = this.opacity.value;

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(scale)
      ..translate(-center.dx, -center.dy);

    {
      final gradient = isOn
          ? RadialGradient(
              colors: [
                onColor.withValues(alpha: opacity),
                onColor.withValues(alpha: 0.85 * opacity),
                onColor.withValues(alpha: 0.6 * opacity),
              ],
              stops: const [0.0, 0.7, 1.0],
            )
          : RadialGradient(
              colors: [
                offColor.withValues(alpha: opacity),
                offColor.withValues(alpha: 0.7 * opacity),
              ],
              stops: const [0.0, 1.0],
            );

      if (isActive) {
        canvas.drawOval(
          rect,
          BoxShadow(
            color: onColor.withValues(alpha: 0.7 * opacity),
            blurRadius: 3.5,
          ).toPaint(),
        );
      }

      canvas.drawOval(
        rect,
        Paint()..shader = gradient.createShader(rect),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.isOn != isOn ||
        oldDelegate.onColor != onColor ||
        oldDelegate.offColor != offColor ||
        oldDelegate.scale != scale ||
        oldDelegate.opacity != opacity;
  }
}
