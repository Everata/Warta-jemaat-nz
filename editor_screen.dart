import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/warta_models.dart';
import 'preview_screen.dart';

import 'widgets/item_edit_dialogs.dart';
import 'widgets/reorder_list_tile.dart';

import '../preview/pick_cover_image.dart';
import '../preview/qr_png.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

  final _church = TextEditingController(text: "GPIB Nazareth Jakarta");
  final _address = TextEditingController(text: "Jakarta, Indonesia");
  final _date = TextEditingController(text: "22 Februari 2026");
  final _theme = TextEditingController(text: "Hidup dalam Kasih");

  Uint8List? _coverImageBytes;
  Uint8List? _qrPngBytes;
  final _qrDataText = TextEditingController(text: "https://contoh.link/persembahan");

  final List<LiturgiLine> _liturgi = [
    LiturgiLine("Votum & Salam"),
    LiturgiLine("Nyanyian Pembukaan"),
    LiturgiLine("Pengakuan Dosa"),
    LiturgiLine("Pemberitaan Anugerah"),
    LiturgiLine("Pembacaan Firman"),
    LiturgiLine("Khotbah"),
    LiturgiLine("Persembahan"),
    LiturgiLine("Berkat"),
  ];

  final List<PetugasItem> _petugas = [
    PetugasItem("Pelayan Firman", "Pdt. Contoh"),
    PetugasItem("Liturgos", "Penatua A"),
    PetugasItem("Pemusik", "Tim Musik"),
  ];

  final List<PengumumanItem> _pengumuman = [
    PengumumanItem(
      title: "Pelayanan Pemuda",
      time: "Sabtu, 19.00 WIB",
      place: "Ruang Serbaguna",
      body: "Undang semua pemuda untuk hadir.",
    ),
    PengumumanItem(
      title: "Katekisasi",
      time: "Rabu, 18.30 WIB",
      place: "Ruang Kelas",
      body: "Pendaftaran dibuka sampai akhir bulan.",
    ),
  ];

  final List<DoaLine> _doa = [
    DoaLine("Doakan jemaat yang sakit dan dalam pemulihan."),
    DoaLine("Doakan pelayanan anak dan remaja."),
  ];

  @override
  void dispose() {
    _tabs.dispose();
    _church.dispose();
    _address.dispose();
    _date.dispose();
    _theme.dispose();
    _qrDataText.dispose();
    super.dispose();
  }

  void _openPreview() {
    final cover = CoverData(
      churchName: _church.text.trim(),
      churchAddress: _address.text.trim().isEmpty ? null : _address.text.trim(),
      dateLabel: _date.text.trim(),
      themeTitle: _theme.text.trim(),
      backgroundImageBytes: _coverImageBytes,
    );

    final inner = InnerData(
      petugas: List.of(_petugas),
      pengumuman: List.of(_pengumuman),
      liturgi: List.of(_liturgi),
      doa: List.of(_doa),
      qrPngBytes: _qrPngBytes,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(coverData: cover, innerData: inner)),
    );
  }

  void _reorder<T>(List<T> list, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
    });
  }

  Widget _tabInfo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Info Edisi", style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        TextField(controller: _church, decoration: const InputDecoration(labelText: "Nama Gereja")),
        TextField(controller: _address, decoration: const InputDecoration(labelText: "Alamat (opsional)")),
        TextField(controller: _date, decoration: const InputDecoration(labelText: "Tanggal Edisi")),
        TextField(controller: _theme, decoration: const InputDecoration(labelText: "Tema")),

        const SizedBox(height: 18),
        const Text("Cover Image", style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.10)),
                  color: Colors.black.withOpacity(0.03),
                ),
                child: _coverImageBytes == null
                    ? Center(
                        child: Text(
                          "Belum ada gambar",
                          style: TextStyle(color: Colors.black.withOpacity(0.55)),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(_coverImageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final bytes = await pickCoverImageBytes();
                    if (bytes == null) return;
                    setState(() => _coverImageBytes = bytes);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih"),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _coverImageBytes = null),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Hapus"),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 18),
        const Text("QR Persembahan", style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        TextField(
          controller: _qrDataText,
          decoration: const InputDecoration(
            labelText: "Link / Rekening / Text untuk QR",
            hintText: "contoh: https://… atau nomor rekening",
          ),
          minLines: 1,
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () {
                final data = _qrDataText.text.trim();
                if (data.isEmpty) return;
                final png = generateQrPngBytes(data, size: 420);
                setState(() => _qrPngBytes = png);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("QR berhasil dibuat ✅")),
                );
              },
              icon: const Icon(Icons.qr_code_2),
              label: const Text("Generate QR"),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () => setState(() => _qrPngBytes = null),
              icon: const Icon(Icons.delete_outline),
              label: const Text("Clear"),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.10)),
            color: Colors.black.withOpacity(0.03),
          ),
          child: _qrPngBytes == null
              ? Center(child: Text("QR belum dibuat", style: TextStyle(color: Colors.black.withOpacity(0.55))))
              : Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.memory(_qrPngBytes!, fit: BoxFit.contain),
                ),
        ),

        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _openPreview,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Preview & Export PDF"),
        ),

        const SizedBox(height: 10),
        Text(
          "Tips:\n• Cover image mengaktifkan auto accent & cover contrast.\n• QR tampil di Mobile A5 & Inner A4.",
          style: TextStyle(color: Colors.black.withOpacity(0.65), fontSize: 12),
        ),
      ],
    );
  }

  Widget _tabHeader({
    required String title,
    required String subtitle,
    required Future<void> Function() onAdd,
    Future<void> Function()? onImport,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.08))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6))),
            ]),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text("Tambah"),
              ),
              if (onImport != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text("Import"),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabLiturgi() {
    return Column(
      children: [
        _tabHeader(
          title: "Liturgi",
          subtitle: "Drag untuk urutkan. Tap edit untuk ubah. Bisa import paragraf.",
          onAdd: () async {
            final txt = await showSingleLineDialog(context, title: "Tambah Liturgi", hint: "Contoh: Nyanyian Pembukaan");
            if (txt == null) return;
            setState(() => _liturgi.add(LiturgiLine(txt)));
          },
          onImport: () async {
            final parts = await showImportParagraphsDialog(context, title: "Import Liturgi");
            if (parts == null) return;
            setState(() => _liturgi.addAll(parts.map(LiturgiLine.new)));
          },
        ),
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.all(8),
            onReorder: (o, n) => _reorder(_liturgi, o, n),
            children: [
              for (int i = 0; i < _liturgi.length; i++)
                Card(
                  key: ValueKey("lit-$i-${_liturgi[i].line}"),
                  child: ReorderTile(
                    title: _liturgi[i].line,
                    onEdit: () async {
                      final txt = await showSingleLineDialog(context, title: "Edit Liturgi", initial: _liturgi[i].line);
                      if (txt == null) return;
                      setState(() => _liturgi[i] = LiturgiLine(txt));
                    },
                    onDelete: () => setState(() => _liturgi.removeAt(i)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabPetugas() {
    return Column(
      children: [
        _tabHeader(
          title: "Petugas",
          subtitle: "Drag untuk urutkan. Format role + nama.",
          onAdd: () async {
            final item = await showPetugasDialog(context);
            if (item == null) return;
            setState(() => _petugas.add(item));
          },
        ),
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.all(8),
            onReorder: (o, n) => _reorder(_petugas, o, n),
            children: [
              for (int i = 0; i < _petugas.length; i++)
                Card(
                  key: ValueKey("ptg-$i-${_petugas[i].role}-${_petugas[i].name}"),
                  child: ReorderTile(
                    title: "${_petugas[i].role}: ${_petugas[i].name}",
                    onEdit: () async {
                      final item = await showPetugasDialog(context, initial: _petugas[i]);
                      if (item == null) return;
                      setState(() => _petugas[i] = item);
                    },
                    onDelete: () => setState(() => _petugas.removeAt(i)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabPengumuman() {
    return Column(
      children: [
        _tabHeader(
          title: "Pengumuman",
          subtitle: "Card modern. Bisa import paragraf jadi banyak item cepat.",
          onAdd: () async {
            final item = await showPengumumanDialog(context);
            if (item == null) return;
            setState(() => _pengumuman.add(item));
          },
          onImport: () async {
            final parts = await showImportParagraphsDialog(
              context,
              title: "Import Pengumuman",
              helper:
                  "Tempel daftar pengumuman. Tiap paragraf jadi 1 item.\nBaris pertama jadi Judul, sisanya jadi Body.",
            );
            if (parts == null) return;

            setState(() {
              for (final p in parts) {
                final lines = p.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                if (lines.isEmpty) continue;
                final title = lines.first;
                final body = lines.length > 1 ? lines.skip(1).join("\n") : null;
                _pengumuman.add(PengumumanItem(title: title, body: body));
              }
            });
          },
        ),
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.all(8),
            onReorder: (o, n) => _reorder(_pengumuman, o, n),
            children: [
              for (int i = 0; i < _pengumuman.length; i++)
                Card(
                  key: ValueKey("ann-$i-${_pengumuman[i].title}"),
                  child: ReorderTile(
                    title: _pengumuman[i].title,
                    subtitle: [
                      if (_pengumuman[i].time != null) _pengumuman[i].time!,
                      if (_pengumuman[i].place != null) _pengumuman[i].place!,
                      if (_pengumuman[i].body != null) _pengumuman[i].body!,
                    ].where((s) => s.trim().isNotEmpty).join(" · "),
                    onEdit: () async {
                      final item = await showPengumumanDialog(context, initial: _pengumuman[i]);
                      if (item == null) return;
                      setState(() => _pengumuman[i] = item);
                    },
                    onDelete: () => setState(() => _pengumuman.removeAt(i)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabDoa() {
    return Column(
      children: [
        _tabHeader(
          title: "Pokok Doa",
          subtitle: "Drag untuk urutkan. Bisa import paragraf.",
          onAdd: () async {
            final txt = await showSingleLineDialog(context, title: "Tambah Pokok Doa", hint: "Contoh: Doakan jemaat…");
            if (txt == null) return;
            setState(() => _doa.add(DoaLine(txt)));
          },
          onImport: () async {
            final parts = await showImportParagraphsDialog(context, title: "Import Pokok Doa");
            if (parts == null) return;
            setState(() => _doa.addAll(parts.map(DoaLine.new)));
          },
        ),
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.all(8),
            onReorder: (o, n) => _reorder(_doa, o, n),
            children: [
              for (int i = 0; i < _doa.length; i++)
                Card(
                  key: ValueKey("doa-$i-${_doa[i].line}"),
                  child: ReorderTile(
                    title: _doa[i].line,
                    onEdit: () async {
                      final txt = await showSingleLineDialog(context, title: "Edit Pokok Doa", initial: _doa[i].line);
                      if (txt == null) return;
                      setState(() => _doa[i] = DoaLine(txt));
                    },
                    onDelete: () => setState(() => _doa.removeAt(i)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Warta Jemaat – Editor"),
        actions: [
          IconButton(
            tooltip: "Preview",
            onPressed: _openPreview,
            icon: const Icon(Icons.preview),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: "Info"),
            Tab(text: "Liturgi"),
            Tab(text: "Petugas"),
            Tab(text: "Pengumuman"),
            Tab(text: "Doa"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _tabInfo(),
          _tabLiturgi(),
          _tabPetugas(),
          _tabPengumuman(),
          _tabDoa(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPreview,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Preview PDF"),
      ),
    );
  }
}
