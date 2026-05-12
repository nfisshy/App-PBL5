import 'package:flutter/material.dart';

import '../swipe/swipe_screen.dart';

class SwipeEntryTab extends StatelessWidget {
  const SwipeEntryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SwipeScreen()),
            );
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Mở màn hình swipe'),
        ),
      ),
    );
  }
}
