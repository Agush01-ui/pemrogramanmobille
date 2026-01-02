import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

/// =======================================================
/// ROOT SCREEN
/// - Auto redirect Login / Home
/// - Handle loading session (SharedPreferences)
/// =======================================================
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ⏳ Loading saat cek session
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ Sudah login → Home
    if (auth.isLoggedIn) {
      return const HomeScreen();
    }

    // 🔐 Belum login → Login
    return const LoginScreen();
  }
}
