# Pustakaku

Aplikasi mobile Flutter untuk mencari, menyimpan, dan mengulas buku. Data buku
diambil dari **Open Library API** (open source, tanpa API key), sedangkan akun,
favorit, ulasan, pengumuman, dan push notification ditangani **Firebase**.

Dibuat sebagai Projek Akhir mata kuliah Pemrograman Mobile.

## Tentang Aplikasi

**Pustakaku** adalah rak buku digital di saku. Pengguna bisa menjelajah jutaan judul
dari Open Library, menyimpan buku yang ingin dibaca ke rak pribadi, memberi rating dan
ulasan, serta menerima pengumuman dari admin lewat push notification. Tampilannya
bergaya **Perpustakaan Klasik**: kertas krem, hijau tua khas perpustakaan, aksen
kuningan, dan judul berhuruf serif, supaya terasa seperti membuka katalog perpustakaan.

### Alur penggunaan

1. **Daftar / masuk** dengan email dan kata sandi. Akun baru otomatis berperan `user`.
2. **Jelajah**: lihat buku tren hari ini, pilih kategori (Fiksi, Bisnis, Psikologi,
   Sejarah, Sains, Fantasi, Romansa), atau cari judul, penulis, maupun ISBN.
3. **Detail buku**: sampul besar, tahun terbit, jumlah halaman, rating, deskripsi,
   subjek, dan ulasan pembaca lain.
4. **Simpan ke rak**: buku masuk ke tab *Rak bukuku* dan tersinkron di semua perangkat.
5. **Ulas**: beri 1–5 bintang dan komentar. Ulasan bisa dihapus oleh penulisnya atau admin.
6. **Pengumuman**: admin menulis pengumuman; pengguna melihatnya secara realtime dan
   menerima push notification.
7. **Admin**: tab khusus admin untuk melihat statistik pengguna dan mengubah role.

### Teknologi

| Bagian | Yang dipakai |
|--------|--------------|
| Framework | Flutter 3.47, Dart 3.13, Material 3 |
| State management | Riverpod 3 |
| Backend | Firebase Authentication, Cloud Firestore, Cloud Messaging (proyek `pustakaku-8c065`) |
| Data buku | Open Library API (tanpa API key) |
| Notifikasi | `firebase_messaging` + `flutter_local_notifications` |
| Tampilan | Font Fraunces & Plus Jakarta Sans, tema terang/gelap lewat `ThemeExtension`, `cached_network_image` |

### Unduh

APK Android siap pasang tersedia di halaman
[Releases](https://github.com/isyraqawwaluthorid/pustakaku/releases/latest)
(Android 6.0 ke atas). Setelah memasang, buat akun baru dari layar *Daftar*.

| Versi | Tanggal | Isi |
|-------|---------|-----|
| v1.1.0 | 22 Nov 2026 | Tampilan baru Perpustakaan Klasik, ikon & splash baru, perbaikan sampul yang tidak muncul, label navigasi tidak terlipat |
| v1.0.0 | 16 Nov 2026 | Rilis pertama: semua fitur, terhubung ke Firebase, push notification terverifikasi |

## Pemenuhan Minimum Requirement

| # | Ketentuan | Implementasi | File utama |
|---|-----------|--------------|------------|
| 1 | **Integrasi dengan Firebase** | Firebase Core, **Authentication** (email/kata sandi), **Cloud Firestore** (profil, favorit, ulasan, pengumuman, realtime stream), **Cloud Messaging**, Cloud Functions | `lib/main.dart`, `lib/services/auth_service.dart`, `lib/services/firestore_service.dart`, `firestore.rules`, `functions/index.js` |
| 2 | **State management** | **Riverpod 3**: `Provider`, `StreamProvider`, `FutureProvider.family`, `Notifier` (pencarian + debounce + infinite scroll), `AsyncNotifier` (form auth), provider turunan (`isAdminProvider`, `isFavoriteProvider`, `averageRatingProvider`) | `lib/providers/*.dart` |
| 3 | **Advance Dart** | `sealed class` + pattern matching (`Result<T>`, `SearchState`), generics (`_get<T>`, `AsyncValueWidget<T>`), extension methods, mixin (`LoggerMixin`, `ValidatorsMixin`), enhanced enum (`UserRole`, `CoverSize`), records (`SearchPage`), `switch` expression dengan guard `when`, isolate (`compute`) untuk parsing JSON, `Comparable`, `Stream`/`async*`, `late`/null-safety | `lib/core/*.dart`, `lib/models/*.dart`, `lib/services/open_library_api.dart` |
| 4 | **Push Notifications** | Firebase Cloud Messaging: izin notifikasi, token disimpan ke Firestore, subscribe topic `pengumuman`, notifikasi foreground via `flutter_local_notifications`, handler background, tap notifikasi membuka tab Pengumuman. Cloud Function mengirim FCM otomatis saat admin membuat pengumuman | `lib/services/notification_service.dart`, `lib/providers/notification_provider.dart`, `functions/index.js` |
| 5 | **API (open source)** | [Open Library API](https://openlibrary.org/developers/api): pencarian (`/search.json`), tren (`/trending/daily.json`), detail karya (`/works/{id}.json`), sampul (`covers.openlibrary.org`) | `lib/services/open_library_api.dart` |
| 6 | **Authentication dan Authorization** | *Authentication*: daftar, masuk, reset kata sandi, keluar (Firebase Auth). *Authorization*: role `user`/`admin` di `users/{uid}.role`; tab Admin & tombol buat/hapus pengumuman hanya untuk admin; ulasan hanya bisa dihapus pemilik atau admin; semuanya ditegakkan ulang di **Firestore Security Rules** | `lib/providers/auth_provider.dart`, `lib/screens/admin_screen.dart`, `firestore.rules` |

## Tampilan

Gaya **Perpustakaan Klasik**: latar kertas krem, hijau tua, aksen kuningan, judul serif
[Fraunces](https://fonts.google.com/specimen/Fraunces) dan teks
[Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans) (keduanya SIL OFL 1.1,
dibundel di `assets/fonts`). Semua token warna ada di `lib/core/theme.dart` (`AppPalette`,
sebuah `ThemeExtension`), termasuk varian mode gelap.

- Ikon aplikasi, splash screen, dan ikon notifikasi dibuat dari `assets/brand/`
  (`dart run flutter_launcher_icons`, `dart run flutter_native_splash:create`).
- Sampul tanpa gambar atau yang masih dimuat diganti sampul cadangan berwarna berisi judul.
- `lib/services/cover_cache_manager.dart` menolak unduhan sampul yang kosong atau bukan
  gambar, sehingga tidak tersimpan di cache dan dicoba lagi lain kali.

## Fitur

- **Jelajah** – carousel buku tren harian, chip kategori (Fiksi, Bisnis, Psikologi, dst. lewat pencarian `subject:`), pencarian judul/penulis/ISBN dengan debounce 500 ms dan *infinite scroll*.
- **Detail buku** – sampul, deskripsi, subjek, rating Open Library, rating rata-rata pembaca Pustakaku, daftar ulasan, tulis ulasan.
- **Favorit** – rak sampul tiga kolom; tersimpan di Firestore (`users/{uid}/favorites`) dan tersinkron realtime antar perangkat.
- **Pengumuman** – daftar pengumuman realtime; admin membuat pengumuman dan semua pengguna menerima push notification (otomatis bila Cloud Function di-deploy, lihat bagian Push notification; tanpa itu dikirim dari Firebase Console ke topic `pengumuman`).
- **Panel Admin** – statistik pengguna dan ubah role (user ⇄ admin).
- **Profil** – info akun, badge role, uji notifikasi lokal, lihat token FCM, keluar.

## Struktur kode

```
lib/
├── main.dart                     # init Firebase + FCM, ProviderScope, AuthGate
├── firebase_options.dart         # dihasilkan oleh `flutterfire configure`
├── core/
│   ├── result.dart               # sealed Result<T>, guard(), AppException
│   ├── extensions.dart           # StringX, DateTimeX, IterableX, BuildContextX
│   ├── mixins.dart               # LoggerMixin, ValidatorsMixin
│   └── theme.dart
├── models/                       # Book, BookDetail, AppUser + UserRole, Review, Announcement
├── services/
│   ├── open_library_api.dart     # HTTP + compute() isolate
│   ├── auth_service.dart         # Firebase Auth
│   ├── firestore_service.dart    # Cloud Firestore
│   └── notification_service.dart # FCM + notifikasi lokal
├── providers/                    # Riverpod (state management)
├── screens/                      # login, register, main_shell, home, book_detail,
│                                 # favorites, announcements, admin, profile
└── widgets/                      # BookCard, BookCover, RatingStars, AsyncValueWidget, EmptyState
functions/index.js                # Cloud Function: pengumuman baru -> FCM topic
firestore.rules                   # Authorization sisi server
firestore.indexes.json            # index komposit untuk query ulasan
```

## Struktur data Firestore

```
users/{uid}                     { email, displayName, role: "user"|"admin", fcmToken, fid, createdAt }
users/{uid}/favorites/{workId}  { workId, title, authors, coverId, ..., savedAt }
reviews/{id}                    { bookId, uid, authorName, rating 1-5, text, createdAt }
announcements/{id}              { title, body, authorName, authorUid, createdAt }
```

## Cara menjalankan

### Mode demo lokal (tanpa akun Firebase, tanpa Android SDK)

Selama `lib/firebase_options.dart` masih berisi projectId `demo-pustakaku`,
aplikasi otomatis terhubung ke **Firebase Local Emulator Suite**. Cukup Node.js,
Java 11+, dan Chrome:

```bash
npm install -g firebase-tools
firebase emulators:start --only auth,firestore --project demo-pustakaku   # terminal 1
node tool/seed_emulator.mjs                                                 # terminal 2: akun demo
flutter run -d chrome --web-port=5000                                       # terminal 2
```

Akun demo: `admin@pustakaku.id` / `admin123` (admin) dan `budi@pustakaku.id` / `budi123` (user).
Di layar login tersedia tombol **Admin demo** / **Pengguna demo** (hanya muncul pada mode demo).
Emulator UI (lihat data Auth & Firestore): http://localhost:4000.
Push notification FCM tidak aktif di mode ini (tombol "Uji notifikasi lokal" di Profil tetap berfungsi);
fitur lain berjalan penuh. Data emulator hilang saat emulator dimatikan (jalankan seed lagi).

Untuk menjalankan mode demo di **emulator Android** (bukan Chrome), ganti perintah terakhir dengan
`flutter run -d emulator-5554` (atau id emulator Anda dari `flutter devices`). Aplikasi otomatis
memakai alamat `10.0.2.2` untuk mencapai emulator Firebase di komputer host; izin HTTP tanpa TLS
ke alamat itu diatur di `android/app/src/main/res/xml/network_security_config.xml`.


### 1. Prasyarat

- Flutter 3.35+ (dibuat dengan Flutter 3.47 / Dart 3.13)
- Akun Firebase, Node.js 20 (hanya untuk Cloud Functions)

```bash
flutter pub get
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### 2. Hubungkan ke proyek Firebase

> Repositori ini sudah terhubung ke proyek Firebase **`pustakaku-8c065`** (`lib/firebase_options.dart`,
> `.firebaserc`). File `android/app/google-services.json` dan `ios/Runner/GoogleService-Info.plist`
> sengaja tidak ikut di repositori; dapatkan dari pemilik proyek atau jalankan ulang
> `flutterfire configure` dengan akses ke proyek tersebut. Rules dan index Firestore sudah di-deploy.
> Akun yang tersedia: `admin@pustakaku.id` (admin) dan `budi@pustakaku.id` (pengguna).
> Untuk membuat proyek Firebase sendiri, ikuti langkah di bawah.

1. Buat proyek di [Firebase Console](https://console.firebase.google.com).
2. Jalankan di root proyek (menghasilkan `lib/firebase_options.dart`,
   `android/app/google-services.json`, dan `ios/Runner/GoogleService-Info.plist`):

   ```bash
   firebase login
   flutterfire configure --project=<id-proyek> --platforms=android,ios
   ```

3. Di Firebase Console aktifkan:
   - **Authentication → Sign-in method → Email/Password**
   - **Firestore Database** (mode production), lalu deploy rules & index:

     ```bash
     firebase deploy --only firestore
     ```

     atau salin isi `firestore.rules` ke tab *Rules* dan buat index komposit
     `reviews (bookId ASC, createdAt DESC)` saat diminta oleh tautan error di log.
   - **Cloud Messaging** (aktif otomatis).

### 3. Jalankan aplikasi

```bash
flutter run
```

Daftar akun pertama lewat aplikasi, lalu jadikan admin dari Firebase Console:
**Firestore → users → {uid} → role: `admin`**. Ini satu-satunya cara menunjuk admin
pertama, karena Firestore rules melarang siapa pun menaikkan role-nya sendiri.
Perubahan role langsung terlihat di aplikasi tanpa login ulang (stream realtime); setelah
itu admin lain dapat ditunjuk dari tab **Admin** di dalam aplikasi.

### 4. Push notification

Ada dua cara mengirim notifikasi ke semua pengguna:

**a. Otomatis (Cloud Function)** — setiap pengumuman yang dibuat admin dikirim ke
topic `pengumuman`:

```bash
cd functions && npm install && cd ..
firebase deploy --only functions
```

> Cloud Functions membutuhkan paket Blaze (pay-as-you-go) dengan kuota gratis
> 2 juta invokasi/bulan. Region di-set ke `asia-southeast2` (Jakarta).

**b. Manual (tanpa Blaze)** — Firebase Console → **Messaging → New campaign →
Notifications**, target **Topic: `pengumuman`**, atau **Send test message**
dengan token FCM yang bisa disalin dari halaman Profil aplikasi.

> **Catatan emulator Android:** registrasi FCM membutuhkan Google Play Services yang sudah
> check-in ke Google. Pada emulator baru hal ini kadang gagal (`FCM Registration failed`,
> `AUTHENTICATION_FAILED` di logcat) sampai Play Services selesai memperbarui diri atau
> sebuah akun Google ditambahkan di emulator. Pengujian paling andal adalah di HP Android asli.
> Terverifikasi berjalan pada emulator **Android 14 (API 34, image Google Play)**: token FCM tersimpan
> ke `users/{uid}.fcmToken` dan pesan uji dari Firebase Console muncul di panel notifikasi.

Notifikasi yang masuk saat aplikasi terbuka ditampilkan lewat
`flutter_local_notifications`; saat aplikasi di background/tertutup ditampilkan
sistem Android; mengetuk notifikasi membuka tab Pengumuman.

### 5. Uji unit

```bash
flutter test
```

Menguji `Result<T>`, extension methods, dan parsing model Open Library.

## Catatan iOS

Push notification di iOS membutuhkan Apple Developer Program (APNs key diunggah
ke Firebase Console → Project settings → Cloud Messaging) serta *capability*
Push Notifications & Background Modes (Remote notifications) di Xcode.
Pengujian di simulator iOS tidak menerima push FCM; gunakan perangkat fisik.

## Sumber

- Open Library API — https://openlibrary.org/developers/api (CC0 / open source, Internet Archive)
- Firebase for Flutter — https://firebase.google.com/docs/flutter/setup
- Riverpod — https://riverpod.dev
