import 'package:railse/model/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  static const String _tasksKey = 'tasks_key_v2';

  static Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey);
      if (tasksJson == null || tasksJson.isEmpty) {
        final dummyTasks = _getDummyTasks();
        await saveTasks(dummyTasks);
        return dummyTasks;
      }
      try {
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      } catch (e) {
        print('Error parsing tasks: $e');
        await prefs.remove(_tasksKey);
        final dummyTasks = _getDummyTasks();
        await saveTasks(dummyTasks);
        return dummyTasks;
      }
    } catch (e) {
      print('Error getting tasks: $e');
      return _getDummyTasks();
    }
  }

  static Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      return await prefs.setStringList(_tasksKey, tasksJson);
    } catch (e) {
      print('Error saving tasks: $e');
      return false;
    }
  }

  static Future<bool> updateTask(Task updatedTask) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
        return await saveTasks(tasks);
      }
      return false;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }
  static Future<void> clearAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }

  static List<Task> _getDummyTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 'Order-1',
        title: 'Arrange Pickup',
        description: 'Order-1',
        assignee: 'Sandhya',
        startDate: DateTime(2025, 8, 1),
        endDate: DateTime(2025, 8, 4),
        status: TaskStatus.started,
        priority: TaskPriority.high,
      ),
      Task(
        id: 'Entity-2',
        title: 'Adhoc Task',
        description: 'Entity-2',
        assignee: 'Arman',
        startDate: DateTime(2025, 8, 5),
        endDate: DateTime(2025, 8, 6),
        status: TaskStatus.started,
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'Order-3',
        title: 'Collect Payment',
        description: 'Order-3',
        assignee: 'Sandhya',
        startDate: DateTime(2025, 8, 15),
        endDate: now.subtract(const Duration(hours: 17, minutes: 2)),
        status: TaskStatus.started,
        priority: TaskPriority.high,
      ),
      Task(
        id: 'Order-4',
        title: 'Arrange Delivery',
        description: 'Order-4',
        assignee: 'Prashant',
        startDate: DateTime(2025, 8, 20),
        endDate: DateTime(2025, 8, 21),
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'Entity-6',
        title: 'Share Company Profile',
        description: 'Entity-6',
        assignee: 'Asif Khan K',
        startDate: DateTime(2025, 8, 22),
        endDate: DateTime(2025, 8, 23),
        status: TaskStatus.completed,
        priority: TaskPriority.low,
      ),
      Task(
        id: 'Entity-7',
        title: 'Add Followup',
        description: 'Entity-7',
        assignee: 'Avik',
        startDate: DateTime(2025, 8, 25),
        endDate: DateTime(2025, 8, 26),
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'Enquiry-8',
        title: 'Convert Enquiry',
        description: 'Enquiry-8',
        assignee: 'Prashant',
        startDate: DateTime(2025, 8, 28),
        endDate: now.add(const Duration(days: 3)),
        status: TaskStatus.notStarted,
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'Order-9',
        title: 'Arrange Pickup',
        description: 'Order-9',
        assignee: 'Prashant',
        startDate: DateTime(2025, 9, 1),
        endDate: now.add(const Duration(days: 11)),
        status: TaskStatus.notStarted,
        priority: TaskPriority.high,
      ),
    ];
  }
}