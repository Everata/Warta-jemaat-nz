import 'dart:typed_data';
import 'export_input.dart';
import '../pdf/builders.dart';

enum PdfKind { mobileA5, innerA4, coverA4 }

Future<Uint8List> generatePdfBytesSingle({
  required PdfKind kind,
  required ExportInput input,
}) async {
  final doc = switch (kind) {
    PdfKind.mobileA5 => buildMobileA5(input),
    PdfKind.innerA4 => buildInnerA4(input),
    PdfKind.coverA4 => buildCoverA4(input),
  };
  return doc.save();
}
