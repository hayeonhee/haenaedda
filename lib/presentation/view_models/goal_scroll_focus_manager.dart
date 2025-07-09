import 'package:flutter/material.dart';
import 'package:haenaedda/domain/entities/goal.dart';

class GoalScrollFocusManager extends ChangeNotifier {
  Goal? _focusedGoal;
  bool _shouldScroll = false;

  Goal? get focusedGoal => _focusedGoal;
  bool get shouldScroll => _shouldScroll;

  void set(Goal goal) {
    _focusedGoal = goal;
    _shouldScroll = true;
    notifyListeners();
  }

  void clear() {
    _focusedGoal = null;
    _shouldScroll = false;
  }
}
