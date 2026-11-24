import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  Task copyWith({bool? isCompleted}) {
    return Task(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final isCompleted = json['isCompleted'];
    if (id is! String || title is! String || isCompleted is! bool) {
      throw const FormatException('Invalid task record.');
    }
    return Task(id: id, title: title, isCompleted: isCompleted);
  }
}

class TaskStorage {
  const TaskStorage();

  static const _tasksKey = 'todo_list_tasks';

  Future<List<Task>> loadTasks() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedTasks = preferences.getString(_tasksKey);
    if (encodedTasks == null) {
      return [];
    }

    final decodedTasks = jsonDecode(encodedTasks);
    if (decodedTasks is! List) {
      throw const FormatException('Invalid task list.');
    }

    return decodedTasks.map((record) {
      if (record is! Map<String, dynamic>) {
        throw const FormatException('Invalid task record.');
      }
      return Task.fromJson(record);
    }).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedTasks = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );
    final saved = await preferences.setString(_tasksKey, encodedTasks);
    if (!saved) {
      throw StateError('Task preferences could not be saved.');
    }
  }
}

/// Hands out a number for each save request and answers whether a request is
/// still the most recent one. Only the most recent request's outcome may
/// change the save-error indicator, so an older save finishing late cannot
/// hide a newer failure.
class SaveRequestTracker {
  int _latestRequest = 0;

  int startRequest() => ++_latestRequest;

  bool isLatest(int request) => request == _latestRequest;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.storage = const TaskStorage()});

  final TaskStorage storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TaskListScreen(storage: storage),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.storage});

  final TaskStorage storage;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _titleController = TextEditingController();
  final _tasks = <Task>[];
  final _saveRequests = SaveRequestTracker();
  var _isLoaded = false;
  var _loadFailed = false;
  var _saveFailed = false;
  String? _inputError;
  var _nextTaskSequence = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final loadedTasks = await widget.storage.loadTasks();
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(loadedTasks);
        _isLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _isLoaded = true;
      });
    }
  }

  Future<void> _saveTasks() async {
    final request = _saveRequests.startRequest();
    try {
      await widget.storage.saveTasks(List.unmodifiable(_tasks));
      if (!mounted || !_saveRequests.isLatest(request)) return;
      setState(() => _saveFailed = false);
    } catch (_) {
      if (!mounted || !_saveRequests.isLatest(request)) return;
      setState(() => _saveFailed = true);
    }
  }

  Future<void> _addTask() async {
    if (!_isLoaded || _loadFailed) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _inputError = 'Please enter a task title.');
      return;
    }

    final task = Task(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_nextTaskSequence++}',
      title: title,
      isCompleted: false,
    );
    setState(() {
      _tasks.add(task);
      _inputError = null;
      _titleController.clear();
    });
    await _saveTasks();
  }

  Future<void> _toggleTask(String taskId, bool isCompleted) async {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
      }
    });
    await _saveTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    setState(() => _tasks.removeWhere((task) => task.id == taskId));
    await _saveTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loadFailed
              ? const Center(child: Text('Failed to load tasks.'))
              : !_isLoaded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Task title',
                        errorText: _inputError,
                      ),
                      onSubmitted: (_) => _addTask(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                    if (_saveFailed)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Failed to save tasks.',
                          key: ValueKey('save-error'),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _tasks.isEmpty
                          ? const Center(child: Text('No tasks yet.'))
                          : ListView.builder(
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                return ListTile(
                                  key: ValueKey('task-${task.id}'),
                                  leading: Checkbox(
                                    key: ValueKey('task-toggle-${task.id}'),
                                    value: task.isCompleted,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _toggleTask(task.id, value);
                                      }
                                    },
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    key: ValueKey('task-delete-${task.id}'),
                                    tooltip: 'Delete ${task.title}',
                                    onPressed: () => _deleteTask(task.id),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
