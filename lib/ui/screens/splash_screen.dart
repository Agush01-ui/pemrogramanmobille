import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _textController;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();

    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);

    _textController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _textAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _logoController.forward();
    _textController.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF9F7AEA);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F2FF), Color(0xFFE6D9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoAnimation,
              child: const Icon(
                Icons.lock_person,
                size: 120,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            SlideTransition(
              position: _textAnimation,
              child: Column(
                children: const [
                  Text(
                    'PRIORITY HUB',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3B417A),
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Organize your life, achieve more.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
