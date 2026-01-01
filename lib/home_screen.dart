import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'todo_model.dart';
import 'login_screen.dart';
import 'counter_provider.dart';
import 'stream_service.dart';

// ================= CONSTANT COLOR =================
const Color primaryColor = Color(0xFF9F7AEA);
const Color accentColorOrange = Color(0xFFFF9800);
const Color accentColorPink = Color(0xFFF48FB1);

// ================= HOME SCREEN =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = 'Pengguna';
  List<Todo> todos = [];
  bool isLoading = false;
  DateTime? _lastRefreshTime;

  String selectedFilter = 'Semua';
  final List<String> categories = [
    'Pekerjaan',
    'Pribadi',
    'Belanja',
    'Olahraga',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // ================= INIT =================
  Future<void> _initData() async {
    await _loadUsername();
    await _refreshTodos();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('last_username') ?? 'Pengguna';
    });
  }

  // ================= AUTH =================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ================= DATA =================
  Future<void> _refreshTodos() async {
    setState(() => isLoading = true);

    final data = await DatabaseHelper.instance.readTodosByUser(_username);

    if (!mounted) return;

    setState(() {
      todos = data;
      isLoading = false;
      _lastRefreshTime = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data from Cache (Local DB)"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearCache() {
    setState(() {
      todos.clear();
      _lastRefreshTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cache Cleared")),
    );
  }

  // ================= TODO LOGIC =================
  Future<void> toggleTodoStatus(Todo todo) async {
    todo.isCompleted = !todo.isCompleted;
    await DatabaseHelper.instance.update(todo);

    if (todo.isCompleted) {
      context.read<CounterProvider>().increment();
    }

    _refreshTodos();
  }

  Future<void> deleteTodo(String id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshTodos();
  }

  List<Todo> get filteredTodos {
    final list = selectedFilter == 'Semua'
        ? todos
        : todos.where((t) => t.category == selectedFilter).toList();

    list.sort((a, b) {
      if (a.isUrgent != b.isUrgent) {
        return a.isUrgent ? -1 : 1;
      }
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }
      return 0;
    });

    return list;
  }

  // ================= ADD / EDIT =================
  Future<void> _showAddEditDialog([Todo? todo]) async {
    final isEditing = todo != null;
    String title = todo?.title ?? '';
    String category = todo?.category ?? categories.first;
    DateTime? deadline = todo?.deadline;
    bool isUrgent = todo?.isUrgent ?? false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Tugas' : 'Tambah Tugas'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: title,
                      decoration:
                          const InputDecoration(labelText: 'Nama Tugas'),
                      validator: (v) =>
                          v!.isEmpty ? 'Tidak boleh kosong' : null,
                      onChanged: (v) => title = v,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField(
                      value: category,
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setStateSB(() => category = v!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(deadline == null
                            ? 'Deadline: -'
                            : DateFormat('dd/MM').format(deadline!)),
                        TextButton(
                          child: const Text('Pilih'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateSB(() => deadline = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Urgent'),
                      value: isUrgent,
                      onChanged: (v) => setStateSB(() => isUrgent = v),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    if (isEditing) {
                      todo!
                        ..title = title
                        ..category = category
                        ..deadline = deadline
                        ..isUrgent = isUrgent;
                      await DatabaseHelper.instance.update(todo);
                    } else {
                      await DatabaseHelper.instance.create(
                        Todo(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          category: category,
                          deadline: deadline,
                          isUrgent: isUrgent,
                          isCompleted: false,
                          username: _username,
                        ),
                      );
                    }
                    _refreshTodos();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= UI =================
  Widget _buildTodoItem(Todo todo) {
    return Card(
      child: ListTile(
        leading: Icon(
          todo.isUrgent ? Icons.local_fire_department : Icons.task,
          color: primaryColor,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(todo.deadline == null
            ? todo.category
            : '${todo.category} | ${DateFormat('dd MMM').format(todo.deadline!)}'),
        trailing: IconButton(
          icon: Icon(
            todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: primaryColor,
          ),
          onPressed: () => toggleTodoStatus(todo),
        ),
        onTap: () => _showAddEditDialog(todo),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $_username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _clearCache,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _lastRefreshTime == null
                  ? 'Belum ada data'
                  : 'Terakhir refresh: ${DateFormat('HH:mm:ss').format(_lastRefreshTime!)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          StreamBuilder<int>(
            stream: SessionTimerService().timerStream,
            initialData: 0,
            builder: (_, snap) => Text(
              'Sesi: ${snap.data}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTodos.isEmpty
                    ? const Center(child: Text('Tidak ada tugas'))
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: filteredTodos.map(_buildTodoItem).toList(),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
