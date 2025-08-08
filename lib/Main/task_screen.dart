import 'package:flutter/material.dart';
import 'package:railse/model/task_model.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> tasks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedTasks = await TaskService.getTasks();
      print('Loaded ${loadedTasks.length}');
      
      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load tasks: $e';
      });
    }
  }

  Future<void> _startTask(Task task) async {
    final updatedTask = task.copyWith(status: TaskStatus.started);
    final success = await TaskService.updateTask(updatedTask);
    if (success) {
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = updatedTask;
        }
      });
    }
  }

  Future<void> _markTaskComplete(Task task) async {
    final updatedTask = task.copyWith(status: TaskStatus.completed);
    final success = await TaskService.updateTask(updatedTask);
    if (success) {
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = updatedTask;
        }
      });
    }
  }

  Future<void> _editStartDate(Task task) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: task.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select Start Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != task.startDate) {
      final updatedTask = task.copyWith(startDate: pickedDate);
      final success = await TaskService.updateTask(updatedTask);
      if (success) {
        setState(() {
          final index = tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            tasks[index] = updatedTask;
          }
        });
      }
    }
  }

  Future<void> _editEndDate(Task task) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: task.endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select End Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != task.endDate) {
      final updatedTask = task.copyWith(endDate: pickedDate);
      final success = await TaskService.updateTask(updatedTask);
      if (success) {
        setState(() {
          final index = tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            tasks[index] = updatedTask;
          }
        });
      }
    }
  }

  Future<void> _editTaskTitle(Task task, String newTitle) async {
    final updatedTask = task.copyWith(title: newTitle);
    final success = await TaskService.updateTask(updatedTask);
    if (success) {
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = updatedTask;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          AppStrings.appTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.overdueRed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No tasks available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTasks,
                            child: const Text('Reload Tasks'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onStartTask: () => _startTask(task),
                          onMarkComplete: () => _markTaskComplete(task),
                          onEditStartDate: () => _editStartDate(task),
                          onEditEndDate: () => _editEndDate(task),
                          onEditTitle: (newTitle) => _editTaskTitle(task, newTitle),
                        );
                      },
                    ),
    );
  }
}