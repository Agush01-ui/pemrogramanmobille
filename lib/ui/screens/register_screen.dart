import 'package:flutter/material.dart';
import '../../database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  // Variabel warna konsisten dengan LoginScreen
  final Color primaryPurple = const Color(0xFF9F7AEA);
  final Color deepPurple = const Color(0xFF3B417A);

  void _register() async {
    String user = _usernameController.text.trim();
    String pass = _passwordController.text.trim();

    // Regex: Minimal 6 karakter, 1 Huruf Kapital, 1 Angka
    RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');

    if (user.isNotEmpty && pass.isNotEmpty) {
      // Validasi Keamanan Password
      if (!passwordRegExp.hasMatch(pass)) {
        _showSnackBar(
          'Password wajib isi dengan benar: Minimal 6 karakter, ada huruf kapital, dan angka!',
          Colors.red,
        );
        return;
      }

      // Simpan ke database
      int result = await DatabaseHelper.instance.registerUser(user, pass);

      if (result != -1) {
        _showSnackBar('Registrasi Berhasil! Silakan Login.', Colors.green);

        // KODE YANG ANDA TANYAKAN diletakkan di sini:
        if (mounted) {
          // Memberikan delay sedikit agar user bisa melihat SnackBar sukses
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context); // Kembali ke halaman login
          });
        }
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
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryPurple.withOpacity(0.8),
              const Color(0xFFE9E4FF),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.person_add_alt_1_rounded,
                      size: 60, color: primaryPurple),
                ),
                const SizedBox(height: 30),
                Text(
                  'DAFTAR AKUN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan lakukan registrasi di sini',
                  style: TextStyle(
                    fontSize: 14,
                    color: deepPurple.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                  controller: _usernameController,
                  label: 'Username Baru',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Password Baru',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),

                // Hint UI
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: deepPurple.withOpacity(0.6)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Hint: Minimal 6 karakter, gunakan huruf kapital dan angka.',
                            style: TextStyle(
                              fontSize: 11,
                              color: deepPurple.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                GestureDetector(
                  onTap: _register,
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryPurple, const Color(0xFF667EEA)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'DAFTAR SEKARANG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: "Sudah punya akun? ",
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: "Login di sini",
                          style: TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryPurple),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}
