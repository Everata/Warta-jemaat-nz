# Warta Jemaat (Flutter)

Aplikasi Android/Flutter untuk membuat PDF Warta Jemaat:
- Preview 3 tab: Mobile A5, Inner A4, Cover A4
- Toggle mode: JEMAAT / FULL
- Export Share (semua platform)
- Save ke Downloads/WartaJemaat (Android, via MediaStore)
- Progress + Cancel
- Cover image picker + QR generator (PNG bytes)

## Jalankan
```bash
flutter pub get
flutter run
```

## Android permissions
Sudah disiapkan snippet manifest di: `android/app/src/main/AndroidManifest.xml` (lihat file itu).

## Catatan
Ini MVP runnable. Kamu bisa memperkaya layout PDF di folder `lib/pdf/`.
