import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/todo_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: ThemeData(
          primaryColor: const Color(0xFF9F7AEA),
          scaffoldBackgroundColor: const Color(0xFFF7F2FF),
        ),
        home: const RootScreen(),
      ),
    );
  }
}

/// RootScreen akan otomatis redirect ke Login atau Home sesuai status login
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Loading state saat cek session
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Jika sudah login -> HomeScreen
    if (auth.isLoggedIn) {
      return const HomeScreen();
    }

    // Jika belum login -> LoginScreen
    return const LoginScreen();
  }
}
