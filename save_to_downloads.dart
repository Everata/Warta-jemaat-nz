import 'package:media_store_plus/media_store_plus.dart';

const String kWartaFolder = "WartaJemaat";

String makeNicePdfName({
  required DateTime editionDate,
  required String modeLabel,
  required String kindLabel,
}) {
  final ts = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '')
      .replaceAll('.', '')
      .replaceAll('-', '');
  return "Warta_${modeLabel}_$kindLabel_$ts.pdf";
}

String saveInfoToText(dynamic info, {String? fallbackName}) {
  try {
    final savedName = (info?.savedFileName ?? info?.fileName ?? fallbackName ?? "").toString();
    final uri = (info?.uriString ?? info?.uri ?? info?.uriPath ?? "").toString();
    final p = (info?.path ?? "").toString();
    final parts = <String>[];
    if (savedName.trim().isNotEmpty) parts.add(savedName);
    if (uri.trim().isNotEmpty) parts.add(uri);
    if (p.trim().isNotEmpty) parts.add(p);
    return parts.isEmpty ? "Tersimpan ✅" : parts.join("\n");
  } catch (_) {
    return "Tersimpan ✅";
  }
}

Future<SaveInfo> savePdfToDownloadsFolderSafe({
  required String tempFilePath,
  required String fileName,
}) async {
  await MediaStore.ensureInitialized();
  MediaStore.appFolder = kWartaFolder;

  final ms = MediaStore();

  try {
    final info = await ms.saveFile(
      tempFilePath: tempFilePath,
      dirType: DirType.download,
      dirName: DirName.download,
      relativePath: "Download/$kWartaFolder",
    );
    if (info != null) return info;
  } catch (_) {}

  final fallback = await ms.saveFile(
    tempFilePath: tempFilePath,
    dirType: DirType.download,
    dirName: DirName.download,
    relativePath: "Download",
  );

  if (fallback == null) throw Exception("Gagal menyimpan ke Downloads.");
  return fallback;
}
