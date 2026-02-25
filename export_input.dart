import '../models/warta_models.dart';

class ExportInput {
  final bool fullMode;

  final bool autoAccent;
  final int? accentOverrideArgb;
  final int? extractedAccentArgb;

  final bool? coverUseLightText;
  final double? coverOverlayOpacity;

  final CoverData coverData;
  final InnerData innerData;

  ExportInput({
    required this.fullMode,
    required this.autoAccent,
    required this.accentOverrideArgb,
    required this.extractedAccentArgb,
    required this.coverUseLightText,
    required this.coverOverlayOpacity,
    required this.coverData,
    required this.innerData,
  });

  ExportInput copyWith({
    bool? fullMode,
    bool? autoAccent,
    int? accentOverrideArgb,
    int? extractedAccentArgb,
    bool? coverUseLightText,
    double? coverOverlayOpacity,
    CoverData? coverData,
    InnerData? innerData,
  }) {
    return ExportInput(
      fullMode: fullMode ?? this.fullMode,
      autoAccent: autoAccent ?? this.autoAccent,
      accentOverrideArgb: accentOverrideArgb ?? this.accentOverrideArgb,
      extractedAccentArgb: extractedAccentArgb ?? this.extractedAccentArgb,
      coverUseLightText: coverUseLightText ?? this.coverUseLightText,
      coverOverlayOpacity: coverOverlayOpacity ?? this.coverOverlayOpacity,
      coverData: coverData ?? this.coverData,
      innerData: innerData ?? this.innerData,
    );
  }
}
