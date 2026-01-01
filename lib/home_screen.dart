import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'todo_model.dart';
import 'database_helper.dart';
import 'login_screen.dart';
import 'main.dart';

const Color primaryColor = Color(0xFF9F7AEA);
const Color accentColorOrange = Color(0xFFFF9800);
const Color accentColorPink = Color(0xFFF48FB1);
const Color bannerColor = Color(0xFF3B417A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _animatedColor = accentColorOrange;
  double _animatedSize = 50.0;
  Timer? _animTimer;

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

    _animTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _animatedColor = _animatedColor == accentColorOrange
              ? accentColorPink
              : accentColorOrange;
          _animatedSize = _animatedSize == 50.0 ? 60.0 : 50.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  // --- LOGIKA DATA & DB ---

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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _refreshTodos() async {
    setState(() => isLoading = true);

    final data = await DatabaseHelper.instance.readTodosByUser(_username);
    if (mounted) {
      setState(() {
        todos = data;
        isLoading = false;
        _lastRefreshTime = DateTime.now();
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data from Cache (Local DB)"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearCache() {
    setState(() {
      todos.clear();
      _lastRefreshTime = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Cache Cleared!")));
  }

  Future<void> toggleTodoStatus(
      String id, bool currentStatus, Todo todo) async {
    todo.isCompleted = !currentStatus;
    await DatabaseHelper.instance.update(todo);
    // Contoh penggunaan Provider: Increment counter setiap kali tugas selesai
    if (todo.isCompleted) {
      context.read<CounterProvider>().increment();
    }
    _refreshTodos();
  }

  Future<void> deleteTodo(String id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshTodos();
  }

  void _showCompletionAppreciation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '🎉 SELAMAT! Semua Tugas Selesai! 🎉',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: accentColorPink,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Todo> get filteredTodos {
    List<Todo> listToFilter = selectedFilter == 'Semua'
        ? todos
        : todos.where((todo) => todo.category == selectedFilter).toList();

    return List.from(listToFilter)
      ..sort((a, b) {
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        if (a.isCompleted && !b.isCompleted) return 1;
        if (a.deadline != null && b.deadline != null) {
          return a.deadline!.compareTo(b.deadline!);
        }
        return 0;
      });
  }

  Future<void> _showAddEditDialog([Todo? todo]) async {
    final isEditing = todo != null;
    String title = todo?.title ?? '';
    String category = todo?.category ?? categories.first;
    DateTime? deadline = todo?.deadline;
    bool isUrgent = todo?.isUrgent ?? false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        initialValue: title,
                        decoration:
                            const InputDecoration(labelText: 'Nama Tugas'),
                        onChanged: (value) => title = value,
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration:
                            const InputDecoration(labelText: 'Kategori'),
                        items: categories
                            .map((v) =>
                                DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) => setStateSB(() => category = v!),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(deadline == null
                              ? 'Deadline: -'
                              : DateFormat('dd/MM').format(deadline!)),
                          TextButton(
                            child: const Text('Pilih Tanggal'),
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
                        title: const Text('Urgent?'),
                        value: isUrgent,
                        activeThumbColor: primaryColor,
                        onChanged: (v) => setStateSB(() => isUrgent = v),
                      )
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Batal'),
                    onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        if (isEditing) {
                          todo!.title = title;
                          todo.category = category;
                          todo.deadline = deadline;
                          todo.isUrgent = isUrgent;
                          // Username tidak diubah saat edit
                          await DatabaseHelper.instance.update(todo);
                        } else {
                          final newTodo = Todo(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: title,
                            category: category,
                            deadline: deadline,
                            isUrgent: isUrgent,
                            isCompleted: false,
                            username: _username, // WAJIB DIISI
                          );
                          await DatabaseHelper.instance.create(newTodo);
                        }
                        await _refreshTodos();
                        if (mounted) Navigator.of(context).pop();
                      } catch (e) {
                        print("Error saving: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal menyimpan: $e")),
                        );
                      }
                      _refreshTodos();
                      if (mounted) Navigator.pop(context);
                    }
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

  // WIDGET HELPERS
  Widget _buildCategoryChip(String category) {
    final isSelected = selectedFilter == category;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(category,
            style:
                TextStyle(color: isSelected ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      child: ListTile(
        leading: Icon(
            todo.isUrgent ? Icons.local_fire_department : Icons.bookmark,
            color: primaryColor),
        title: Text(todo.title,
            style: TextStyle(
                decoration:
                    todo.isCompleted ? TextDecoration.lineThrough : null)),
        subtitle: Text(todo.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteTodo(todo.id)),
            IconButton(
              icon: Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: primaryColor),
              onPressed: () =>
                  toggleTodoStatus(todo.id, todo.isCompleted, todo),
            ),
          ],
        ),
        onTap: () => _showAddEditDialog(todo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Membaca state counter tanpa rebuild seluruh halaman (hanya untuk log)
    // context.read<CounterProvider>().count;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(''),
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            actions: [
              Tooltip(
                  message: "Clear Cache",
                  child: IconButton(
                      icon: const Icon(Icons.cleaning_services,
                          color: Colors.orange),
                      onPressed: _clearCache)),
              // FITUR 3: Navigasi ke Halaman Profil
              IconButton(
                icon: const Icon(Icons.person, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()));
                },
              ),
              IconButton(
                icon: Icon(themeNotifier.value == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  themeNotifier.value = themeNotifier.value == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  await prefs.setBool(
                      'is_dark_mode', themeNotifier.value == ThemeMode.dark);
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // BANNER
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                height: 150,
                decoration: BoxDecoration(
                    color: bannerColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PRIORITY HUB',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: accentColorOrange)),
                            Text('Atur tugas Anda.',
                                style: TextStyle(color: Colors.white)),
                          ]),
                    ),
                    // FITUR 4: Broadcast Stream Listener (Listener ke-1)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sesi:",
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                        StreamBuilder<int>(
                          stream: SessionTimerService().timerStream,
                          initialData: 0,
                          builder: (context, snapshot) {
                            return Text(
                              "${snapshot.data}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Halo, $_username!',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _refreshTodos)
                      ],
                    ),
                    Text(
                        _lastRefreshTime == null
                            ? 'Belum ada data'
                            : 'Refreshed: ${DateFormat('HH:mm:ss').format(_lastRefreshTime!)}',
                        style: const TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic)),

                    // Menampilkan Counter di Home (Optional, sebagai bukti reactive)
                    Consumer<CounterProvider>(
                      builder: (context, counter, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text("Total Aktivitas User: ${counter.count}",
                              style: const TextStyle(color: Colors.grey)),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          _buildCategoryChip('Semua'),
                          ...categories.map((c) => _buildCategoryChip(c))
                        ])),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : todos.isEmpty
                        ? const Center(child: Text("Tidak ada tugas."))
                        : Column(
                            children: filteredTodos
                                .map((t) => _buildTodoItem(t))
                                .toList()),
              ),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Todo> get filteredTodos {
    List<Todo> list = selectedFilter == 'Semua'
        ? todos
        : todos.where((t) => t.category == selectedFilter).toList();
    return list; // Sorting logic disederhanakan
  }
}
