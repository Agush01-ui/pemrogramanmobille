import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/weather_provider.dart';
import 'ui/screens/splash_screen.dart';

// Global Notifier for Theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, child) {
          return MaterialApp(
            title: 'Todo List Lokasi',
            debugShowCheckedModeBanner: false,

            // Light Theme
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF9F7AEA),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF7F2FF),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF3B417A), // bannerColor
                elevation: 4,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
                actionsIconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                toolbarTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF9F7AEA), // primaryColor
                foregroundColor: Colors.white,
              ),
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey.shade200,
                selectedColor: const Color(0xFF9F7AEA),
                labelStyle: const TextStyle(color: Colors.black87),
                secondaryLabelStyle: const TextStyle(color: Colors.white),
                brightness: Brightness.light,
              ),
            ),

            // Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF9F7AEA),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF3B417A), // bannerColor
                elevation: 4,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
                actionsIconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                toolbarTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF9F7AEA), // primaryColor
                foregroundColor: Colors.white,
              ),
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey.shade800,
                selectedColor: const Color(0xFF9F7AEA),
                labelStyle: const TextStyle(color: Colors.white),
                secondaryLabelStyle: const TextStyle(color: Colors.white),
                brightness: Brightness.dark,
              ),
            ),

            themeMode: currentMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
