extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element that satisfies [test], or null if none found.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  T? get firstOrNull => isEmpty ? null : first;
}
