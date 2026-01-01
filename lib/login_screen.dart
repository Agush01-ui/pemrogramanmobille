import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'database_helper.dart'; // Import DB Helper

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true; // Untuk sembunyikan password

  // Fungsi Login
  void _login() async {
    String user = _usernameController.text.trim();
    String pass = _passwordController.text.trim();

    if (user.isNotEmpty && pass.isNotEmpty) {
      // Cek ke Database SQLite
      bool isValid = await DatabaseHelper.instance.loginUser(user, pass);

      if (isValid) {
        // Jika Akun Valid, Simpan Sesi di SharedPrefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('last_username', user);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Jika Salah
        _showSnackBar('Username atau Password salah!', Colors.red);
      }
    } else {
      _showSnackBar('Harap isi Username dan Password', Colors.orange);
    }
  }

  // Fungsi Registrasi (Daftar Akun)
  void _register() async {
    String user = _usernameController.text.trim();
    String pass = _passwordController.text.trim();

    if (user.isNotEmpty && pass.isNotEmpty) {
      // Simpan ke Database SQLite
      int result = await DatabaseHelper.instance.registerUser(user, pass);

      if (result != -1) {
        _showSnackBar('Registrasi Berhasil! Silakan Login.', Colors.green);
      } else {
        _showSnackBar('Username sudah digunakan!', Colors.red);
      }
    } else {
      _showSnackBar(
          'Harap isi Username dan Password untuk daftar', Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan MediaQuery untuk desain responsif
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person, size: 80, color: Color(0xFF9F7AEA)),
              const SizedBox(height: 20),
              const Text(
                'SELAMAT DATANG',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B417A)),
              ),
              const Text(
                'Silakan Masuk atau Daftar',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // INPUT USERNAME
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // INPUT PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              // TOMBOL LOGIN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F7AEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'MASUK',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // TOMBOL DAFTAR (Outlined)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _register,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF9F7AEA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'DAFTAR AKUN BARU',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9F7AEA)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}