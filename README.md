<p align="center">
  <img src="assets/images/solea_readme_banner.png" alt="SOLEA — Step into your own story" width="100%" />
</p>

<p align="center">
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-Web-24251F?style=flat-square&logo=flutter&logoColor=E9DFC4" alt="Flutter Web" /></a>
  <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-3.x-24251F?style=flat-square&logo=dart&logoColor=8BC5FF" alt="Dart" /></a>
  <a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Firebase-Backend-24251F?style=flat-square&logo=firebase&logoColor=FFCA28" alt="Firebase" /></a>
  <img src="https://img.shields.io/badge/Status-In%20Development-24251F?style=flat-square" alt="In development" />
</p>

<h1 align="center">SOLEA</h1>
<p align="center"><strong>A sneaker shopping experience built for everyday movement.</strong></p>
<p align="center">Aplikasi e-commerce sneakers berbasis Flutter Web dengan autentikasi Firebase dan penyimpanan data pengguna melalui Cloud Firestore.</p>

---

## The experience

SOLEA dirancang untuk menghadirkan pengalaman belanja sneakers yang sederhana dan modern — mulai dari menjelajahi katalog, melihat detail produk, sampai mengelola pesanan dari satu tempat.

<table>
  <tr>
    <td width="50%" valign="top">
      <h3>01 / Explore</h3>
      Jelajahi katalog sneakers, gunakan kategori, dan urutkan produk berdasarkan harga atau rating.
    </td>
    <td width="50%" valign="top">
      <h3>02 / Personalize</h3>
      Buat akun, kelola profil dan alamat, lalu simpan produk favorit ke wishlist.
    </td>
  </tr>
  <tr>
    <td width="50%" valign="top">
      <h3>03 / Shop</h3>
      Pilih ukuran dan jumlah, kelola keranjang, serta isi informasi pengiriman saat checkout.
    </td>
    <td width="50%" valign="top">
      <h3>04 / Track</h3>
      Lihat daftar pesanan dan temukan halaman bantuan atau kontak ketika diperlukan.
    </td>
  </tr>
</table>

## Feature overview

| Area | Yang tersedia |
|:--|:--|
| **Account** | Registrasi, login, logout, dan verifikasi email melalui Firebase Authentication |
| **Discover** | Katalog sneakers, kategori, pengurutan produk, dan halaman detail |
| **Shopping** | Pilihan ukuran, jumlah produk, keranjang belanja, dan wishlist |
| **Orders** | Form checkout dan halaman daftar pesanan |
| **Profile** | Informasi personal, alamat, keamanan akun, metode pembayaran, notifikasi, dan FAQ |
| **Support** | Halaman layanan dan kontak SOLEA |

## Built with

<p>
  <img src="https://img.shields.io/badge/Flutter-Framework-20221D?style=flat-square&logo=flutter&logoColor=8BC5FF" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-Language-20221D?style=flat-square&logo=dart&logoColor=8BC5FF" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase_Auth-Authentication-20221D?style=flat-square&logo=firebase&logoColor=FFCA28" alt="Firebase Auth" />
  <img src="https://img.shields.io/badge/Cloud_Firestore-Database-20221D?style=flat-square&logo=firebase&logoColor=FFCA28" alt="Cloud Firestore" />
</p>

| Technology | Role |
|:--|:--|
| Flutter + Dart | UI dan logika aplikasi |
| Firebase Authentication | Autentikasi pengguna |
| Cloud Firestore | Penyimpanan data pengguna dan data terkait yang sudah dihubungkan |
| Firebase Hosting | Target deployment untuk versi web |

## Run locally

### Requirements

- Flutter SDK yang memenuhi batas SDK di `pubspec.yaml`
- Browser modern, misalnya Google Chrome
- Project Firebase dengan konfigurasi aplikasi yang sesuai

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure Firebase

Project ini menyertakan `lib/firebase_options.dart` untuk konfigurasi Firebase yang sudah dipilih. Jika memakai project Firebase lain, buat project melalui [Firebase Console](https://console.firebase.google.com/), aktifkan **Email/Password** pada Authentication, siapkan Cloud Firestore, lalu generate ulang konfigurasi dengan FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Tinjau **Firestore Security Rules** sebelum aplikasi digunakan di lingkungan publik. Jangan memakai rules terbuka untuk produksi.

### 3. Start the app

```bash
flutter run -d chrome
```

## Deploy to Firebase Hosting

Build versi web terlebih dahulu:

```bash
flutter build web
```

Jika Firebase CLI belum terpasang atau belum login:

```bash
npm install -g firebase-tools
firebase login
```

Siapkan Hosting satu kali dari root project:

```bash
firebase init hosting
```

Pilih project Firebase yang sesuai dan atur **public directory** ke `build/web`. Untuk Flutter Web, pilih konfigurasi single-page app jika diperlukan, dan jangan menimpa `web/index.html`. Setelah `firebase.json` berisi konfigurasi Hosting yang benar, jalankan:

```bash
firebase deploy --only hosting
```

> Catatan: `firebase init hosting` hanya perlu dilakukan saat konfigurasi Hosting belum tersedia. Pastikan `firebase.json` memiliki bagian `hosting` sebelum deploy.

## Project structure

```text
lib/
├── controllers/     # Logika autentikasi dan aktivitas belanja
├── core/            # Tema, helper, dan komponen inti
├── models/          # Model data aplikasi
├── views/
│   ├── auth/        # Login dan registrasi
│   ├── home/        # Home, katalog, detail produk, layanan, kontak
│   ├── landing/     # Landing page
│   ├── order/       # Daftar pesanan
│   ├── profile/     # Profil dan pengaturan akun
│   └── shopping/    # Keranjang, checkout, dan wishlist
├── firebase_options.dart
└── main.dart

assets/images/       # Logo dan gambar produk
web/                 # Entry point Flutter Web
pubspec.yaml         # Dependencies dan konfigurasi Flutter
README.md
```

## Development notes

- Data katalog produk saat ini masih didefinisikan secara lokal di `ProductController`, belum diambil dari koleksi produk Firestore.
- Pembayaran checkout masih berupa simulasi; belum terhubung ke payment gateway.
- Fitur yang menggunakan Firebase memerlukan konfigurasi layanan dan Security Rules yang sesuai.
- Screenshot aplikasi dan tautan demo dapat ditambahkan setelah versi publik tersedia.

---

<p align="center">
  <sub>SOLEA · Sneaker Store · Built with Flutter</sub>
</p>
