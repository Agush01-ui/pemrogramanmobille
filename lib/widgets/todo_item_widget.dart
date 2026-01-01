import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';

const Color primaryColor = Color(0xFF9F7AEA);
const Color accentColorOrange = Color(0xFFFF9800);
const Color accentColorPink = Color(0xFFF48FB1);

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;

  const TodoItemWidget({super.key, required this.todo, this.onTap});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    // Warna kategori
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
          builder: (_) => AlertDialog(
            title: const Text("Konfirmasi Hapus"),
            content: const Text("Apakah Anda yakin ingin menghapus tugas ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Hapus"),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        todoProvider.deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${todo.title} dihapus")),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 1,
        child: ListTile(
          onTap: onTap,
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
              decoration:
                  todo.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
              color: todo.isCompleted ? Colors.grey : null,
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
                onPressed: () {
                  todo.isCompleted = !todo.isCompleted;
                  todoProvider.updateTodo(todo);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
