import 'dart:typed_data';

class PetugasItem {
  final String role;
  final String name;
  PetugasItem(this.role, this.name);
}

class PengumumanItem {
  final String title;
  final String? time;
  final String? place;
  final String? body;
  PengumumanItem({required this.title, this.time, this.place, this.body});
}

class LiturgiLine {
  final String line;
  LiturgiLine(this.line);
}

class DoaLine {
  final String line;
  DoaLine(this.line);
}

class InnerData {
  final List<PetugasItem> petugas;
  final List<PengumumanItem> pengumuman;
  final List<LiturgiLine> liturgi;
  final List<DoaLine> doa;
  final Uint8List? qrPngBytes;

  InnerData({
    required this.petugas,
    required this.pengumuman,
    required this.liturgi,
    required this.doa,
    this.qrPngBytes,
  });
}

class CoverData {
  final String churchName;
  final String? churchAddress;
  final String dateLabel;
  final String themeTitle;
  final Uint8List? backgroundImageBytes;

  CoverData({
    required this.churchName,
    required this.dateLabel,
    required this.themeTitle,
    this.churchAddress,
    this.backgroundImageBytes,
  });
}
