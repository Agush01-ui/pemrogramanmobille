import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/map_provider.dart';
import 'providers/location_provider.dart';
import 'providers/weather_provider.dart';

import 'services/location_service.dart';

import 'screens/root_screen.dart';
import 'theme.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),

        /// 🌦️ WEATHER (LISTEN REALTIME LOCATION)
        ChangeNotifierProvider(
          create: (context) {
            final weather = WeatherProvider();
            final location = context.read<LocationProvider>();

            /// ⬅️ INI KUNCI UTAMA
            weather.listenLocation(location);

            return weather;
          },
        ),

        /// 🗺️ MAP
        ChangeNotifierProvider(
          create: (_) => MapProvider(
            locationService: LocationService(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Todo App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}
