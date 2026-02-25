import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../export/export_input.dart';

pw.Document buildCoverA4Pdf(ExportInput input) {
  final doc = pw.Document();

  final useLight = input.coverUseLightText ?? true;
  final overlay = (input.coverOverlayOpacity ?? 0.35).clamp(0.18, 0.62);

  final titleColor = useLight ? PdfColor(1, 1, 1, 1) : PdfColor(0, 0, 0, 1);
  final metaColor = useLight ? PdfColor(1, 1, 1, 0.75) : PdfColor(0, 0, 0, 0.65);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) {
        final bgBytes = input.coverData.backgroundImageBytes;
        final bgImg = bgBytes == null ? null : pw.MemoryImage(bgBytes as Uint8List);

        return pw.Stack(
          children: [
            pw.Container(color: PdfColor(0.06, 0.16, 0.27)),
            if (bgImg != null)
              pw.Positioned.fill(child: pw.Image(bgImg, fit: pw.BoxFit.cover)),
            pw.Positioned.fill(child: pw.Container(color: PdfColor(0, 0, 0, overlay))),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(56, 90, 56, 56),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: 64, height: 4, color: PdfColor(0.20, 0.45, 0.75)),
                  pw.SizedBox(height: 18),
                  pw.Text("WARTA JEMAAT",
                      style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: titleColor)),
                  pw.SizedBox(height: 10),
                  pw.Text(input.coverData.dateLabel, style: pw.TextStyle(fontSize: 12, color: metaColor)),
                  pw.SizedBox(height: 26),
                  pw.Text("“${input.coverData.themeTitle}”", style: pw.TextStyle(fontSize: 16, color: metaColor)),
                  pw.Spacer(),
                  pw.Text(input.coverData.churchName, style: pw.TextStyle(fontSize: 12, color: metaColor)),
                  if ((input.coverData.churchAddress ?? "").isNotEmpty)
                    pw.Text(input.coverData.churchAddress!, style: pw.TextStyle(fontSize: 10, color: metaColor)),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return doc;
}
