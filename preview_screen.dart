import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/warta_models.dart';
import '../export/export_input.dart';
import '../export/generate_pdf_bytes_single.dart';
import '../preview/export_utils.dart';
import '../preview/open_downloads.dart';
import '../preview/progress_runner.dart';
import '../preview/save_to_downloads.dart';

import '../preview/accent_extractor.dart';
import '../preview/cover_bg_sampler.dart';
import '../pdf/theme/cover_contrast.dart';

enum PreviewKind { mobileA5, innerA4, coverA4 }

class PreviewScreen extends StatefulWidget {
  final CoverData coverData;
  final InnerData innerData;

  const PreviewScreen({super.key, required this.coverData, required this.innerData});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  bool _fullMode = false;
  int? _accentLockedArgb;

  ExportInput? _input;
  Uint8List? _a5;
  Uint8List? _inner;
  Uint8List? _cover;

  PreviewKind _kind = PreviewKind.mobileA5;
  String? _err;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() async {
      if (_tabs.indexIsChanging) return;
      setState(() => _kind = PreviewKind.values[_tabs.index]);
      await _ensureBytesForTab();
    });
    _init();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _err = null;
      _a5 = null;
      _inner = null;
      _cover = null;
    });

    try {
      int? extractedAccent;
      bool? coverUseLightText = true;
      double? coverOverlay = 0.35;

      final coverBytes = widget.coverData.backgroundImageBytes;
      if (coverBytes != null) {
        final ex = await extractAccentFromImageBytes(coverBytes);
        extractedAccent = ex?.argb;

        final avg = await sampleAverageRgbFromImageBytes(coverBytes);
        if (avg != null) {
          final cc = decideCoverContrastFromRgb(avg.r, avg.g, avg.b);
          coverUseLightText = cc.useLightText;
          coverOverlay = cc.overlayOpacity;
        }
      }

      _input = ExportInput(
        fullMode: _fullMode,
        autoAccent: true,
        accentOverrideArgb: _accentLockedArgb,
        extractedAccentArgb: extractedAccent,
        coverUseLightText: coverUseLightText,
        coverOverlayOpacity: coverOverlay,
        coverData: widget.coverData,
        innerData: widget.innerData,
      );

      _a5 = await generatePdfBytesSingle(kind: PdfKind.mobileA5, input: _input!);

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _ensureBytesForTab() async {
    if (_input == null) return;
    try {
      if (_kind == PreviewKind.innerA4 && _inner == null) {
        _inner = await generatePdfBytesSingle(kind: PdfKind.innerA4, input: _input!);
        if (mounted) setState(() {});
      }
      if (_kind == PreviewKind.coverA4 && _cover == null) {
        _cover = await generatePdfBytesSingle(kind: PdfKind.coverA4, input: _input!);
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _err = e.toString());
    }
  }

  Uint8List? _currentBytes() {
    return switch (_kind) {
      PreviewKind.mobileA5 => _a5,
      PreviewKind.innerA4 => _inner,
      PreviewKind.coverA4 => _cover,
    };
  }

  String _kindLabel() => switch (_kind) {
        PreviewKind.mobileA5 => "Mobile A5",
        PreviewKind.innerA4 => "Inner A4",
        PreviewKind.coverA4 => "Cover A4",
      };

  String _fileName(PreviewKind k) {
    final mode = _fullMode ? "FULL" : "JEMAAT";
    final label = switch (k) {
      PreviewKind.mobileA5 => "A5",
      PreviewKind.innerA4 => "InnerA4",
      PreviewKind.coverA4 => "CoverA4",
    };
    return makeNicePdfName(editionDate: DateTime.now(), modeLabel: mode, kindLabel: label);
  }

  Future<void> _shareCurrent() async {
    await _ensureBytesForTab();
    final bytes = _currentBytes();
    if (bytes == null) return;
    final f = await writeTempPdf(filename: _fileName(_kind), bytes: bytes);
    await Share.shareXFiles([XFile(f.path, mimeType: "application/pdf")]);
  }

  Future<void> _shareAll3() async {
    if (_input == null) return;
    final res = await runWithProgressDialogCancelable<void>(
      context: context,
      title: "Export 3 PDF",
      task: (p) async {
        p.update(step: "Generating A5…", progress: 0.10);
        _a5 ??= await generatePdfBytesSingle(kind: PdfKind.mobileA5, input: _input!);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Generating Inner…", progress: 0.30);
        _inner ??= await generatePdfBytesSingle(kind: PdfKind.innerA4, input: _input!);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Generating Cover…", progress: 0.50);
        _cover ??= await generatePdfBytesSingle(kind: PdfKind.coverA4, input: _input!);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Preparing files…", progress: 0.70);
        final f1 = await writeTempPdf(filename: _fileName(PreviewKind.mobileA5), bytes: _a5!);
        final f2 = await writeTempPdf(filename: _fileName(PreviewKind.innerA4), bytes: _inner!);
        final f3 = await writeTempPdf(filename: _fileName(PreviewKind.coverA4), bytes: _cover!);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Sharing…", progress: 0.90);
        await Share.shareXFiles([
          XFile(f1.path, mimeType: "application/pdf"),
          XFile(f2.path, mimeType: "application/pdf"),
          XFile(f3.path, mimeType: "application/pdf"),
        ]);

        p.update(step: "Selesai ✅", progress: 1.0);
      },
    );

    if (res == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dibatalkan.")));
    }
  }

  Future<void> _saveCurrentAndroid() async {
    if (!Platform.isAndroid) {
      await _shareCurrent();
      return;
    }
    await _ensureBytesForTab();
    final bytes = _currentBytes();
    if (bytes == null) return;

    final res = await runWithProgressDialogCancelable<void>(
      context: context,
      title: "Menyimpan PDF",
      task: (p) async {
        final name = _fileName(_kind);
        p.update(step: "Membuat file sementara…", progress: 0.35);
        final tmp = await writeTempPdf(filename: name, bytes: bytes);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Menyimpan ke Downloads/$kWartaFolder…", progress: 0.75);
        final info = await savePdfToDownloadsFolderSafe(tempFilePath: tmp.path, fileName: name);
        p.update(step: "Selesai ✅", progress: 1.0);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tersimpan ✅\n${saveInfoToText(info, fallbackName: name)}")),
        );
      },
    );

    if (res == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dibatalkan.")));
    }
  }

  Future<void> _saveAllAndroid() async {
    if (!Platform.isAndroid) {
      await _shareAll3();
      return;
    }
    if (_input == null) return;

    final res = await runWithProgressDialogCancelable<void>(
      context: context,
      title: "Menyimpan 3 PDF",
      task: (p) async {
        p.update(step: "Generating A5…", progress: 0.10);
        _a5 ??= await generatePdfBytesSingle(kind: PdfKind.mobileA5, input: _input!);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Generating Inner…", progress: 0.30);
        _inner ??= await generatePdfBytesSingle(kind: PdfKind.innerA4, input: _input!);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Generating Cover…", progress: 0.50);
        _cover ??= await generatePdfBytesSingle(kind: PdfKind.coverA4, input: _input!);
        p.cancelToken.throwIfCanceled();

        final n1 = _fileName(PreviewKind.mobileA5);
        final n2 = _fileName(PreviewKind.innerA4);
        final n3 = _fileName(PreviewKind.coverA4);

        p.update(step: "Temp files…", progress: 0.65);
        final t1 = await writeTempPdf(filename: n1, bytes: _a5!);
        final t2 = await writeTempPdf(filename: n2, bytes: _inner!);
        final t3 = await writeTempPdf(filename: n3, bytes: _cover!);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Saving A5…", progress: 0.75);
        final i1 = await savePdfToDownloadsFolderSafe(tempFilePath: t1.path, fileName: n1);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Saving Inner…", progress: 0.85);
        final i2 = await savePdfToDownloadsFolderSafe(tempFilePath: t2.path, fileName: n2);
        p.cancelToken.throwIfCanceled();

        p.update(step: "Saving Cover…", progress: 0.95);
        final i3 = await savePdfToDownloadsFolderSafe(tempFilePath: t3.path, fileName: n3);

        p.update(step: "Selesai ✅", progress: 1.0);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 8),
            content: Text(
              "Done ✅\nA5:\n${saveInfoToText(i1)}\nInner:\n${saveInfoToText(i2)}\nCover:\n${saveInfoToText(i3)}",
            ),
          ),
        );
      },
    );

    if (res == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dibatalkan.")));
    }
  }

  int _uiResolvedAccentArgb() {
    const fallback = 0xFF3372BF;
    if (_accentLockedArgb != null) return _accentLockedArgb!;
    final override = _input?.accentOverrideArgb;
    if (override != null) return override;
    final extracted = _input?.extractedAccentArgb;
    if ((_input?.autoAccent ?? false) && extracted != null) return extracted;
    return fallback;
  }

  Widget _themeChip() {
    final accent = Color(_uiResolvedAccentArgb());
    final isLocked = _accentLockedArgb != null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _openThemeSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text("${_fullMode ? "FULL" : "JEMAAT"} · ${isLocked ? "LOCK" : "AUTO"}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  void _openThemeSheet() {
    final accentArgb = _uiResolvedAccentArgb();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Theme Preview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Color(accentArgb),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.10)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Accent: #${accentArgb.toRadixString(16).padLeft(8, '0').toUpperCase()}\nMode: ${_fullMode ? "FULL" : "JEMAAT"}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _accentLockedArgb = null;
                      _input = _input?.copyWith(accentOverrideArgb: null);
                    });
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text("Unlock"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _accentLockedArgb = accentArgb;
                      _input = _input?.copyWith(accentOverrideArgb: accentArgb);
                      _a5 = null;
                      _inner = null;
                      _cover = null;
                    });
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text("Lock"),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _openActions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Export 3 PDF (Share)"),
              subtitle: const Text("Mobile A5 + Inner A4 + Cover A4"),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareAll3();
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text("Share PDF yang sedang dibuka"),
              subtitle: Text("Saat ini: ${_kindLabel()}"),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareCurrent();
              },
            ),
            if (Platform.isAndroid) ...[
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text("Save 3 PDF ke Downloads"),
                subtitle: const Text("Downloads/WartaJemaat"),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _saveAllAndroid();
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_for_offline),
                title: const Text("Save PDF yang sedang dibuka"),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _saveCurrentAndroid();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text("Open Downloads"),
                onTap: () async {
                  Navigator.pop(ctx);
                  await openDownloadsApp();
                },
              ),
            ],
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _currentBytes();

    return Scaffold(
      appBar: AppBar(
        title: Text("Preview: ${_kindLabel()}"),
        actions: [
          _themeChip(),
          Row(
            children: [
              Text(_fullMode ? "FULL" : "JEMAAT", style: const TextStyle(fontWeight: FontWeight.w800)),
              Switch.adaptive(
                value: _fullMode,
                onChanged: (v) async {
                  setState(() {
                    _fullMode = v;
                    _a5 = null;
                    _inner = null;
                    _cover = null;
                  });
                  _input = _input?.copyWith(fullMode: v);
                  await _init();
                },
              ),
            ],
          ),
          IconButton(onPressed: _openActions, icon: const Icon(Icons.more_vert)),
          IconButton(onPressed: _init, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: "Mobile"), Tab(text: "Inner"), Tab(text: "Cover")],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_err != null)
              ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_err!)))
              : (bytes == null)
                  ? const Center(child: Text("Belum ada PDF."))
                  : PdfPreview(
                      build: (_) async => bytes,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      allowSharing: true,
                      allowPrinting: true,
                    ),
    );
  }
}
