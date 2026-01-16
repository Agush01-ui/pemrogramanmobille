# Priority Hub - To-Do List Application

Aplikasi ini dikembangkan untuk memenuhi tugas pemrograman mobile dengan fitur-fitur wajib yang telah diimplementasikan secara lengkap. Berikut adalah dokumentasi teknis mengenai bagaimana setiap fitur wajib diterapkan dalam kode.

---

👥 Anggota Tim
| Nama Lengkap | NIM | Tugas |
|---------------|-----|--------|
| Agus Saputra Hamzah | 2310120018 | Ketua Tim - Logika aplikasi & manajemen data To-Do & Perancangan Project |
| Muhammad Abyan Alwafi Effendy | 2310120024 | Integrasi API, Local Base Service & Reactive Progamming |
| Muhammad Dzikri Khairrifo | 2310120024 | Local Base Storage & UI Navigation |

---

## 📋 Fitur Wajib & Implementasi

### 1. UI & Navigation (Material Design & Responsive)
*   **Material Design**: Aplikasi menggunakan widget bawaan Flutter Material Design seperti `Scaffold`, `AppBar`, `Card`, `FloatingActionButton`, dan `ElevatedButton`.
*   **Responsive Layout**:
    *   Menggunakan `MediaQuery` untuk mendapatkan ukuran layar (lihat `login_screen.dart`).
    *   Menggunakan `LayoutBuilder` atau `Flexible`/`Expanded` (dalam `Column` dan `Row` di `home_screen.dart`) untuk memastikan tampilan menyesuaikan berbagai ukuran layar tanpa *hardcode* pixel.
*   **Navigation**: Menggunakan `Navigator.pushReplacement` untuk perpindahan antar halaman (Splash -> Login -> Home) dengan animasi transisi standar Android/iOS.

#### Login 🔐
Priority Hub menerapkan **Authentication System** untuk fitur **Masuk** dan **Daftar**, sehingga pengguna dapat:
- Membuat akun baru dengan aman  
- Masuk ke akun mereka secara terproteksi  
- Menyimpan data tugas secara terpersonal menggunakan **penyimpanan lokal / database**  

Fitur ini memastikan setiap data tugas terkait langsung dengan akun pengguna, menjaga keamanan dan privasi.

<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/db2b15c7-4f5b-421e-835a-7b623b115ee9" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/4640f4a4-7f7f-41a3-b847-6daca0f6e15d" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/587a71b4-8693-437f-b86a-061da3924020" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/ef173fa8-0aef-4ebc-a05b-f278bf47e507" />


---

### 2. State Management State Management & Persistence (Provider + SharedPreferences)
Aplikasi menerapkan **Provider** sebagai *global state management*.
*   **Implementasi State Management**:
    *   **MultiProvider**: Terletak di root (main.dart) untuk menyediakan WeatherProvider (data cuaca) dan ThemeProvider (pengaturan tema) ke seluruh aplikasi.
    *   **Reactive UI**: Widget menggunakan Consumer untuk merespons perubahan data secara otomatis setelah notifyListeners() dipanggil.
    *   **Usage**: UI (`home_screen.dart`) menggunakan `Consumer<WeatherProvider>` atau `Provider.of` untuk mendengarkan perubahan data cuaca (`notifyListeners()`) dan membangun ulang widget secara otomatis.

*   **Implementasi Persistence (Tema)**:
    *   **Dependency**: Menggunakan paket shared_preferences.
    *   **Logic**: Saat pengguna mengubah tema (Light/Dark), aplikasi akan menyimpan nilai boolean ke penyimpanan lokal.
    *   **Initialization**: Saat aplikasi pertama kali dibuka, ThemeProvider akan membaca nilai dari SharedPreferences untuk menentukan tema yang aktif sebelum UI dirender.
   
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/81a89719-3ac3-496f-adc4-36d81945d411" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/614cb9e5-fddd-4b68-b4c7-da0140aaf8df" />

---

### 3. Reactive Programming
UI bereaksi otomatis terhadap perubahan data tanpa perlu intervensi manual yang rumit.
*   **Implementasi**:
    *   Pada **Cuaca**: Saat `WeatherProvider` memanggil `notifyListeners()`, widget `Consumer` di `home_screen.dart` otomatis memperbarui tampilan suhu dan ikon cuaca.
    *   Pada **Todo List**: Menggunakan `setState` dan *callback* setelah operasi database (CRUD SQLite) untuk me-refresh tampilan daftar tugas secara real-time.

<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/de8a5b8c-6ad1-4e5b-a91e-6c2f52e537ca" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/d26ac772-94f7-4b11-b178-e9b298281d1b" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/fc2c44b8-dc2c-45cd-b1b0-c8ddbd24b08b" />
<img width="220" height="450" alt="image" src="https://github.com/Agush01-ui/pemrogramanmobille/blob/main/Hapus%20Taskk.jpeg?raw=true"/>

---

### 4. Integrasi API Eksternal (Open-Meteo Weather API)
Menggunakan API publik gratis dari Open-Meteo untuk menampilkan data cuaca.
*   **API URL**: `https://api.open-meteo.com/v1/forecast`
*   **Implementasi**:
    *   **Service**: `lib/data/services/weather_service.dart`. Menggunakan paket `http` untuk mengirim request GET dengan parameter Latitude dan Longitude dinamis.
    *   **JSON Parsing**: Data JSON dikonversi menjadi objek Dart melalui `WeatherModel.fromJson` di `lib/data/models/weather_model.dart`.

---

### 5. Local Storage / Database
Aplikasi menerapkan **DUA** jenis penyimpanan lokal untuk keandalan maksimal:
1.  **SharedPreferences** (Wajib):
    *   Digunakan untuk menyimpan **Preferensi Tema** (Dark/Light mode) dan **Status Login**.
    *   Digunakan juga untuk menyimpan *cache* lokasi terakhir (`last_lat`, `last_long`).
    *   Lokasi Kode: `lib/main.dart` (Tema) dan `lib/providers/weather_provider.dart` (Cache Lokasi).
2.  **SQLite (sqflite)**:
    *   Digunakan untuk menyimpan data user (registrasi/login) dan daftar tugas (To-Do List).
    *   Lokasi Kode: `lib/database_helper.dart`.

<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/b8c5c301-bb18-4191-b01c-d326ec8be2e9" />

---

### 6. Location Based Service (GPS)
Aplikasi menggabungkan sensor GPS untuk posisi real-time dan OpenStreetMap untuk visualisasi rute dan lokasi.
*   **Implementasi**:
    *   **Dependency**: Menambahkan flutter_map (untuk menampilkan tile OSM) dan latlong2 (untuk manajemen koordinat).
    *   **Permission**: Menggunakan `permission_handler` untuk meminta izin lokasi pada Android (`AndroidManifest.xml` telah dikonfigurasi).
    *   **Service**: `lib/data/services/location_service.dart`. Fungsi `getCurrentLocation()` menangani pengecekan izin dan pengambilan koordinat. Fungsi getRoute() memanggil API OSRM (Open Source Routing Machine) untuk mendapatkan garis rute berdasarkan data OSM.
    *   **Fitur**: Fungsi `Weather Access` sebagai Koordinat yang digunakan untuk API cuaca. Fungsi `Visual Mapping` untuk Menampilkan marker posisi pengguna di atas peta OpenStreetMap. Fungsi `Routing` untuk menghitung dan menampilkan jalur dari lokasi pengguna ke titik tujuan (misalnya lokasi stasiun cuaca atau titik tertentu).

<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/a8d9da02-8842-4c83-a41f-13711380f83e" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/48cb89b9-8cfb-4222-803e-e84cdbec30b7" />
<img width="220" height="450" alt="image" src="https://github.com/user-attachments/assets/199a75fd-07ac-4a7f-9e79-a079553327be" />

---

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
<img width="244" height="505" alt="image" src="https://github.com/user-attachments/assets/a7a39a98-2ad1-4ffd-8c4d-d1b2700e1710" />

© 2025 – Tim Priority Hub.
