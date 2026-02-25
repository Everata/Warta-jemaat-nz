import 'package:pdf/widgets.dart' as pw;
import '../export/export_input.dart';
import 'builders/mobile_a5.dart';
import 'builders/inner_a4.dart';
import 'builders/cover_a4.dart';

pw.Document buildMobileA5(ExportInput input) => buildMobileA5Pdf(input);
pw.Document buildInnerA4(ExportInput input) => buildInnerA4Pdf(input);
pw.Document buildCoverA4(ExportInput input) => buildCoverA4Pdf(input);
