import 'package:flutter/material.dart';
import 'package:railse/constants/app_colors.dart';
import 'package:railse/model/task_model.dart';
import 'package:railse/widgets/dashed_line.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onStartTask;
  final VoidCallback onMarkComplete;
  final VoidCallback onEditStartDate;
  final VoidCallback onEditEndDate;
  final Function(String) onEditTitle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onStartTask,
    required this.onMarkComplete,
    required this.onEditStartDate,
    required this.onEditEndDate,
    required this.onEditTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.taskCardWhite,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(color: _getIndicatorColor()),
                  child: task.status == TaskStatus.notStarted
                      ? CustomPaint(
                          painter: DashedLinePainter(
                            color: AppColors.greyShade400!,
                            strokeWidth: 6,
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  task.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: task.status == TaskStatus.completed
                                        ? AppColors.taskCompletedDescriptionBlue
                                        : AppColors.taskDescriptionBlue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.taskDescriptionBlue,
                                  ),
                                ),

                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: AppColors.greyShade400,
                                    size: 20,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit_title') {
                                      _showEditTitleDialog(context);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit_title',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: AppColors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Change Task Name'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildStatusChip(),
                                if (task.status == TaskStatus.started &&
                                    DateTime.now().isAfter(task.endDate)) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: onEditEndDate,
                                    child: Icon(
                                      Icons.edit_square,
                                      size: 17,
                                      color: AppColors.greyShade400,
                                    ),
                                  ),
                                ] else if (task.status ==
                                    TaskStatus.notStarted) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: onEditEndDate,
                                    child: Icon(
                                      Icons.edit_square,
                                      size: 17,
                                      color: AppColors.greyShade400,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.taskTitleGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (task.status == TaskStatus.notStarted)
                              Row(
                                children: [
                                  Text(
                                    'Start: ${_formatShortDate(task.startDate)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.greyShade600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: onEditStartDate,
                                    child: Icon(
                                      Icons.edit_square,
                                      size: 17,
                                      color: AppColors.greyShade400,
                                    ),
                                  ),
                                ],
                              )
                            else if (task.status == TaskStatus.started ||
                                task.status == TaskStatus.completed)
                              Text(
                                'Started: ${_formatShortDate(task.startDate)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.greyShade600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  task.assignee,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: task.status == TaskStatus.completed
                                        ? AppColors.greyShade400
                                        : AppColors.black87,
                                  ),
                                ),
                                if (task.priority == TaskPriority.high) ...[
                                  const SizedBox(width: 8),
                                  _buildPriorityChip(),
                                ],
                              ],
                            ),
                            if (task.status != TaskStatus.completed)
                              _buildActionText(),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 1, color: AppColors.greyShade200),
      ],
    );
  }

  Color _getIndicatorColor() {
    switch (task.status) {
      case TaskStatus.notStarted:
        return AppColors.transparent;
      case TaskStatus.started:
        return DateTime.now().isAfter(task.endDate)
            ? AppColors.taskIndicatorBlue
            : AppColors.taskIndicatorBlue;
      case TaskStatus.completed:
        return AppColors.taskCompletedIndicator;
    }
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (task.status) {
      case TaskStatus.completed:
        backgroundColor = AppColors.transparent;
        textColor = AppColors.taskCompletedGreen;
        text = 'Completed: ${_formatShortDate(task.endDate)}';
        break;
      case TaskStatus.started:
        if (DateTime.now().isAfter(task.endDate)) {
          backgroundColor = AppColors.transparent;
          textColor = AppColors.taskOverdueRed;
          text = 'Overdue - ${_getOverdueDuration()}';
        } else {
          backgroundColor = AppColors.transparent;
          textColor = AppColors.taskDueOrange;
          text = _getDueDuration();
        }
        break;
      case TaskStatus.notStarted:
        backgroundColor = AppColors.transparent;
        textColor = AppColors.taskDueOrange;
        text = _getDueDuration();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActionText() {
    switch (task.status) {
      case TaskStatus.notStarted:
        return GestureDetector(
          onTap: onStartTask,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle, size: 16, color: AppColors.taskStartBlue),
              SizedBox(width: 4),
              Text(
                'Start Task',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.taskStartBlue,
                ),
              ),
            ],
          ),
        );
      case TaskStatus.started:
        return GestureDetector(
          onTap: onMarkComplete,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 16, color: AppColors.taskCompleteGreen),
              SizedBox(width: 4),
              Text(
                'Mark as complete',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.taskCompleteActionGreen,
                ),
              ),
            ],
          ),
        );
      case TaskStatus.completed:
        return const SizedBox.shrink();
    }
  }

  String _getOverdueDuration() {
    final difference = DateTime.now().difference(task.endDate);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
  }

  String _getDueDuration() {
    final now = DateTime.now();
    final difference = task.endDate.difference(now);

    if (difference.inDays > 1) {
      return 'Due in ${difference.inDays} days';
    } else if (difference.inDays == 1) {
      return 'Due Tomorrow';
    } else if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return 'Due in ${difference.inHours}h';
      } else {
        return 'Due in ${difference.inMinutes}m';
      }
    } else {
      return 'Overdue';
    }
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        'High Priority',
        style: TextStyle(
          color: AppColors.taskHighPriorityRed,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _showEditTitleDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: task.title,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Task Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onEditTitle(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}