import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool isLogin = true;
  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80),
            const SizedBox(height: 16),
            Text(
              isLogin ? 'Login' : 'Register',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                setState(() => error = null);

                final user = _userCtrl.text.trim();
                final pass = _passCtrl.text.trim();

                if (user.isEmpty || pass.isEmpty) {
                  setState(() => error = 'Field tidak boleh kosong');
                  return;
                }

                String? result;
                if (isLogin) {
                  result = await auth.login(user, pass);
                } else {
                  result = await auth.register(user, pass);
                  if (result == null) {
                    result = await auth.login(user, pass);
                  }
                }

                if (result != null) {
                  setState(() => error = result);
                }
              },
              child: Text(isLogin ? 'LOGIN' : 'REGISTER'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                  error = null;
                });
              },
              child: Text(
                isLogin
                    ? 'Belum punya akun? Register'
                    : 'Sudah punya akun? Login',
              ),
            )
          ],
        ),
      ),
    );
  }
}
