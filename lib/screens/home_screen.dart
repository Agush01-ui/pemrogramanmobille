import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';

import '../models/todo_model.dart';
import '../widgets/weather_card.dart';
import '../screens/map_screen.dart';
import '../widgets/todo_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Semua';

  final List<String> categories = [
    'Semua',
    'Pekerjaan',
    'Pribadi',
    'Belanja',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    /// 🔥 INIT SEKALI SAAT SCREEN DIBUKA
    Future.microtask(() {
      final location = context.read<LocationProvider>();
      final weather = context.read<WeatherProvider>();

      location.startLocationStream();

      location.addListener(() {
        final pos = location.position;
        if (pos != null) {
          weather.fetchWeather(pos.latitude, pos.longitude);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final username = auth.username ?? 'Pengguna';

    final todos = selectedCategory == 'Semua'
        ? todoProvider.todos
        : todoProvider.todos
            .where((t) => t.category == selectedCategory)
            .toList();

    final total = todoProvider.todos.length;
    final done = todoProvider.todos.where((t) => t.completed).length;
    final progress = total == 0 ? 0.0 : done / total;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          /// 🗺️ MAP
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
          ),

          /// 🌗 THEME
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProvider.toggleTheme(!isDark),
          ),

          /// 🔐 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: auth.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTodoDialog(context, username: username),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          _buildBanner(username, colorScheme),

          /// 🌦️ WEATHER (REALTIME + CACHE + ANIMASI)
          const WeatherCard(),

          _buildProgressCard(done, total, progress),
          _buildCategoryChips(colorScheme),
          const SizedBox(height: 8),
          _buildTodoList(todos),
        ],
      ),
    );
  }

  // ================== WIDGET HELPERS ==================

  Widget _buildBanner(String username, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $username 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Siap menghadapi hari ini?',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 26,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.check, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildProgressCard(int done, int total, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$done / $total Tugas Selesai',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme colorScheme) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.map((cat) {
          final selected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: selected,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : colorScheme.onSurface,
              ),
              onSelected: (_) {
                setState(() => selectedCategory = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('Tidak ada tugas', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: todos.map(_buildTodoItem).toList(),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () =>
            showTodoDialog(context, todo: todo, username: todo.username),
        leading: CircleAvatar(
          backgroundColor:
              todo.isUrgent ? Colors.pinkAccent : Colors.orangeAccent,
          child: const Icon(Icons.bookmark, color: Colors.white, size: 18),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: todo.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${todo.category} • ${DateFormat('dd MMM').format(todo.deadline)}',
        ),
        trailing: IconButton(
          icon: Icon(
            todo.completed ? Icons.check_circle : Icons.radio_button_unchecked,
          ),
          onPressed: () => context.read<TodoProvider>().toggleStatus(todo),
        ),
      ),
    );
  }
}
