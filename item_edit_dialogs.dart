import 'package:flutter/material.dart';
import '../../models/warta_models.dart';

Future<PetugasItem?> showPetugasDialog(
  BuildContext context, {
  PetugasItem? initial,
}) async {
  final role = TextEditingController(text: initial?.role ?? "");
  final name = TextEditingController(text: initial?.name ?? "");

  final res = await showDialog<PetugasItem>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(initial == null ? "Tambah Petugas" : "Edit Petugas"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: role, decoration: const InputDecoration(labelText: "Peran (contoh: Liturgos)")),
          TextField(controller: name, decoration: const InputDecoration(labelText: "Nama")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () {
            final r = role.text.trim();
            final n = name.text.trim();
            if (r.isEmpty || n.isEmpty) return;
            Navigator.pop(context, PetugasItem(r, n));
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );

  role.dispose();
  name.dispose();
  return res;
}

Future<PengumumanItem?> showPengumumanDialog(
  BuildContext context, {
  PengumumanItem? initial,
}) async {
  final title = TextEditingController(text: initial?.title ?? "");
  final time = TextEditingController(text: initial?.time ?? "");
  final place = TextEditingController(text: initial?.place ?? "");
  final body = TextEditingController(text: initial?.body ?? "");

  final res = await showDialog<PengumumanItem>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(initial == null ? "Tambah Pengumuman" : "Edit Pengumuman"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: "Judul")),
            TextField(controller: time, decoration: const InputDecoration(labelText: "Waktu (opsional)")),
            TextField(controller: place, decoration: const InputDecoration(labelText: "Tempat (opsional)")),
            TextField(
              controller: body,
              decoration: const InputDecoration(labelText: "Isi (opsional)"),
              minLines: 3,
              maxLines: 8,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () {
            final t = title.text.trim();
            if (t.isEmpty) return;
            Navigator.pop(
              context,
              PengumumanItem(
                title: t,
                time: time.text.trim().isEmpty ? null : time.text.trim(),
                place: place.text.trim().isEmpty ? null : place.text.trim(),
                body: body.text.trim().isEmpty ? null : body.text.trim(),
              ),
            );
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );

  title.dispose();
  time.dispose();
  place.dispose();
  body.dispose();
  return res;
}

Future<String?> showSingleLineDialog(
  BuildContext context, {
  required String title,
  String? initial,
  String hint = "Tulis teks…",
}) async {
  final c = TextEditingController(text: initial ?? "");
  final res = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        decoration: InputDecoration(hintText: hint),
        minLines: 2,
        maxLines: 8,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () {
            final v = c.text.trim();
            if (v.isEmpty) return;
            Navigator.pop(context, v);
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );
  c.dispose();
  return res;
}

Future<List<String>?> showImportParagraphsDialog(
  BuildContext context, {
  required String title,
  String helper =
      "Tempel teks panjang di bawah. Sistem akan memotong per paragraf (baris kosong) dan menghapus baris kosong.",
}) async {
  final c = TextEditingController();
  final res = await showDialog<List<String>>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(helper, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: c,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Tempel di sini…\n\nParagraf dipisahkan dengan baris kosong.",
              ),
              minLines: 8,
              maxLines: 14,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () {
            final raw = c.text;
            final parts = raw
                .split(RegExp(r'\n\s*\n'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            if (parts.isEmpty) return;
            Navigator.pop(context, parts);
          },
          child: const Text("Import"),
        ),
      ],
    ),
  );
  c.dispose();
  return res;
}
