enum GoalEditMode { create, update, order }

class GoalEditResult {
  final String title;
  final GoalEditMode mode;

  GoalEditResult({required this.title, required this.mode});
}
