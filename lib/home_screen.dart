// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_model.dart';
import 'database_helper.dart';
import 'login_screen.dart';
import 'main.dart';

const Color primaryColor = Color(0xFF9F7AEA);
const Color accentColorOrange = Color(0xFFFF9800);
const Color accentColorPink = Color(0xFFF48FB1);
const Color backgroundColor = Color(0xFFF7F2FF);
const Color bannerColor = Color(0xFF3B417A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _animatedColor = accentColorOrange;
  double _animatedSize = 50.0;
  Timer? _timer;

  String _username = 'Pengguna';
  String _currentUserId = ''; // BARU: Simpan ID user aktif
  List<Todo> todos = [];
  bool isLoading = false;

  String selectedFilter = 'Semua';
  final List<String> categories = [
    'Pekerjaan',
    'Pribadi',
    'Belanja',
    'Olahraga',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Ganti _loadUsername
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIKA DATA & DB ---

  // BARU: Memuat ID User dan Username
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_userId');

    if (userId == null || userId.isEmpty) {
      await _logout(); // Paksa logout jika tidak ada ID user
      return;
    }

    setState(() {
      _currentUserId = userId;
      _username = prefs.getString('last_username') ?? 'Pengguna';
    });

    _refreshTodos();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('current_userId'); // Hapus ID user aktif
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _refreshTodos() async {
    if (_currentUserId.isEmpty) return; // Guard

    setState(() => isLoading = true);
    // MEMBACA TODO HANYA UNTUK USER YANG AKTIF
    final data = await DatabaseHelper.instance.readAllTodos(_currentUserId); 
    if (mounted) {
      setState(() {
        todos = data;
        isLoading = false;
      });
    }
  }

  Future<void> toggleTodoStatus(
      String id, bool currentStatus, Todo todo) async {
    todo.isCompleted = !currentStatus;
    await DatabaseHelper.instance.update(todo);
    _refreshTodos();

    await Future.delayed(Duration.zero);
    int totalTodos = todos.length;
    int completedTodos = todos.where((t) => t.isCompleted).length;

    if (totalTodos > 0 && completedTodos == totalTodos) {
      _showCompletionAppreciation();
    }
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

  // --- DIALOG TAMBAH/EDIT ---

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        initialValue: title,
                        decoration:
                            const InputDecoration(labelText: 'Nama Tugas'),
                        onChanged: (value) => title = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration:
                            const InputDecoration(labelText: 'Kategori'),
                        items: categories.map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null)
                            setStateSB(() => category = newValue);
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deadline: ${deadline == null ? 'Tidak Ada' : DateFormat('dd/MM/yyyy').format(deadline!)}',
                          ),
                          TextButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: deadline ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null)
                                setStateSB(() => deadline = pickedDate);
                            },
                            child: const Text('Pilih Tanggal'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Prioritas Mendesak (Urgent)'),
                          Switch(
                            value: isUrgent,
                            onChanged: (bool value) =>
                                setStateSB(() => isUrgent = value),
                            activeColor: primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        if (_currentUserId.isEmpty) return; // Guard

                        if (isEditing) {
                          todo.title = title;
                          todo.category = category;
                          todo.deadline = deadline;
                          todo.isUrgent = isUrgent;
                          // todo.userId tidak perlu diubah saat update
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
                            userId: _currentUserId, // Kunci: Tambahkan ID user
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
                    }
                  },
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Tugas'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- WIDGETS UI --- (Tetap sama)

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedFilter == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    Color categoryColor;
    switch (todo.category) {
      case 'Pekerjaan':
        categoryColor = accentColorPink;
        break;
      case 'Pribadi':
        categoryColor = primaryColor.withOpacity(0.8);
        break;
      case 'Belanja':
        categoryColor = accentColorOrange;
        break;
      default:
        categoryColor = Colors.green.shade400;
    }

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Konfirmasi Hapus"),
              content:
                  const Text("Apakah Anda yakin ingin menghapus tugas ini?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Hapus"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${todo.title} dihapus")),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 1,
        child: ListTile(
          onTap: () => _showAddEditDialog(todo),
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              todo.isUrgent ? Icons.local_fire_department : Icons.bookmark,
              color: Colors.white,
              size: 18,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: todo.isCompleted ? Colors.grey : null,
              // 'null' agar mengikuti tema dark/light mode
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                '${todo.category} ${todo.deadline != null ? ' | ${DateFormat('dd MMM').format(todo.deadline!)}' : ''}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: todo.isCompleted ? primaryColor : Colors.grey,
                ),
                onPressed: () =>
                    toggleTodoStatus(todo.id, todo.isCompleted, todo),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PRIORITY HUB',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: accentColorOrange,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Atur tugas Anda, raih produktivitas tertinggi.',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            width: _animatedSize,
            height: _animatedSize,
            decoration: BoxDecoration(
              color: _animatedColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: _animatedSize * 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MAIN UI BUILD --- (Tetap sama)

  @override
  Widget build(BuildContext context) {
    int totalTodos = todos.length;
    int completedTodos = todos.where((t) => t.isCompleted).length;
    double progress = totalTodos == 0 ? 0 : completedTodos / totalTodos;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text(''),
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              actions: [
                // TEMA TOGGLE
                IconButton(
                  icon: Icon(
                    themeNotifier.value == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.yellow
                        : Colors.deepPurple,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final isCurrentlyDark =
                        themeNotifier.value == ThemeMode.dark;
                    final newMode =
                        isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;

                    themeNotifier.value = newMode;
                    await prefs.setBool('is_dark_mode', !isCurrentlyDark);
                  },
                ),
                // LOGOUT
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: _logout,
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildBanner(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Halo, $_username!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Siap menghadapi hari ini?',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).cardColor, // Support Dark Mode
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$completedTodos/$totalTodos Tugas Selesai',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade300,
                              color: primaryColor,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip('Semua'),
                            ...categories
                                .map((cat) => _buildCategoryChip(cat))
                                .toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Daftar Tugas ($selectedFilter)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // Warna text menyesuaikan tema
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredTodos.isEmpty
                          ? const Center(
                              child: Text("Tidak ada tugas di kategori ini."),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: filteredTodos.map((todo) {
                                return _buildTodoItem(todo);
                              }).toList(),
                            ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}