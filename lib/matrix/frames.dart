part of 'matrix.dart';

/// 7-segment style digits from 0 to 9 (7×5).
final digits = <Frame>[
  Frame([
    [0, 1, 1, 1, 0],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
  ]),
  Frame([
    [0, 0, 1, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 1, 1, 1, 0],
  ]),
  Frame([
    [0, 1, 1, 1, 0],
    [1, 0, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 1, 0],
    [0, 0, 1, 0, 0],
    [0, 1, 0, 0, 0],
    [1, 1, 1, 1, 1],
  ]),
  Frame([
    [0, 1, 1, 1, 0],
    [1, 0, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [0, 0, 1, 1, 0],
    [0, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
  ]),
  Frame([
    [0, 0, 0, 1, 0],
    [0, 0, 1, 1, 0],
    [0, 1, 0, 1, 0],
    [1, 0, 0, 1, 0],
    [1, 1, 1, 1, 1],
    [0, 0, 0, 1, 0],
    [0, 0, 0, 1, 0],
  ]),
  Frame([
    [1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
  ]),
  Frame([
    [0, 1, 1, 1, 0],
    [1, 0, 0, 0, 0],
    [1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
  ]),
  Frame([
    [1, 1, 1, 1, 1],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 1, 0],
    [0, 0, 1, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
  ]),
  Frame([
    [0, 1, 1, 1, 0],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
  ]),
  Frame([
    [0, 1, 1, 1, 0],
    [1, 0, 0, 0, 1],
    [1, 0, 0, 0, 1],
    [0, 1, 1, 1, 1],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [0, 1, 1, 1, 0],
  ]),
];

/// Simple left direction arrow (5×5).
final chevronLeft = Frame([
  [0, 0, 0, 1, 0],
  [0, 0, 1, 0, 0],
  [0, 1, 0, 0, 0],
  [0, 0, 1, 0, 0],
  [0, 0, 0, 1, 0],
]);

/// Simple right direction arrow (5×5).
final chevronRight = Frame([
  [0, 1, 0, 0, 0],
  [0, 0, 1, 0, 0],
  [0, 0, 0, 1, 0],
  [0, 0, 1, 0, 0],
  [0, 1, 0, 0, 0],
]);

/// Returns an empty frame (filled with zeros) with a specified dimension.
Frame emptyFrame(int rows, int cols) {
  return Frame(
    List.generate(rows, (_) => List.generate(cols, (_) => 0)),
  );
}

/// Expanding pulse effect (7×7, 16 frames).
final List<Frame> pulse = () {
  const length = 16;
  const size = 7;
  const center = 3;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i < length; i++) {
    final f = frames[i];
    final phase = (i / length) * math.pi * 2;
    final intensity = (math.sin(phase) + 1) / 2;

    f[center][center] = 1;

    final radius = ((1 - intensity) * 3).floor() + 1;
    for (var dy = -radius; dy <= radius; dy++) {
      for (var dx = -radius; dx <= radius; dx++) {
        final dist = math.sqrt(dx * dx + dy * dy);
        if ((dist - radius).abs() < 0.7) {
          final y = center + dy;
          final x = center + dx;
          if (y >= 0 && y < f.height && x >= 0 && x < f.width) {
            f[y][x] = intensity * 0.6;
          }
        }
      }
    }
  }

  return frames;
}();

/// Smooth sine wave animation (7×7, 24 frames).
final List<Frame> wave = () {
  const length = 24;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i < length; i++) {
    final f = frames[i];
    final phase = (i / length) * math.pi * 2;

    for (var col = 0; col < size; col++) {
      final colPhase = (col / size) * math.pi * 2;
      final height = math.sin(phase + colPhase) * 2.5 + 3.5;
      final row = height.floor();

      if (row >= 0 && row < size) {
        f[row][col] = 1;
        final frac = height - row;
        if (row > 0) f[row - 1][col] = 1 - frac;
        if (row < size - 1) f[row + 1][col] = frac;
      }
    }
  }

  return frames;
}();

/// Rotating spinner animation (7×7, 12 frames).
final List<Frame> spinner = () {
  const length = 12;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  const positions = [
    [1, 3],
    [1, 4],
    [2, 5],
    [3, 5],
    [4, 5],
    [5, 4],
    [5, 3],
    [5, 2],
    [4, 1],
    [3, 1],
    [2, 1],
    [1, 2],
  ];

  for (var i = 0; i < length; i++) {
    final f = frames[i];

    for (var j = 0; j < 3; j++) {
      final idx = (i + j) % positions.length;
      final [r, c] = positions[idx];
      f[r][c] = 1 - j * 0.3;
    }
  }

  return frames;
}();

/// Snake traversal pattern (7×7, 49 frames).
final List<Frame> snake = () {
  const size = 7;

  final path = <(int, int)>[];

  var x = 0;
  var y = 0;
  var dx = 1;
  var dy = 0;

  final visited = <String>{};
  while (path.length < size * size) {
    path.add((y, x));
    visited.add('$y,$x');

    final nextX = x + dx;
    final nextY = y + dy;

    if (nextX >= 0 &&
        nextX < size &&
        nextY >= 0 &&
        nextY < size &&
        !visited.contains('$nextY,$nextX')) {
      x = nextX;
      y = nextY;
    } else {
      final newDx = -dy;
      final newDy = dx;
      dx = newDx;
      dy = newDy;

      final nextX = x + dx;
      final nextY = y + dy;

      if (nextX >= 0 &&
          nextX < size &&
          nextY >= 0 &&
          nextY < size &&
          !visited.contains('$nextY,$nextX')) {
        x = nextX;
        y = nextY;
      } else {
        break;
      }
    }
  }

  final frames = List.generate(path.length, (_) => emptyFrame(size, size));

  const snakeLength = 5;
  for (var i = 0; i < path.length; i++) {
    final f = frames[i];

    for (var j = 0; j < snakeLength; j++) {
      final idx = i - j;
      if (idx >= 0 && idx < path.length) {
        final (y, x) = path[idx];
        final brightness = 1 - j / snakeLength;
        f[y][x] = brightness;
      }
    }
  }

  return frames;
}();

/// ElevenLabs logo (7×7, 30 frames).
final List<Frame> elevenLogo = () {
  const length = 30;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i < length; i++) {
    final f = frames[i];

    final phase = (i / length) * math.pi * 2;
    final intensity = ((math.sin(phase) + 1) / 2) * 0.3 + 0.7;

    for (var r = 1; r <= 5; r++) {
      f[r][2] = intensity;
      f[r][4] = intensity;
    }
  }

  return frames;
}();

/// Sand timer animation (7×7, 60 frames).
final List<Frame> sandTimer = () {
  const length = 60;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i < length; i++) {
    final f = frames[i];

    f[0][2] = 1;
    f[0][3] = 1;
    f[0][4] = 1;
    f[1][2] = 1;
    f[1][4] = 1;
    f[5][2] = 1;
    f[5][4] = 1;
    f[6][2] = 1;
    f[6][3] = 1;
    f[6][4] = 1;

    final progress = i / length;

    final topSand = ((1 - progress) * 8).floor();
    for (var i = 0; i < topSand; i++) {
      if (i < 3) f[1][3] = 1;
      if (i >= 3) f[2][3] = 1;
    }

    final bottomSand = (progress * 8).floor();
    for (var i = 0; i < bottomSand; i++) {
      if (i < 3) f[5][3] = 1;
      if (i >= 3 && i < 6) f[4][3] = 1;
      if (i >= 6) f[3][3] = 0.5;
    }
  }

  return frames;
}();

/// Corners animation (7×7, 16 frames).
final List<Frame> corners = () {
  const length = 16;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i < length; i++) {
    final f = frames[i];

    final progress = i / 16;

    for (var r = 0; r < 7; r++) {
      for (var c = 0; c < 7; c++) {
        final distFromCorner = math.min(
          math.min(
            math.sqrt(r * r + c * c),
            math.sqrt(r * r + (6 - c) * (6 - c)),
          ),
          math.min(
            math.sqrt((6 - r) * (6 - r) + c * c),
            math.sqrt((6 - r) * (6 - r) + (6 - c) * (6 - c)),
          ),
        );
        final threshold = progress * 8;
        if (distFromCorner <= threshold) {
          f[r][c] = math.max(0, 1 - (distFromCorner - threshold).abs());
        }
      }
    }
  }

  return frames;
}();

/// Shining gradient animation (7×7, 14 frames).
final List<Frame> sweep = () {
  const length = 14;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i < length; i++) {
    final f = frames[i];

    for (var r = 0; r < 7; r++) {
      for (var c = 0; c < 7; c++) {
        if (r + c == i) {
          f[r][c] = 1;
        } else if (r + c == i - 1) {
          f[r][c] = 0.5;
        } else if (r + c == i + 1) {
          f[r][c] = 0.5;
        }
      }
    }
  }

  return frames;
}();

/// Rectangle expansions animation (7×7, 13 frames).
final List<Frame> expand = () {
  const length = 13;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i <= 6; i++) {
    final f = frames[i];

    for (var r = 3 - i; r <= 3 + i; r++) {
      for (var c = 3 - i; c <= 3 + i; c++) {
        if (r >= 0 && r < 7 && c >= 0 && c < 7) {
          if (r == 3 - i || r == 3 + i || c == 3 - i || c == 3 + i) {
            f[r][c] = 1;
          }
        }
      }
    }
  }
  for (var i = 5; i >= 0; i--) {
    final f = frames[length - i - 1];
    for (var r = 3 - i; r <= 3 + i; r++) {
      for (var c = 3 - i; c <= 3 + i; c++) {
        if (r >= 0 && r < 7 && c >= 0 && c < 7) {
          if (r == 3 - i || r == 3 + i || c == 3 - i || c == 3 + i) {
            f[r][c] = 1;
          }
        }
      }
    }
  }

  return frames;
}();

/// Burst animation (7×7, 8 frames).
final List<Frame> burst = () {
  const length = 8;
  const size = 7;

  final frames = List.generate(length, (_) => emptyFrame(size, size));

  for (var i = 0; i < length; i++) {
    final f = frames[i];

    final intensity = i < 4 ? i / 3 : (7 - i) / 3;

    if (i < 6) {
      for (var r = 0; r < 7; r++) {
        for (var c = 0; c < 7; c++) {
          final distance = math.sqrt(math.pow(r - 3, 2) + math.pow(c - 3, 2));
          if ((distance - i * 0.8).abs() < 1.2) {
            f[r][c] = intensity;
          }
        }
      }
    }
  }

  return frames;
}();
