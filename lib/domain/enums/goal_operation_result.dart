enum AddGoalResult {
  success,
  emptyInput,
  duplicate,
  saveFailed,
}

enum RenameGoalResult {
  success,
  emptyInput,
  notFound,
  duplicate,
  saveFailed,
}

enum ResetEntireGoalResult {
  success,
  recordFailed,
  goalFailed,
}

enum ResetAllGoalsResult {
  success,
  failure,
}
