import 'package:flutter/widgets.dart';

import 'streak_controller.dart';

/// Cung cấp [StreakController] cho cây widget (header 3 tab, swipe, …).
class StreakScope extends InheritedNotifier<StreakController> {
  const StreakScope({
    super.key,
    required StreakController controller,
    required super.child,
  }) : super(notifier: controller);

  static StreakController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StreakScope>();
    assert(scope != null, 'StreakScope not found');
    return scope!.notifier!;
  }

  static StreakController? maybeOf(BuildContext context) {
    final el = context.getElementForInheritedWidgetOfExactType<StreakScope>();
    return (el?.widget as StreakScope?)?.notifier;
  }
}
