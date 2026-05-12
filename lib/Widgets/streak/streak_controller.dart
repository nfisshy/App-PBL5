import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Streak lưu [SharedPreferences] — đọc/ghi qua các màn/tab.
///
/// ```dart
/// StreakScope.of(context).increment();
/// ```
class StreakController extends ChangeNotifier {
  StreakController();

  static const _key = 'photocleaner_streak';

  int _value = 0;
  int get streak => _value;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _value = p.getInt(_key) ?? 0;
    notifyListeners();
  }

  Future<void> setStreak(int value) async {
    final v = value < 0 ? 0 : value;
    if (_value == v) return;
    _value = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_key, _value);
  }

  Future<void> increment([int delta = 1]) async {
    await setStreak(_value + delta);
  }

  Future<void> reset() async => setStreak(0);
}
