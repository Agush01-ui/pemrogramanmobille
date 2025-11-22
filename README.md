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

Dependencies yang digunakan di Flutter:

```yaml
dependencies:
  intl: ^0.18.0
  sqflite: ^2.3.0
  path: ^1.8.3
  shared_preferences: ^2.2.0
---

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

### 🏠 Tampilan Utama
Menampilkan daftar seluruh *to-do list* beserta status dan kategori kegiatan.
![image alt]()


---

### ➕ Menambahkan To-Do Baru
Pengguna dapat menambah tugas baru, menentukan kategori, serta menandai sebagai prioritas dengan ikon khusus.
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/0a37c43ea10d690dafdb48a0d2a3fbf773b4e65b/20f4dd5ae8a54059bf1f5a1ff416f8d1.jpg)

---

### 📅 Menentukan Tanggal
Setiap tugas dapat dijadwalkan sesuai tanggal pelaksanaan agar lebih teratur.
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/1f6fddef08a108e27642ef4e769d46298cb4d96a/fb4cd08728f743719b9e7796359f982a.jpg)

---

### 🎉 Pesan Apresiasi
Jika semua *to-do list* sudah selesai, aplikasi menampilkan pesan motivasi:  
**"Selamat! Semua tugas selesai! Anda hebat!"**
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/cfa8b36e498fd6b81a5279033ba835a28f3bcb2d/4a9da1e99b6f4cb5845a886817af8c76.jpg)


---

### 🗑️ Menghapus To-Do
Pengguna dapat menghapus tugas yang sudah tidak diperlukan dengan mudah.
![image alt](https://github.com/Agush01-ui/pemrogramanmobille/blob/3e900afde52368c71a7d78e6231d620d7778658e/ff87cd43015b4e4bbaa3caeeb65c7454.jpg)

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
