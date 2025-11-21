// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'database_helper.dart';
import 'user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    // Tidak memuat username terakhir secara otomatis untuk keamanan yang lebih baik
  }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi username dan password!')),
      );
      return;
    }

    // 1. Cek apakah user sudah terdaftar
    User? user = await DatabaseHelper.instance.getUserByUsername(username);

    if (user == null) {
      // 2. Jika user belum ada (Registrasi otomatis)
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        password: password,
      );
      await DatabaseHelper.instance.createUser(newUser);
      user = newUser;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Akun baru berhasil didaftarkan dan Anda masuk!')),
      );
    } else {
      // 3. Jika user ada, verifikasi password
      if (user.password != password) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password salah!')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang kembali, ${user.username}!')),
      );
    }

    // 4. Simpan status login, ID user aktif, dan username terakhir
    final prefs = await SharedPreferences.getInstance();
    
    // Blok try-catch untuk menyimpan preferensi
    try {
        await prefs.setBool('is_logged_in', true);
        // Menggunakan user.id tanpa ! karena kita yakin user sudah non-null 
        // pada titik ini (baik dari DB atau new User)
        await prefs.setString('current_userId', user.id); 
        await prefs.setString('last_username', user.username);
        
        print('DEBUG: Data login disimpan: ${user.username} | ${user.id}');
    } catch (e) {
        print('ERROR SIMPAN PREFS: $e');
        ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Gagal menyimpan data login: $e')),
        );
        return; // Hentikan fungsi jika penyimpanan preferensi gagal
    }
    
    // 5. LOGIKA NAVIGASI YANG HILANG (KINI DIKEMBALIKAN)
    if (mounted) {
      print('DEBUG: Navigasi ke HomeScreen...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.task_alt, size: 80, color: Color(0xFF9F7AEA)),
              const SizedBox(height: 20),
              const Text(
                'PRIORITY HUB',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B417A)),
              ),
              const SizedBox(height: 40),
              // TEXTFIELD USERNAME
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // TEXTFIELD PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: true, // Sembunyikan input
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F7AEA),
                  ),
                  child: const Text('MASUK / DAFTAR',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}