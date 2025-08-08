import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String getDueDuration(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return 'Due in ${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return 'Due in ${difference.inMinutes}m';
      } else {
        return 'Due now';
      }
    } else if (difference.inDays == 1) {
      return 'Due Tomorrow';
    } else if (difference.inDays > 1) {
      return 'Due in ${difference.inDays} days';
    } else {
      return getOverdueDuration(dueDate);
    }
  }

  static String getOverdueDuration(DateTime overdueDate) {
    final now = DateTime.now();
    final difference = now.difference(overdueDate);

    if (difference.inDays > 0) {
      return 'Overdue - ${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return 'Overdue - ${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return 'Overdue - ${difference.inMinutes}m';
    }
  }
}