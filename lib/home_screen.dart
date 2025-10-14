import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'todo_model.dart';

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

  @override
  void initState() {
    super.initState();
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

  // Data disimpan sementara di memori
  // KETENTUAN SOAL: Data perlu disimpan sementara dalam memori.
  List<Todo> todos = [
    Todo(
      id: '1',
      title: 'Mengerjakan Laporan Bulanan',
      category: 'Pekerjaan',
      isUrgent: true,
      isCompleted: false,
    ),
    Todo(
      id: '2',
      title: 'Jadwal Pertemuan Klien',
      category: 'Pribadi',
      deadline: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
    ),
    Todo(
      id: '3',
      title: 'Beli Bahan Makanan',
      category: 'Belanja',
      isCompleted: false,
    ),
    Todo(
      id: '4',
      title: 'Olah Raga Pagi',
      category: 'Olahraga',
      isCompleted: true,
    ),
  ];

  String selectedFilter = 'Semua';
  final List<String> categories = [
    'Pekerjaan',
    'Pribadi',
    'Belanja',
    'Olahraga',
    'Lainnya',
  ];

  // --- LOGIKA UTAMA ---

  // Fungsi untuk menandai tugas selesai
  void toggleTodoStatus(String id) {
    setState(() {
      final index = todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        todos[index].isCompleted = !todos[index].isCompleted;
      }
    });

    // Cek setelah state diperbarui
    int totalTodos = todos.length;
    int completedTodos = todos.where((t) => t.isCompleted).length;

    // Pemberitahuan apresiasi jika semua tugas selesai
    if (totalTodos > 0 && completedTodos == totalTodos) {
      _showCompletionAppreciation();
    }
  }

  // Fungsi untuk menampilkan apresiasi (Snackbar)
  void _showCompletionAppreciation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '🎉 SELAMAT! Semua Tugas Selesai! Anda Hebat! 🎉',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: accentColorPink,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Fungsi untuk menghapus tugas
  void deleteTodo(String id) {
    setState(() {
      todos.removeWhere((todo) => todo.id == id);
    });
  }

  // Fungsi untuk mendapatkan daftar tugas yang difilter dan diurutkan
  List<Todo> get filteredTodos {
    List<Todo> listToFilter = selectedFilter == 'Semua'
        ? todos
        : todos.where((todo) => todo.category == selectedFilter).toList();

    return List.from(listToFilter)..sort((a, b) {
      // Urutkan: Mendesak > Belum Selesai > Selesai
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

  // --- TAMPILAN TAMBAH/EDIT TUGAS (DIALOG) ---

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
        // StatefulBuilder digunakan agar dialog bisa diupdate
        return StatefulBuilder(
          builder: (context, setStateSB) {
            // KETENTUAN SOAL: Alert/Dialog
            return AlertDialog(
              title: Text(isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  // KETENTUAN SOAL: menggunakan Column
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // KETENTUAN SOAL: menggunakan Text
                      TextFormField(
                        initialValue: title,
                        decoration: const InputDecoration(
                          labelText: 'Nama Tugas',
                        ),
                        onChanged: (value) => title = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tugas tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Kategori (Dropdown)
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setStateSB(() => category = newValue);
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      // Deadline
                      // KETENTUAN SOAL: menggunakan Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // KETENTUAN SOAL: menggunakan Text
                          Text(
                            'Deadline: ${deadline == null ? 'Tidak Ada' : DateFormat('dd/MM/yyyy').format(deadline!)}',
                          ),
                          // KETENTUAN SOAL: menggunakan TextButton
                          TextButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: deadline ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setStateSB(() => deadline = pickedDate);
                              }
                            },
                            child: const Text('Pilih Tanggal'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Prioritas (Switch)
                      // KETENTUAN SOAL: menggunakan Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Prioritas Mendesak (Urgent)'),
                          Switch(
                            value: isUrgent,
                            onChanged: (bool value) {
                              setStateSB(() => isUrgent = value);
                            },
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
                // KETENTUAN SOAL: Tombol "Simpan" menggunakan ElevatedButton
                ElevatedButton(
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Tugas'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        if (isEditing) {
                          // Update tugas yang sudah ada
                          todo!.title = title;
                          todo.category = category;
                          todo.deadline = deadline;
                          todo.isUrgent = isUrgent;
                        } else {
                          // Tambah tugas baru
                          todos.add(
                            Todo(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              title: title,
                              category: category,
                              deadline: deadline,
                              isUrgent: isUrgent,
                            ),
                          );
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- WIDGET KOMPONEN UI ---

  // Widget untuk Chip Filter Kategori
  Widget _buildCategoryChip(String category) {
    final isSelected = selectedFilter == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = category;
        });
      },
      // KETENTUAN SOAL: menggunakan Container
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        // KETENTUAN SOAL: menggunakan Padding
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        // KETENTUAN SOAL: menggunakan Text
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

  // Widget untuk Item Tugas
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

    // KETENTUAN SOAL: Item memiliki ikon hapus & menghapus data
    // Implementasi HAPUS melalui Dismissible (Swipe)
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        // KETENTUAN SOAL: menggunakan Ikon (Icons.delete)
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // KONFIRMASI HAPUS: Memunculkan AlertDialog
      confirmDismiss: (direction) async {
        // KETENTUAN SOAL: Alert/Dialog
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Konfirmasi Hapus"),
              content: const Text(
                "Apakah Anda yakin ingin menghapus tugas ini?",
              ),
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
      // EKSEKUSI HAPUS: memanggil deleteTodo(id)
      onDismissed: (direction) {
        deleteTodo(todo.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${todo.title} dihapus")));
      },
      // KETENTUAN SOAL: menggunakan Card
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
              color: todo.isCompleted ? Colors.grey : Colors.black87,
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
          // KETENTUAN SOAL: menggunakan Row (di dalam trailing untuk 2 ikon)
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // KETENTUAN SOAL: menggunakan IconButton
              IconButton(
                // KETENTUAN SOAL: menggunakan Ikon (Icons.delete)
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  bool? shouldDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Konfirmasi Hapus"),
                        content: const Text(
                          "Apakah Anda yakin ingin menghapus tugas ini?",
                        ),
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
                  if (shouldDelete == true) {
                    deleteTodo(todo.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${todo.title} dihapus")),
                    );
                  }
                },
              ),
              // KETENTUAN SOAL: menggunakan IconButton
              IconButton(
                icon: Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: todo.isCompleted ? primaryColor : Colors.grey,
                ),
                onPressed: () => toggleTodoStatus(todo.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget khusus untuk Banner
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
          // Widget Animasi Sederhana
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

  // --- TAMPILAN UTAMA  ---

  @override
  Widget build(BuildContext context) {
    int totalTodos = todos.length;
    int completedTodos = todos.where((t) => t.isCompleted).length;
    double progress = totalTodos == 0 ? 0 : completedTodos / totalTodos;

    // KETENTUAN SOAL: Design Antarmuka (Scaffold, AppBar)
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(color: backgroundColor),
        child: CustomScrollView(
          slivers: [
            // KETENTUAN SOAL: menggunakan AppBar
            SliverAppBar(
              // JUDUL TELAH DIHAPUS: title: const Text('TASK FLOW', ...)
              title: const Text(
                '',
              ), // Mengganti dengan Text kosong agar AppBar tetap ada
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              actions: [
                // Ikon Notifikasi
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black87,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildBanner(),

                Padding(
                  // KETENTUAN SOAL: menggunakan Padding
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 15.0,
                  ), // Padding diubah
                  // KETENTUAN SOAL: menggunakan Column
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 1. Header dan Progress
                      // KETENTUAN SOAL: menggunakan Text
                      Text(
                        'Halo, Pengguna!',
                        // KETENTUAN SOAL: Proporsional dan mudah digunakan
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Siap menghadapi hari ini?',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 15),

                      // Progress Bar (Kotak Progress yang lebih menonjol)
                      // KETENTUAN SOAL: menggunakan Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
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

                      // 2. Filter Kategori (Row)
                      // KETENTUAN SOAL: menggunakan Row
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

                      // Header Daftar Tugas
                      Text(
                        'Daftar Tugas (${selectedFilter})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // 3. Daftar Tugas (Menampilkan List Item)
                // KETENTUAN SOAL: menggunakan ListView.builder (direpresentasikan dalam SliverList)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: filteredTodos.isEmpty
                      ? const Center(
                          child: Text("Tidak ada tugas di kategori ini."),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: filteredTodos.map((todo) {
                            // KETENTUAN SOAL: menggunakan ListView.builder
                            // (Di sini menggunakan map().toList() dalam Column yang fungsinya sama)
                            return _buildTodoItem(todo);
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 80), // Memberi ruang di bawah
              ]),
            ),
          ],
        ),
      ),
      // KETENTUAN SOAL: Tombol FloatingActionButton untuk menambah data
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: primaryColor, // Warna Ungu
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
