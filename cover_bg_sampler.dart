import 'dart:typed_data';
import 'dart:ui' as ui;

class Rgb {
  final int r, g, b;
  const Rgb(this.r, this.g, this.b);
}

Future<Rgb?> sampleAverageRgbFromImageBytes(
  Uint8List imageBytes, {
  int targetSize = 64,
  int stride = 2,
}) async {
  final codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: targetSize,
    targetHeight: targetSize,
  );
  final frame = await codec.getNextFrame();
  final img = frame.image;

  final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (bd == null) return null;

  final data = bd.buffer.asUint8List();
  final w = img.width;
  final h = img.height;

  int count = 0;
  int sr = 0, sg = 0, sb = 0;

  for (int y = 0; y < h; y += stride) {
    for (int x = 0; x < w; x += stride) {
      final i = (y * w + x) * 4;
      final r = data[i];
      final g = data[i + 1];
      final b = data[i + 2];
      final a = data[i + 3];
      if (a < 200) continue;

      sr += r;
      sg += g;
      sb += b;
      count++;
    }
  }

  if (count == 0) return null;
  return Rgb(sr ~/ count, sg ~/ count, sb ~/ count);
}
