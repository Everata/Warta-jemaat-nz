import 'dart:math';

class CoverContrast {
  final bool useLightText;
  final double overlayOpacity;
  const CoverContrast({required this.useLightText, required this.overlayOpacity});
}

double _srgbToLinear(double x) =>
    x <= 0.04045 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4).toDouble();

double relativeLuminanceRgb(int r, int g, int b) {
  final R = _srgbToLinear(r / 255.0);
  final G = _srgbToLinear(g / 255.0);
  final B = _srgbToLinear(b / 255.0);
  return 0.2126 * R + 0.7152 * G + 0.0722 * B;
}

double contrastRatioL(double L1, double L2) {
  final a = max(L1, L2);
  final b = min(L1, L2);
  return (a + 0.05) / (b + 0.05);
}

CoverContrast decideCoverContrastFromRgb(int r, int g, int b) {
  final Lbg = relativeLuminanceRgb(r, g, b);

  final cWhite = contrastRatioL(Lbg, 1.0);
  final cBlack = contrastRatioL(Lbg, 0.0);

  final useLightText = cWhite >= cBlack;

  final overlayOpacity = (0.22 + (Lbg * 0.33)).clamp(0.22, 0.55);

  return CoverContrast(useLightText: useLightText, overlayOpacity: overlayOpacity);
}
