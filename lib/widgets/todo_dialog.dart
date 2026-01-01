import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';

const Color primaryColor = Color(0xFF9F7AEA);

Future<void> showTodoDialog(
  BuildContext context, {
  Todo? todo,
  required String username,
}) async {
  final isEdit = todo != null;

  String title = todo?.title ?? '';
  String category = todo?.category ?? 'Pekerjaan';
  DateTime deadline = todo?.deadline ?? DateTime.now();
  bool isUrgent = todo?.isUrgent ?? false;

  final formKey = GlobalKey<FormState>();

  final categories = ['Pekerjaan', 'Pribadi', 'Belanja', 'Lainnya'];

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (context, setStateSB) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: title,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                      onChanged: (v) => title = v,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setStateSB(() => category = v!),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                              'Deadline: ${DateFormat('dd MMM yyyy').format(deadline)}'),
                        ),
                        TextButton(
                          child: const Text('Pilih Tanggal'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: deadline,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateSB(() => deadline = picked);
                            }
                          },
                        )
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tandai sebagai Urgent'),
                      value: isUrgent,
                      activeColor: primaryColor,
                      onChanged: (v) => setStateSB(() => isUrgent = v),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final provider =
                  Provider.of<TodoProvider>(context, listen: false);

              if (isEdit) {
                final updated = todo!.copyWith(
                  title: title,
                  category: category,
                  deadline: deadline,
                  isUrgent: isUrgent,
                );
                await provider.updateTodo(updated);
              } else {
                final newTodo = Todo(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: title,
                  category: category,
                  deadline: deadline,
                  isUrgent: isUrgent,
                  completed: false,
                  username: username,
                );
                await provider.addTodo(newTodo);
              }

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
