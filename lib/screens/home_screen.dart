import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../widgets/todo_dialog.dart';

const Color primaryColor = Color(0xFF9F7AEA);
const Color accentOrange = Color(0xFFFF9800);
const Color accentPink = Color(0xFFF48FB1);
const Color bannerColor = Color(0xFF3B417A);
const Color bgColor = Color(0xFFF7F2FF);

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
    'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();

    final username = auth.username ?? 'Pengguna';

    final todos = selectedCategory == 'Semua'
        ? todoProvider.todos
        : todoProvider.todos
            .where((t) => t.category == selectedCategory)
            .toList();

    final total = todoProvider.todos.length;
    final done = todoProvider.todos.where((t) => t.completed).length;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            actions: [
              IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () => auth.logout()),
            ],
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            _buildBanner(username),
            _buildHeader(username),
            _buildProgress(done, total, progress),
            _buildCategory(),
            _buildTodoList(todos),
            const SizedBox(height: 100),
          ])),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => showTodoDialog(context, username: username),
      ),
    );
  }

  Widget _buildBanner(String username) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $username 👋',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 6),
                const Text(
                  'Siap menghadapi hari ini?',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: accentPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Daftar Tugas Kamu',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgress(int done, int total, double progress) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$done / $total Tugas Selesai',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, color: primaryColor),
        ],
      ),
    );
  }

  Widget _buildCategory() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.map((cat) {
          final active = selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cat,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Tidak ada tugas')),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: todos.map((todo) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () =>
                  showTodoDialog(context, todo: todo, username: todo.username),
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: todo.isUrgent ? accentPink : accentOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.bookmark, color: Colors.white),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                  '${todo.category} | ${DateFormat('dd MMM').format(todo.deadline)}'),
              trailing: IconButton(
                icon: Icon(
                    todo.completed ? Icons.check_circle : Icons.circle_outlined,
                    color: primaryColor),
                onPressed: () =>
                    context.read<TodoProvider>().toggleStatus(todo),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
