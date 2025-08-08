import 'package:flutter/material.dart';
import 'package:railse/model/task_model.dart';
import 'package:railse/utils/date_util.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left indicator bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _getIndicatorColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    _buildContent(),
                    const SizedBox(height: 12),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIndicatorColor() {
    switch (task.status) {
      case TaskStatus.notStarted:
        return AppColors.grey;
      case TaskStatus.started:
        return DateTime.now().isAfter(task.endDate) 
            ? AppColors.primaryBlue 
            : AppColors.warningOrange;
      case TaskStatus.completed:
        return AppColors.completedGreen;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          task.description,
          style:TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: task.status==TaskStatus.completed? AppColors.completedtaskcolor : AppColors.primaryBlue,
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_horiz,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onSelected: (value) {
            if (value == 'edit_title') {
              _showEditTitleDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit_title',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Change Task Name'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        _buildStatusChip(),
      ],
    );
  }

  void _showEditTitleDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: task.title);
    
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            color: task.status == TaskStatus.completed 
                ? AppColors.textSecondary 
                : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              task.assignee,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (task.priority == TaskPriority.high) ...[
              const SizedBox(width: 12),
              _buildPriorityChip(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateSection(context),
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (task.status) {
      case TaskStatus.completed:
        backgroundColor = AppColors.completedGreen;
        textColor = Colors.white;
        text = '${AppStrings.completed}: ${DateUtilsHelper.formatDate(task.endDate)}';
        break;
      case TaskStatus.started:
        backgroundColor = DateTime.now().isAfter(task.endDate) 
            ? AppColors.overdueRed 
            : AppColors.warningOrange;
        textColor = Colors.white;
        text = DateUtilsHelper.getDueDuration(task.endDate);
        break;
      case TaskStatus.notStarted:
        backgroundColor = AppColors.warningOrange;
        textColor = Colors.white;
        text = DateUtilsHelper.getDueDuration(task.endDate);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.highPriorityBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        AppStrings.highPriority,
        style: TextStyle(
          color: AppColors.highPriorityText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start Date Row - Always show for active tasks
        if (task.status != TaskStatus.completed) ...[
          Row(
            children: [
              Text(
                '${AppStrings.started}: ${DateUtilsHelper.formatDate(task.startDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onEditStartDate,
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        
        // Due Date Row - Show based on status
        if (task.status == TaskStatus.started) ...[
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onEditEndDate,
                child: Text(
                  'Due: ${DateUtilsHelper.formatDate(task.endDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: DateTime.now().isAfter(task.endDate) 
                        ? AppColors.overdueRed 
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onEditEndDate,
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ] else if (task.status == TaskStatus.notStarted) ...[
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onEditEndDate,
                child: Text(
                  'Due: ${DateUtilsHelper.formatDate(task.endDate)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onEditEndDate,
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ] else if (task.status == TaskStatus.completed) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.started}: ${DateUtilsHelper.formatDate(task.startDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Completed: ${DateUtilsHelper.formatDate(task.endDate)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.completedGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton() {
    switch (task.status) {
      case TaskStatus.notStarted:
        return ElevatedButton(
          onPressed: onStartTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            AppStrings.startTask,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        );
      case TaskStatus.started:
        return ElevatedButton(
          onPressed: onMarkComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.completedGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 16),
              SizedBox(width: 4),
              Text(
                AppStrings.markComplete,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      case TaskStatus.completed:
        return const SizedBox.shrink();
    }
  }
}