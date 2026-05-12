import 'package:flutter/material.dart';

import 'streak/streak_scope.dart';

/// Header chung: tên app + pill streak (flame + số).
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  static const Color _peach = Color(0xFFFFE8DC);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final streak = StreakScope.of(context);

    return ColoredBox(
      color: _peach,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, top + 10, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'photocleaner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: streak,
              builder: (context, _) {
                return _StreakPill(count: streak.streak);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD4C4).withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 20,
            color: Colors.deepOrange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
