import 'package:flutter/material.dart';

/// Số liệu demo — gắn provider / storage thật sau.
class MyStatScreen extends StatelessWidget {
  const MyStatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const photosSwiped = 1284;
    const storageMbSaved = 420;
    const deleted = 312;
    const kept = 972;

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê của bạn')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatTile(
            label: 'Ảnh đã swipe',
            value: '$photosSwiped',
            icon: Icons.swipe_vertical,
          ),
          _StatTile(
            label: 'Dung lượng tiết kiệm',
            value: '$storageMbSaved MB',
            icon: Icons.storage,
          ),
          _StatTile(
            label: 'Đã xóa',
            value: '$deleted',
            icon: Icons.delete_outline,
          ),
          _StatTile(
            label: 'Giữ lại',
            value: '$kept',
            icon: Icons.favorite_outline,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
