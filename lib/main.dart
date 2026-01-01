import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load last login status
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final lastUsername = prefs.getString('last_username') ?? '';

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    lastUsername: lastUsername,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String lastUsername;

  const MyApp({super.key, required this.isLoggedIn, required this.lastUsername});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: isLoggedIn
            ? HomeScreen(username: lastUsername)
            : const LoginScreen(),
      ),
    );
  }
}
