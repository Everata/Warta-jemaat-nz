import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../export/export_input.dart';

pw.Document buildInnerA4Pdf(ExportInput input) {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(48, 56, 42, 50),
      build: (ctx) {
        final widgets = <pw.Widget>[];

        widgets.add(pw.Text("WARTA JEMAAT", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.Text(input.coverData.dateLabel, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)));
        widgets.add(pw.SizedBox(height: 14));

        widgets.add(pw.Text("Pengumuman", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.SizedBox(height: 10));

        widgets.add(
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: input.innerData.pengumuman.map((a) {
              return pw.Container(
                width: (ctx.page.pageFormat.availableWidth - 12) / 2,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(a.title.toUpperCase(), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  if (a.time != null) pw.Text(a.time!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  if (a.place != null) pw.Text(a.place!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  if (a.body != null) pw.SizedBox(height: 6),
                  if (a.body != null) pw.Text(a.body!, style: const pw.TextStyle(fontSize: 10.5)),
                ]),
              );
            }).toList(),
          ),
        );

        if (input.innerData.qrPngBytes != null) {
          final img = pw.MemoryImage(input.innerData.qrPngBytes as Uint8List);
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(pw.Center(child: pw.Image(img, width: 140, height: 140)));
        }

        return widgets;
      },
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(input.coverData.churchName, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
          pw.Text("Hal. ${ctx.pageNumber}", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
        ],
      ),
    ),
  );
  return doc;
}
