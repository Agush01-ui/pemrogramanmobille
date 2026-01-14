# Priority Hub - To-Do List Application

Aplikasi ini dikembangkan untuk memenuhi tugas pemrograman mobile dengan fitur-fitur wajib yang telah diimplementasikan secara lengkap. Berikut adalah dokumentasi teknis mengenai bagaimana setiap fitur wajib diterapkan dalam kode.

## 📋 Fitur Wajib & Implementasi

### 1. UI & Navigation (Material Design & Responsive)
*   **Material Design**: Aplikasi menggunakan widget bawaan Flutter Material Design seperti `Scaffold`, `AppBar`, `Card`, `FloatingActionButton`, dan `ElevatedButton`.
*   **Responsive Layout**:
    *   Menggunakan `MediaQuery` untuk mendapatkan ukuran layar (lihat `login_screen.dart`).
    *   Menggunakan `LayoutBuilder` atau `Flexible`/`Expanded` (dalam `Column` dan `Row` di `home_screen.dart`) untuk memastikan tampilan menyesuaikan berbagai ukuran layar tanpa *hardcode* pixel.
*   **Navigation**: Menggunakan `Navigator.pushReplacement` untuk perpindahan antar halaman (Splash -> Login -> Home) dengan animasi transisi standar Android/iOS.

### 2. State Management (Provider)
Aplikasi menerapkan **Provider** sebagai *global state management*.
*   **Implementasi**:
    *   `MultiProvider` diletakkan di root aplikasi (`main.dart`) untuk membungkus `MaterialApp`.
    *   **Provider File**: `lib/providers/weather_provider.dart`.
    *   **Usage**: UI (`home_screen.dart`) menggunakan `Consumer<WeatherProvider>` atau `Provider.of` untuk mendengarkan perubahan data cuaca (`notifyListeners()`) dan membangun ulang widget secara otomatis.

### 3. Reactive Programming
UI bereaksi otomatis terhadap perubahan data tanpa perlu intervensi manual yang rumit.
*   **Implementasi**:
    *   Pada **Cuaca**: Saat `WeatherProvider` memanggil `notifyListeners()`, widget `Consumer` di `home_screen.dart` otomatis memperbarui tampilan suhu dan ikon cuaca.
    *   Pada **Todo List**: Menggunakan `setState` dan *callback* setelah operasi database (CRUD SQLite) untuk me-refresh tampilan daftar tugas secara real-time.

### 4. Integrasi API Eksternal (Open-Meteo Weather API)
Menggunakan API publik gratis dari Open-Meteo untuk menampilkan data cuaca.
*   **API URL**: `https://api.open-meteo.com/v1/forecast`
*   **Implementasi**:
    *   **Service**: `lib/data/services/weather_service.dart`. Menggunakan paket `http` untuk mengirim request GET dengan parameter Latitude dan Longitude dinamis.
    *   **JSON Parsing**: Data JSON dikonversi menjadi objek Dart melalui `WeatherModel.fromJson` di `lib/data/models/weather_model.dart`.

### 5. Local Storage / Database
Aplikasi menerapkan **DUA** jenis penyimpanan lokal untuk keandalan maksimal:
1.  **SharedPreferences** (Wajib):
    *   Digunakan untuk menyimpan **Preferensi Tema** (Dark/Light mode) dan **Status Login**.
    *   Digunakan juga untuk menyimpan *cache* lokasi terakhir (`last_lat`, `last_long`).
    *   Lokasi Kode: `lib/main.dart` (Tema) dan `lib/providers/weather_provider.dart` (Cache Lokasi).
2.  **SQLite (sqflite)**:
    *   Digunakan untuk menyimpan data user (registrasi/login) dan daftar tugas (To-Do List).
    *   Lokasi Kode: `lib/database_helper.dart`.

### 6. Location Based Service (GPS)
Aplikasi mengakses sensor GPS perangkat untuk mendapatkan lokasi akurat pengguna.
*   **Implementasi**:
    *   **Dependency**: Menggunakan paket `geolocator`.
    *   **Permission**: Menggunakan `permission_handler` untuk meminta izin lokasi pada Android (`AndroidManifest.xml` telah dikonfigurasi).
    *   **Service**: `lib/data/services/location_service.dart`. Fungsi `getCurrentLocation()` menangani pengecekan izin dan pengambilan koordinat.
    *   **Fitur**: Lokasi pengguna digunakan sebagai parameter untuk memanggil API Cuaca, sehingga cuaca yang tampil adalah cuaca di lokasi pengguna saat ini.

### 7. Dependency Injection & Clean Architecture
Struktur kode aplikasi dipisahkan dengan jelas untuk memudahkan *maintenance* (pemeliharaan).

*   **UI Layer (Tampilan)**:
    *   Folder: `lib/ui/screens/` & `lib/ui/widgets/`
    *   Berisi: `HomeScreen`, `LoginScreen`, `SplashScreen`. Hanya fokus pada tampilan.
*   **Service/Repository Layer (Data Source)**:
    *   Folder: `lib/data/services/`
    *   Berisi: `WeatherService` (ambil data API), `LocationService` (ambil data GPS). UI tidak tahu menahu soal HTTP atau GPS, hanya memanggil service ini.
*   **State Management Layer (Penghubung)**:
    *   Folder: `lib/providers/`
    *   Berisi: `WeatherProvider`. Bertugas memanggil Service, menyimpan data di memori, dan memberi tahu UI jika ada update.
