import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  Future<void> _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi')),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success;
    if (isLogin) {
      success =
          await DatabaseHelper.instance.loginUser(username, password);
    } else {
      final result =
          await DatabaseHelper.instance.registerUser(username, password);
      success = result != -1;
    }

    setState(() => isLoading = false);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('last_username', username);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: username, // ✅ WAJIB DIKIRIM
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLogin
              ? 'Login gagal'
              : 'Registrasi gagal, username sudah ada'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLogin ? 'Login' : 'Register',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: size.width,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleAuth,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isLogin ? 'Login' : 'Register'),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() => isLogin = !isLogin);
                },
                child: Text(isLogin
                    ? 'Belum punya akun? Register'
                    : 'Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
