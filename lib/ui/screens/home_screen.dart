import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../todo_model.dart';
import '../../database_helper.dart';
import 'login_screen.dart';
import '../../main.dart';
import '../../providers/weather_provider.dart';
import 'map_screen.dart';

const Color primaryColor = Color(0xFF9F7AEA);
const Color accentColorOrange = Color(0xFFFF9800);
const Color accentColorPink = Color(0xFFF48FB1);
const Color backgroundColor = Color(0xFFF7F2FF);
const Color bannerColor = Color(0xFF3B417A);

// TAMBAHAN: Widget TimePicker dengan tampilan jam besar
class TimePickerWidget extends StatefulWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final bool isDarkMode;

  const TimePickerWidget({
    Key? key,
    this.initialTime,
    required this.onTimeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: widget.isDarkMode
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: primaryColor,
                    secondary: accentColorPink,
                  ),
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor: Colors.grey[900],
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: primaryColor,
                    secondary: accentColorPink,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      widget.onTimeChanged(_selectedTime);
    }
  }

  void _clearTime() {
    setState(() {
      _selectedTime = null;
    });
    widget.onTimeChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Waktu Task',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
        GestureDetector(
          onTap: _showTimePicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedTime != null)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedTime!.hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: accentColorPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedTime!.minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: accentColorPink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedTime!.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap untuk mengubah waktu',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 48,
                        color: widget.isDarkMode
                            ? Colors.grey[500]
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'TAP UNTUK SET WAKTU',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: widget.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Opsional',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (_selectedTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _clearTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? Colors.red[900]!.withOpacity(0.2)
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.clear,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hapus Waktu',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

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
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).loadWeather();
    });

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

  Widget _buildGradientProgressBar(double progress, bool isDarkMode) {
    return SizedBox(
      height: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      accentColorPink,
                      accentColorOrange,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      });
    }
  }

  Future<void> toggleTodoStatus(
      String id, bool currentStatus, Todo todo) async {
    todo.isCompleted = !currentStatus;
    await DatabaseHelper.instance.update(todo);
    _refreshTodos();

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

  Future<void> _showAddEditDialog([Todo? todo]) async {
    final isEditing = todo != null;
    String title = todo?.title ?? '';
    String category = todo?.category ?? categories.first;
    DateTime? deadline = todo?.deadline;
    TimeOfDay? time = todo?.time;
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
                        decoration: InputDecoration(
                          labelText: 'Nama Tugas',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onChanged: (value) => title = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        items: categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Theme.of(context).cardColor,
                        onChanged: (String? newValue) {
                          if (newValue != null)
                            setStateSB(() => category = newValue);
                        },
                      ),
                      const SizedBox(height: 15),
                      TimePickerWidget(
                        initialTime: time,
                        onTimeChanged: (newTime) {
                          setStateSB(() => time = newTime);
                        },
                        isDarkMode:
                            Theme.of(context).brightness == Brightness.dark,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deadline: ${deadline == null ? 'Tidak Ada' : DateFormat('dd/MM/yyyy').format(deadline!)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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
                          Text(
                            'Prioritas Mendesak (Urgent)',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
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
              backgroundColor: Theme.of(context).cardColor,
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
                        if (isEditing) {
                          todo!.title = title;
                          todo.category = category;
                          todo.deadline = deadline;
                          todo.time = time;
                          todo.isUrgent = isUrgent;
                          await DatabaseHelper.instance.update(todo);
                        } else {
                          final newTodo = Todo(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: title,
                            category: category,
                            deadline: deadline,
                            time: time,
                            isUrgent: isUrgent,
                            isCompleted: false,
                            username: _username,
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

  Widget _buildWeatherWidget() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator()));
        }
        if (provider.error.isNotEmpty) {
          return Center(
              child: TextButton(
                  onPressed: provider.loadWeather,
                  child: const Text("Gagal memuat cuaca. Ketuk untuk ulangi.",
                      style: TextStyle(color: Colors.red))));
        }
        if (provider.weather == null) {
          return Center(
              child: TextButton(
                  onPressed: provider.loadWeather,
                  child: const Text("Muat Cuaca")));
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Lokasi Sekarang",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${provider.weather!.temperature}°C",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          "Angin: ${provider.weather!.windSpeed} km/h",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.map,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MapScreen()),
                      );
                    },
                    tooltip: 'Lihat di Peta',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );
                },
                icon: Icon(
                  Icons.map,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                label: Text(
                  'Buka Peta Lokasi',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                    width: 1,
                  ),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
          color: isSelected
              ? primaryColor
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              "Hapus",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(todo);
      },
      onDismissed: (direction) {
        deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Tugas '${todo.title}' berhasil dihapus",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 1,
        color: Theme.of(context).cardColor,
        child: ListTile(
          onTap: () => _showAddEditDialog(todo),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
              if (todo.time != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    todo.hourDisplay,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: todo.isCompleted
                  ? Colors.grey
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.category,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (todo.time != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          todo.formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (todo.deadline != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM').format(todo.deadline!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (todo.time != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      todo.minuteDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  bool confirm = await _showDeleteConfirmationDialog(todo);
                  if (confirm && mounted) {
                    deleteTodo(todo.id);
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: todo.isCompleted
                      ? primaryColor
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
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

  Future<bool> _showDeleteConfirmationDialog(Todo todo) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Konfirmasi Hapus",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              content: Text(
                  "Apakah anda yakin akan menghapus tugas '${todo.title}'?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Tidak"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Ya, Hapus",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bannerColor,
            bannerColor.withOpacity(0.8),
            const Color(0xFF5A67D8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
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
              boxShadow: [
                BoxShadow(
                  color: _animatedColor.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    int totalTodos = todos.length;
    int completedTodos = todos.where((t) => t.isCompleted).length;
    double progress = totalTodos == 0 ? 0 : completedTodos / totalTodos;

    final lightGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFF7F2FF),
        const Color(0xFFF0E6FF),
        const Color(0xFFE8DAFF),
        Colors.white.withOpacity(0.9),
      ],
    );

    final darkGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF121212),
        const Color(0xFF1A1A2E),
        const Color(0xFF16213E),
        const Color(0xFF0F3460),
      ],
    );

    final bannerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        bannerColor,
        bannerColor.withOpacity(0.8),
        const Color(0xFF5A67D8),
      ],
    );

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? darkGradient : lightGradient,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: bannerGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Priority Hub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              floating: true,
              expandedHeight: 120,
              flexibleSpace: Container(
                decoration: BoxDecoration(gradient: bannerGradient),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.white),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MapScreen())),
                ),
                IconButton(
                  icon: Icon(
                    themeNotifier.value == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    themeNotifier.value = themeNotifier.value == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                    await prefs.setBool(
                        'is_dark_mode', themeNotifier.value == ThemeMode.dark);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _logout,
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildBanner(),
                _buildWeatherWidget(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade900.withOpacity(0.7)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // BAGIAN PERBAIKAN: Menghapus Gradasi Teks
                            Text(
                              'Halo, $_username!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Siap menghadapi hari ini?',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade900.withOpacity(0.8)
                              : Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: primaryColor.withOpacity(0.15),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Progress Tugas',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade700)),
                                Text('$completedTodos/$totalTodos Selesai',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildGradientProgressBar(progress, isDarkMode),
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
                            color: Theme.of(context).colorScheme.onSurface),
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
                          ? const Center(child: Text("Tidak ada tugas."))
                          : Column(
                              children: filteredTodos
                                  .map((todo) => _buildTodoItem(todo))
                                  .toList()),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
