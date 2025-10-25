import 'dart:async';
import 'dart:math' as math;

import 'package:elevenlabs_ui_matrix/matrix/matrix.dart';
import 'package:elevenlabs_ui_matrix/theme/theme.dart';
import 'package:flutter/material.dart';

enum _MatrixDemoMode {
  individual,
  focus,
  expand,
  unified,
  collapse,
  burst;

  _MatrixDemoMode get next {
    return switch (this) {
      individual => focus,
      focus => expand,
      expand => unified,
      unified => collapse,
      collapse => burst,
      burst => individual,
    };
  }
}

class MatrixDemoScreen extends StatefulWidget {
  const MatrixDemoScreen({super.key});

  @override
  State<MatrixDemoScreen> createState() => _MatrixDemoScreenState();
}

class _MatrixDemoScreenState extends State<MatrixDemoScreen>
    with SingleTickerProviderStateMixin {
  static final Frame _emptyFrame = Frame([
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
  ]);

  final ValueNotifier<_MatrixDemoMode> _mode = ValueNotifier(
    _MatrixDemoMode.individual,
  );
  final ValueNotifier<List<Frame>> _cachedFrames = ValueNotifier(
    [_emptyFrame.copy()],
  );

  Timer? _unifiedModeTimer;
  int _unifiedModeFrameIndex = 0;

  late final _progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  );

  @override
  void initState() {
    super.initState();
    _scheduleNextMode().ignore();
    _mode.addListener(_onModeChanged);
    _progressController.addListener(_onProgress);
  }

  @override
  void dispose() {
    _mode.dispose();
    _cachedFrames.dispose();
    _unifiedModeTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _scheduleNextMode() async {
    final duration = switch (_mode.value) {
      _MatrixDemoMode.individual => const Duration(milliseconds: 4000),
      _MatrixDemoMode.focus => const Duration(milliseconds: 2000),
      _MatrixDemoMode.expand => const Duration(milliseconds: 2500),
      _MatrixDemoMode.unified => const Duration(milliseconds: 4000),
      _MatrixDemoMode.collapse => const Duration(milliseconds: 2500),
      _MatrixDemoMode.burst => const Duration(milliseconds: 800),
    };

    await Future<void>.delayed(duration);

    if (!mounted) {
      return;
    }

    _mode.value = _mode.value.next;
    return _scheduleNextMode();
  }

  void _onModeChanged() {
    _unifiedModeTimer?.cancel();
    _progressController
      ..stop()
      ..reset();

    switch (_mode.value) {
      case _MatrixDemoMode.unified:
        _unifiedModeFrameIndex = 0;

        void createUnifiedFrames() {
          final frames = _createUnifiedFrames(_unifiedModeFrameIndex);
          _cachedFrames.value = frames;
          _unifiedModeFrameIndex++;
        }

        createUnifiedFrames();
        _unifiedModeTimer = Timer.periodic(
          const Duration(milliseconds: 50),
          (timer) => createUnifiedFrames(),
        );

      case _MatrixDemoMode.expand:
      case _MatrixDemoMode.collapse:
        _progressController.forward(from: 0).ignore();

      case _MatrixDemoMode.individual:
      case _MatrixDemoMode.focus:
      case _MatrixDemoMode.burst:
        break;
    }
  }

  List<Frame> _createUnifiedFrames(int frameIndex) {
    final frames = _cachedFrames.value.toList();

    for (var globalRow = 0; globalRow < 21; globalRow++) {
      for (var globalCol = 0; globalCol < 21; globalCol++) {
        const center = 21 / 2;
        final distance = math.sqrt(
          math.pow(globalCol - center, 2) + math.pow(globalRow - center, 2),
        );
        final wave = math.sin(distance * 0.5 - frameIndex * 0.2);
        final value = (wave + 1) / 2;

        final matrixRow = globalRow ~/ 7;
        final matrixCol = globalCol ~/ 7;
        final matrixIdx = matrixRow * 3 + matrixCol;
        final localRow = globalRow % 7;
        final localCol = globalCol % 7;

        frames[matrixIdx][localRow][localCol] = value;
      }
    }

    return frames;
  }

  void _onProgress() {
    switch (_mode.value) {
      case _MatrixDemoMode.expand:
        _cachedFrames.value = _createExpandFrames(_progressController.value);
      case _MatrixDemoMode.collapse:
        _cachedFrames.value = _createCollapseFrames(_progressController.value);

      case _:
        return;
    }
  }

  List<Frame> _createExpandFrames(double progress) {
    final frames = List.generate(9, (_) => _emptyFrame.copy());

    final easeProgress = progress < 0.5
        ? 2 * progress * progress
        : 1 - math.pow(-2 * progress + 2, 2) / 2;

    if (easeProgress < 0.3) {
      final centerFrame = frames[4];
      for (var r = 1; r <= 5; r++) {
        centerFrame[r][2] = 1;
        centerFrame[r][4] = 1;
      }
    } else {
      final expandProgress = (easeProgress - 0.3) / 0.7;

      for (var globalRow = 0; globalRow < 21; globalRow++) {
        for (var globalCol = 0; globalCol < 21; globalCol++) {
          final matrixRow = globalRow ~/ 7;
          final matrixCol = globalCol ~/ 7;
          final matrixIdx = matrixRow * 3 + matrixCol;
          final localRow = globalRow % 7;
          final localCol = globalCol % 7;

          final leftBarStart = (9 + (5 - 9) * expandProgress).floor();
          final leftBarEnd = (9 + (7 - 9) * expandProgress).floor();
          final rightBarStart = (11 + (13 - 11) * expandProgress).floor();
          final rightBarEnd = (11 + (15 - 11) * expandProgress).floor();

          final isLeftBar =
              globalCol >= leftBarStart && globalCol <= leftBarEnd;
          final isRightBar =
              globalCol >= rightBarStart && globalCol <= rightBarEnd;
          final inVerticalRange = globalRow >= 4 && globalRow <= 16;

          if ((isLeftBar || isRightBar) && inVerticalRange) {
            frames[matrixIdx][localRow][localCol] = 1;
          }
        }
      }
    }

    return frames;
  }

  List<Frame> _createCollapseFrames(double progress) {
    final frames = List.generate(9, (_) => _emptyFrame.copy());

    final easeProgress = progress < 0.5
        ? 2 * progress * progress
        : 1 - math.pow(-2 * progress + 2, 2) / 2;

    if (easeProgress < 0.4) {
      final collapseProgress = easeProgress / 0.4;

      for (var globalRow = 0; globalRow < 21; globalRow++) {
        for (var globalCol = 0; globalCol < 21; globalCol++) {
          final matrixRow = globalRow ~/ 7;
          final matrixCol = globalCol ~/ 7;
          final matrixIdx = matrixRow * 3 + matrixCol;
          final localRow = globalRow % 7;
          final localCol = globalCol % 7;

          final leftBarStart = (5 + (9 - 5) * collapseProgress).floor();
          final leftBarEnd = (7 + (9 - 7) * collapseProgress).floor();
          final rightBarStart = (13 + (11 - 13) * collapseProgress).floor();
          final rightBarEnd = (15 + (11 - 15) * collapseProgress).floor();

          final isLeftBar =
              globalCol >= leftBarStart && globalCol <= leftBarEnd;
          final isRightBar =
              globalCol >= rightBarStart && globalCol <= rightBarEnd;
          final inVerticalRange = globalRow >= 4 && globalRow <= 16;

          if ((isLeftBar || isRightBar) && inVerticalRange) {
            frames[matrixIdx][localRow][localCol] = 1;
          }
        }
      }
    } else {
      final centerMatrix = frames[4];
      final fadeProgress = (easeProgress - 0.4) / 0.6;
      final brightness = 1 - fadeProgress;

      for (var r = 1; r <= 5; r++) {
        centerMatrix[r][2] = brightness;
        centerMatrix[r][4] = brightness;
      }
    }

    return frames;
  }

  ({List<Frame> frames, int fps}) _getConfigForMatrix(int index) {
    switch (_mode.value) {
      case _MatrixDemoMode.individual:
        return switch (index) {
          0 => (frames: pulse, fps: 16),
          1 => (frames: wave, fps: 20),
          2 => (frames: spinner, fps: 10),
          3 => (frames: snake, fps: 15),
          4 => (frames: elevenLogo, fps: 12),
          5 => (frames: sandTimer, fps: 12),
          6 => (frames: corners, fps: 10),
          7 => (frames: sweep, fps: 14),
          8 => (frames: expand, fps: 12),
          _ => (frames: [_emptyFrame], fps: 1),
        };

      case _MatrixDemoMode.focus:
        if (index == 4) {
          final frame = _emptyFrame.copy();
          for (var r = 1; r <= 5; r++) {
            frame[r][2] = 1;
            frame[r][4] = 1;
          }
          return (frames: [frame], fps: 1);
        }
        return (frames: [_emptyFrame], fps: 1);

      case _MatrixDemoMode.expand:
      case _MatrixDemoMode.unified:
      case _MatrixDemoMode.collapse:
        return (frames: [_cachedFrames.value[index]], fps: 1);

      case _MatrixDemoMode.burst:
        return (frames: burst, fps: 30);
    }
  }

  Widget _buildMatrix({
    required int index,
    required Color onColor,
    required Color offColor,
  }) {
    final (:frames, :fps) = _getConfigForMatrix(index);

    return Matrix(
      size: 10,
      gap: 2,
      frames: frames,
      fps: fps,
      onColor: onColor,
      offColor: offColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final matrixColors = context.matrixColors;

    return Scaffold(
      body: Center(
        child: RepaintBoundary(
          child: ListenableBuilder(
            listenable: Listenable.merge([_mode, _cachedFrames]),
            builder: (context, _) {
              return Column(
                spacing: 6,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var j = 0; j < 3; j++)
                          Flexible(
                            child: _buildMatrix(
                              index: 3 * i + j,
                              onColor: matrixColors.on,
                              offColor: matrixColors.off,
                            ),
                          ),
                      ],
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
