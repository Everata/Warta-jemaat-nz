import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

class ExtractedAccent {
  final int argb;
  final double score;
  const ExtractedAccent(this.argb, this.score);
}

double _sat(int r, int g, int b) {
  final rf = r / 255.0, gf = g / 255.0, bf = b / 255.0;
  final mx = max(rf, max(gf, bf));
  final mn = min(rf, min(gf, bf));
  final d = mx - mn;
  if (mx == 0) return 0;
  return d / mx;
}

double _val(int r, int g, int b) {
  final rf = r / 255.0, gf = g / 255.0, bf = b / 255.0;
  return max(rf, max(gf, bf));
}

int _argb(int a, int r, int g, int b) =>
    ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);

Future<ExtractedAccent?> extractAccentFromImageBytes(
  Uint8List imageBytes, {
  int targetSize = 96,
  int stride = 2,
}) async {
  final codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: targetSize,
    targetHeight: targetSize,
  );
  final frame = await codec.getNextFrame();
  final img = frame.image;

  final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return null;

  final data = byteData.buffer.asUint8List();
  final w = img.width;
  final h = img.height;

  int q(int c) => (c ~/ 24) * 24;
  final counts = <int, int>{};
  final scores = <int, double>{};

  for (int y = 0; y < h; y += stride) {
    for (int x = 0; x < w; x += stride) {
      final i = (y * w + x) * 4;
      final r = data[i];
      final g = data[i + 1];
      final b = data[i + 2];
      final a = data[i + 3];

      if (a < 200) continue;

      final v = _val(r, g, b);
      if (v > 0.95) continue;
      if (v < 0.08) continue;

      final s = _sat(r, g, b);
      if (s < 0.18) continue;

      final rr = q(r), gg = q(g), bb = q(b);
      final key = _argb(255, rr, gg, bb);
      counts[key] = (counts[key] ?? 0) + 1;

      final vibrancy = (s * 1.4) + (min(1.0, v) * 0.6);
      scores[key] = (scores[key] ?? 0) + vibrancy;
    }
  }

  if (counts.isEmpty) return null;

  int bestKey = counts.keys.first;
  double bestScore = -1;

  counts.forEach((k, c) {
    final avgV = (scores[k] ?? 0) / max(1, c);
    final score = c * avgV;
    if (score > bestScore) {
      bestScore = score;
      bestKey = k;
    }
  });

  return ExtractedAccent(bestKey, bestScore);
}
