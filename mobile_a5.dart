import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../export/export_input.dart';

pw.Document buildMobileA5Pdf(ExportInput input) {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) {
        final widgets = <pw.Widget>[];

        widgets.add(pw.Text(input.coverData.churchName,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.Text(input.coverData.dateLabel,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)));
        widgets.add(pw.SizedBox(height: 12));

        widgets.add(pw.Text("TATA IBADAH",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.SizedBox(height: 6));

        final lines = input.fullMode
            ? input.innerData.liturgi.map((e) => e.line).toList()
            : ["Ringkasan ibadah (mode jemaat)"];
        for (final line in lines) {
          widgets.add(pw.Text("• $line", style: const pw.TextStyle(fontSize: 10.8)));
        }

        widgets.add(pw.SizedBox(height: 12));
        widgets.add(pw.Text("PETUGAS",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.SizedBox(height: 6));
        for (final p in input.innerData.petugas) {
          widgets.add(pw.Text("• ${p.role}: ${p.name}", style: const pw.TextStyle(fontSize: 10.8)));
        }

        widgets.add(pw.SizedBox(height: 12));
        widgets.add(pw.Text("PENGUMUMAN",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)));
        widgets.add(pw.SizedBox(height: 6));
        for (final a in input.innerData.pengumuman) {
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.only(bottom: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(a.title.toUpperCase(),
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  if (a.time != null)
                    pw.Text(a.time!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  if (a.place != null)
                    pw.Text(a.place!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  if (a.body != null) pw.SizedBox(height: 6),
                  if (a.body != null) pw.Text(a.body!, style: const pw.TextStyle(fontSize: 10.5)),
                ],
              ),
            ),
          );
        }

        if (input.innerData.qrPngBytes != null) {
          final img = pw.MemoryImage(input.innerData.qrPngBytes as Uint8List);
          widgets.add(pw.SizedBox(height: 10));
          widgets.add(pw.Center(child: pw.Image(img, width: 110, height: 110)));
        }

        return widgets;
      },
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("Warta Jemaat", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
          pw.Text("Hal. ${ctx.pageNumber}", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
        ],
      ),
    ),
  );

  return doc;
}
