import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'Semua';

  final categories = [
    'Semua',
    'Pekerjaan',
    'Pribadi',
    'Belanja',
    'Olahraga',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos(widget.username);
    });
  }

  void _showAddTodoDialog() {
    String title = '';
    String category = 'Pekerjaan';
    DateTime? deadline;
    bool isUrgent = false;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                onChanged: (v) => title = v,
              ),
              DropdownButtonFormField(
                value: category,
                items: categories
                    .where((c) => c != 'Semua')
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => category = v!,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              SwitchListTile(
                title: const Text('Urgent'),
                value: isUrgent,
                onChanged: (v) => isUrgent = v,
              ),
              TextButton(
                child: Text(
                  deadline == null
                      ? 'Pilih Deadline'
                      : DateFormat('dd/MM/yyyy').format(deadline!),
                ),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (d != null) {
                    setState(() => deadline = d);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final todo = Todo(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  category: category,
                  deadline: deadline,
                  isUrgent: isUrgent,
                  isCompleted: false,
                  username: widget.username,
                );

                await context.read<TodoProvider>().addTodo(todo);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final todos = provider.filteredTodos(selectedFilter);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (_, i) {
                final t = todos[i];
                return ListTile(
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: t.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    t.deadline != null
                        ? DateFormat('dd MMM').format(t.deadline!)
                        : 'Tanpa deadline',
                  ),
                  trailing: Checkbox(
                    value: t.isCompleted,
                    onChanged: (_) =>
                        context.read<TodoProvider>().updateTodo(
                              t..isCompleted = !t.isCompleted,
                            ),
                  ),
                );
              },
            ),
    );
  }
}
