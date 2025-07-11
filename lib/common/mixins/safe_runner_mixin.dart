import 'package:flutter/material.dart';

mixin SafeRunnerMixin {
  Future<T> runSafely<T>(
    Future<T> Function() action,
    String label,
    T fallback,
  ) async {
    try {
      return await action();
    } catch (e, stack) {
      debugPrint('[SafeRunner] $label failed: $e');
      debugPrint('$stack');
      return fallback;
    }
  }
}
