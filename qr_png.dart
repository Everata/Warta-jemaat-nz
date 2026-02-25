import 'dart:typed_data';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

Uint8List generateQrPngBytes(
  String data, {
  int size = 420,
  int margin = 2,
}) {
  final qr = QrCode(8, QrErrorCorrectLevel.M);
  qr.addData(data);
  qr.make();

  final moduleCount = qr.moduleCount;
  final pixelsPerModule = (size / (moduleCount + margin * 2)).floor().clamp(1, 64);

  final outSize = (moduleCount + margin * 2) * pixelsPerModule;
  final image = img.Image(width: outSize, height: outSize);

  img.fill(image, img.ColorRgb8(255, 255, 255));

  for (int y = 0; y < moduleCount; y++) {
    for (int x = 0; x < moduleCount; x++) {
      final isDark = qr.isDark(y, x);
      if (!isDark) continue;

      final px = (x + margin) * pixelsPerModule;
      final py = (y + margin) * pixelsPerModule;

      img.fillRect(
        image,
        x1: px,
        y1: py,
        x2: px + pixelsPerModule - 1,
        y2: py + pixelsPerModule - 1,
        color: img.ColorRgb8(0, 0, 0),
      );
    }
  }

  return Uint8List.fromList(img.encodePng(image));
}
