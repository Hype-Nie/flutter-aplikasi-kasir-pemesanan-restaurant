# Aplikasi Kasir dan Pemesanan Restoran

Aplikasi ini merupakan sistem point-of-sale (POS) dan pemesanan restoran berbasis mobile yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk memfasilitasi dua peran utama: kasir dan pelanggan, dengan alur navigasi dan fungsionalitas yang terpisah sesuai hak akses masing-masing peran.

## Fitur Utama

- **Autentikasi & Otorisasi**: Sistem login dan registrasi berbasis token, dilengkapi dengan pengaman (interceptor) pada setiap permintaan API. Aplikasi akan secara otomatis membaca peran pengguna dari penyimpanan lokal untuk menentukan halaman tujuan awal (Splash).
- **Manajemen Menu dan Kategori**: Katalog menu makanan dan minuman yang terstruktur berdasarkan kategori, lengkap dengan opsi tambahan (addons) yang dinamis.
- **Sistem Keranjang Belanja**: Memungkinkan pelanggan untuk menambah pesanan, mengubah jumlah item, serta mengelola tambahan (addons) di setiap item keranjang sebelum melakukan proses pembayaran.
- **Riwayat dan Manajemen Pesanan**: Pelacakan pesanan dan riwayat transaksi yang mencakup detail lengkap seperti informasi harga satuan, total, dan tambahan yang dipilih.
- **Antarmuka yang Responsif**: Pengalaman pengguna yang mulus didukung oleh komponen antarmuka yang terstruktur dan indikator pemuatan kustom (shimmer effect).

## Arsitektur & Teknologi

Proyek ini mengadopsi standar pengembangan Flutter yang berfokus pada kebersihan kode dan pemisahan tanggung jawab (separation of concerns):

- **Framework**: Flutter
- **Manajemen State**: Riverpod
- **HTTP Client**: Dio (diimplementasikan dengan pola Singleton dan AuthInterceptor)
- **Penyimpanan Lokal**: SharedPreferences (menangani penyimpanan token sesi, peran, dan ID pengguna)
- **Konfigurasi Lingkungan**: `flutter_dotenv` untuk pengelolaan variabel `.env`

### Struktur Proyek

Basis kode diorganisasikan dengan struktur modular:
- `lib/config/`: Menyimpan konfigurasi string, konstanta, dan variabel lingkungan.
- `lib/core/`: Berisi modul inti seperti pengaturan klien jaringan dan kelas utilitas (misal: pemformatan mata uang).
- `lib/features/`: Modul utama aplikasi yang dikelompokkan berdasarkan fitur (`auth`, `customer`, `cashier`). Setiap fitur memiliki batasan yang ketat antara logika bisnis (`domain/entities`, `providers`) dan antarmuka pengguna (`presentation`).

## Persyaratan Sistem

- Flutter SDK (sesuai versi yang ditentukan pada berkas `pubspec.yaml`)
- Perangkat Android, iOS, atau emulator untuk menjalankan dan menguji aplikasi.

## Panduan Instalasi dan Menjalankan Proyek

1. Klon repositori ini ke penyimpanan lokal Anda.
2. Buka terminal atau command prompt pada direktori proyek tersebut.
3. Unduh seluruh dependensi yang diperlukan dengan perintah:
   ```bash
   flutter pub get
   ```
4. Pastikan Anda telah membuat dan mengonfigurasi berkas `.env` di direktori utama sesuai dengan kebutuhan API.
5. Jalankan aplikasi pada perangkat yang terhubung atau emulator:
   ```bash
   flutter run
   ```

## Skrip Pengembangan

Beberapa perintah yang disarankan selama proses pengembangan:
- Analisis dan linting kode: `flutter analyze`
- Pemformatan kode: `dart format lib/`
- Kompilasi untuk rilis (Android): `flutter build apk`
