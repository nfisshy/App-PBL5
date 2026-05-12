import 'package:flutter/material.dart';

/// Giá fake — giao diện đơn giản.
class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});

  static const Color _accent = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      backgroundColor: const Color(0xFFFFF3E0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Photo Cleaner Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mở khóa dọn ảnh không giới hạn & chủ đề độc quyền.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          _PlanCard(
            title: 'Hàng tuần',
            price: '₫79.000 / tuần',
            subtitle: 'Hủy bất cứ lúc nào',
            highlighted: false,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Hàng năm',
            price: '₫599.000 / năm',
            subtitle: 'Tiết kiệm ~40% so với tuần',
            highlighted: true,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Trọn đời',
            price: '₫1.990.000',
            subtitle: 'Thanh toán một lần',
            highlighted: false,
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.highlighted,
  });

  final String title;
  final String price;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: highlighted ? SubscribeScreen._accent : Colors.grey.shade400,
      width: highlighted ? 2 : 1,
    );
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: highlighted ? 3 : 0,
      shadowColor: SubscribeScreen._accent.withOpacity(0.35),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (highlighted)
                  Chip(
                    label: const Text('Phổ biến nhất'),
                    backgroundColor: SubscribeScreen._accent.withOpacity(0.25),
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
