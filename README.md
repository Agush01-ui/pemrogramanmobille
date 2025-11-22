# 🧠 Priority Hub

**Tema Aplikasi:** To-Do List  
**Nama Aplikasi:** Priority Hub  

---

👥 Anggota Tim
| Nama Lengkap | NIM | Tugas |
|---------------|-----|--------|
| Agus | 2310120018 | Ketua Tim - Logika aplikasi & manajemen data To-Do & Perancangan Project |
| Rifo | 2310120025 | Desain UI dan implementasi Login SCr |
| Byan | 2310120024 | Intergrasi CRUD dengan SQLite dan SharedPreferences |

---

📱 Deskripsi Aplikasi
**Priority Hub** adalah aplikasi *to-do list* yang dirancang untuk membantu pengguna mengatur aktivitas harian berdasarkan tingkat prioritas.  
Aplikasi ini memiliki antarmuka sederhana namun fungsional untuk meningkatkan produktivitas pengguna.

---

## 🌟 Fitur Utama
✏️ **Menambahkan To-Do List**  
  Pengguna dapat menambah daftar tugas dengan mudah.  
🗂️ **Kategorisasi Aktivitas**  
  Setiap tugas dapat dikelompokkan berdasarkan kategori (misalnya: olahraga, pribadi, pekerjaan, lainnya).  
📅 **Pemilihan Tanggal**  
  Pengguna bisa menetapkan tanggal pelaksanaan untuk setiap tugas.  
🚨 **Tombol Prioritas**  
  Aktifkan toggle khusus jika tugas tersebut bersifat penting atau mendesak.  
✅ **Apresiasi Penyelesaian**  
  Saat semua tugas berhasil diselesaikan, aplikasi menampilkan pesan apresiasi untuk pengguna.  
🗑️ **Pilih & Hapus To-Do List**  
  Pengguna dapat memilih dan menghapus tugas yang sudah tidak diperlukan.

---
Fitur Tambahan
### 1. Login 🔐
Priority Hub menerapkan **Authentication System** untuk fitur **Masuk** dan **Daftar**, sehingga pengguna dapat:

- Membuat akun baru dengan aman  
- Masuk ke akun mereka secara terproteksi  
- Menyimpan data tugas secara terpersonal menggunakan **penyimpanan lokal / database**  

Fitur ini memastikan setiap data tugas terkait langsung dengan akun pengguna, menjaga keamanan dan privasi.

---

### 2. Light/Dark Mode 🌞🌙
Pengguna dapat **beralih antara Light dan Dark Mode**, memberikan fleksibilitas visual sesuai preferensi dan kondisi cahaya:

- **Light Mode**: Cocok untuk penggunaan di lingkungan terang  
- **Dark Mode**: Nyaman untuk kondisi gelap atau malam hari  

Fitur ini meningkatkan pengalaman visual dan menambahkan personalisasi aplikasi.

---

### 3. Penyimpanan Data Lokal (SQLite & SharedPreferences) 💾
Priority Hub menggunakan kombinasi **SQLite** dan **SharedPreferences** untuk manajemen data:

- **SQLite**  
  Digunakan untuk menyimpan daftar tugas secara terstruktur, memungkinkan:  
  - CRUD (Create, Read, Update, Delete) data tugas  
  - Data tersimpan permanen meski aplikasi ditutup  

- **SharedPreferences**  
  Digunakan untuk menyimpan **pengaturan pengguna** seperti:  
  - Mode tampilan (Light/Dark)  
  - Data terakhir yang digunakan atau preferensi sederhana lainnya  


💡 Tujuan
Meningkatkan efektivitas pengelolaan waktu dan membantu pengguna agar lebih konsisten menyelesaikan kegiatan berdasarkan prioritasnya.

---

🛠️ Teknologi yang Digunakan
- Flutter (Dart)
- Visual Studio Code
- Git & GitHub

---

📸 Cuplikan Tampilan 
Berikut beberapa tampilan dari aplikasi **Priority Hub** 👇  

### 1. Tampilan Awal Halaman Login 🔑
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/main/TampilanLogin.png?raw=true)

Menunjukkan tampilan awal untuk masuk ke aplikasi, dengan kolom kosong untuk **Username** dan **Password**, serta tombol **MASUK** dan **DAFTAR AKUN BARU**. Pengguna dapat langsung mendaftar atau masuk sesuai akun yang dimiliki.


---

### 2. Halaman Login Setelah Registrasi Berhasil ✅
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/main/HalamanLogin.png?raw=true)

Menampilkan halaman login setelah pengguna berhasil mendaftar. Terdapat notifikasi hijau di bawah yang menandakan registrasi berhasil, dan kolom **Username** serta **Password** sudah terisi secara otomatis, memudahkan pengguna untuk langsung masuk.

---

### 3. Halaman Login dengan Pesan Kesalahan ❌
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/main/pesanusernamesalahh.png?raw=true)

Menunjukkan halaman login ketika pengguna memasukkan **Username** atau **Password** yang salah. Terdapat notifikasi merah di bawah kolom login yang memberi tahu bahwa kredensial yang dimasukkan tidak valid.

---

### 4. Halaman HomePage ❌
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/main/HomePage.png?raw=true)

Menunjukkan halaman utama dari tampilan aplikasi PriorityHub

---

### 5. Tampilan Utama Mode Terang (Light)☀️
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/main/TampilanLight.png?raw=true)

Menampilkan **homepage** aplikasi **Priority Hub** dalam **Light Mode**. Pada tampilan ini, terdapat informasi **0/0 Tugas Selesai** dan daftar tugas masih kosong, sehingga pengguna dapat langsung menambahkan tugas baru.

---

###  6. Tampilan Utama Mode Gelap (Dark)🌙 
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/main/DarkMode.png?raw=true)

Menampilkan **homepage** aplikasi dalam **Dark Mode**. Sama seperti Light Mode, ditampilkan **0/0 Tugas Selesai** dan tidak ada tugas yang tercatat, namun dengan tampilan gelap yang nyaman untuk kondisi cahaya rendah.

---

###  7. Penambahan Item/Task To Do ➕
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/main/Task.png?raw=true)

Menunjukkan proses penambahan tugas baru di aplikasi **Priority Hub**. Pengguna dapat mengisi **nama tugas**, menentukan **tanggal jatuh tempo**, serta menandai **tingkat prioritas**. Setelah disimpan, tugas baru langsung muncul di daftar tugas utama, siap untuk dikelola dan diselesaikan.
---

###  8. Tampilan Utama Setelah Semua Tugas Selesai 🎉
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/3e900afde52368c71a7d78e6231d620d7778658e/ff87cd43015b4e4bbaa3caeeb65c7454.jpg)

Menampilkan halaman utama setelah semua tugas selesai dicentang. Tampilan menunjukkan **2/2 Tugas Selesai** dan muncul pesan ucapan selamat berwarna merah muda, memberikan pengalaman positif kepada pengguna ketika berhasil menyelesaikan semua tugas.

---
## Penyimpanan Data 💾

Priority Hub menyimpan data pengguna melalui dua mekanisme utama:

### 1. SQLite
- Menyimpan daftar tugas secara **terstruktur** di database lokal.  
- Mendukung operasi **CRUD**:  
  - **Create**: Tambah tugas baru  
  - **Read**: Tampilkan daftar tugas  
  - **Update**: Ubah tugas (status, prioritas, tanggal)  
  - **Delete**: Hapus tugas  
- Data tersimpan **permanen di perangkat**, tetap ada meski aplikasi ditutup.

### 2. SharedPreferences
- Menyimpan **pengaturan pengguna** seperti mode Light/Dark atau data terakhir yang digunakan.  
- Data disimpan dalam bentuk **key-value**, mudah diakses saat aplikasi dibuka kembali.  
- Memastikan aplikasi selalu menampilkan preferensi pengguna secara otomatis.

**Alur singkat:**  
1. Tambah/ubah tugas → disimpan di **SQLite**  
2. Ubah pengaturan → disimpan di **SharedPreferences**  
3. Buka aplikasi → SQLite + SharedPreferences → data & pengaturan siap digunakan

© 2025 – Tim Priority Hub.
