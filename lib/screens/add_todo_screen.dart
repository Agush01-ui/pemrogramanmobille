import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';

const Color primaryColor = Color(0xFF9F7AEA);

class AddTodoScreen extends StatefulWidget {
  final Todo? todo; // Jika edit
  final String username;

  const AddTodoScreen({super.key, this.todo, required this.username});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String category;
  DateTime? deadline;
  bool isUrgent = false;

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
    title = widget.todo?.title ?? '';
    category = widget.todo?.category ?? categories.first;
    deadline = widget.todo?.deadline;
    isUrgent = widget.todo?.isUrgent ?? false;
  }

  void _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TodoProvider>(context, listen: false);

      if (widget.todo != null) {
        // Edit
        widget.todo!
          ..title = title
          ..category = category
          ..deadline = deadline
          ..isUrgent = isUrgent;

        await provider.updateTodo(widget.todo!);
      } else {
        // Tambah baru
        final newTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          category: category,
          deadline: deadline,
          isUrgent: isUrgent,
          isCompleted: false,
          username: widget.username,
        );

        await provider.addTodo(newTodo);
      }

      // Tutup screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo != null ? 'Edit Tugas' : 'Tambah Tugas'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Nama Tugas'),
                onChanged: (value) => title = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 16),
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
                      if (pickedDate != null) setState(() => deadline = pickedDate);
                    },
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Prioritas Mendesak'),
                  Switch(
                    value: isUrgent,
                    onChanged: (val) => setState(() => isUrgent = val),
                    activeColor: primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.todo != null ? 'Simpan Perubahan' : 'Tambah Tugas',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
