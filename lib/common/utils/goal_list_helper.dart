import 'package:haenaedda/domain/entities/goal.dart';

class GoalListHelper {
  static const String _firstGoalId = '10';
  static const int orderStep = 10;

  static int getNextOrder(List<Goal> goals) {
    if (goals.isEmpty) return orderStep;
    final maxOrder = goals.map((g) => g.order).reduce((a, b) => a > b ? a : b);
    return maxOrder + orderStep;
  }

  static String getNextId(List<Goal> goals) {
    if (goals.isEmpty) return _firstGoalId;
    final lastId = int.tryParse(goals.last.id) ?? 0;
    return (lastId + 1).toString();
  }

  static List<Goal> sorted(List<Goal> goals) {
    return [...goals]..sort((a, b) => a.order.compareTo(b.order));
  }
}
