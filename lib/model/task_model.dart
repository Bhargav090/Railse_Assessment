import 'dart:convert';

enum TaskStatus { notStarted, started, completed }

enum TaskPriority { high, medium, low }

class Task {
  final String id;
  String title;
  final String description;
  final String assignee;
  DateTime startDate;
  DateTime endDate;
  TaskStatus status;
  final TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignee': assignee,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'status': status.index,
      'priority': priority.index,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      assignee: map['assignee'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      status: TaskStatus.values[map['status']],
      priority: TaskPriority.values[map['priority']],
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? assignee,
    DateTime? startDate,
    DateTime? endDate,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}
