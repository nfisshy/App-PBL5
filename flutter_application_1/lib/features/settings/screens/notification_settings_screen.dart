import 'package:flutter/material.dart';

/// Bento pastel — peach / kem, ô bo tròn lớn, toggle tím nhạt + chọn giờ.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  static const Color _bgPeach = Color(0xFFFFE8DC);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _purpleToggle = Color(0xFFB39DDB);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool reminders = true;
  bool digest = false;
  bool quiet = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay quietEnd = const TimeOfDay(hour: 22, minute: 0);

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay current,
    ValueChanged<TimeOfDay> onPick,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) onPick(picked);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textBold = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      fontFamily: 'Roboto',
      letterSpacing: 0.2,
    );

    return Scaffold(
      backgroundColor: NotificationSettingsScreen._bgPeach,
      appBar: AppBar(
        title: const Text(
          'Cài đặt thông báo',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: NotificationSettingsScreen._bgPeach,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bentoLarge(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng quan', style: textBold),
                  const SizedBox(height: 12),
                  _rowToggle(
                    'Nhắc dọn ảnh',
                    reminders,
                    (v) => setState(() => reminders = v),
                  ),
                  const Divider(height: 28),
                  _timeRow(
                    context,
                    'Giờ nhắc hằng ngày',
                    reminderTime,
                    () => _pickTime(
                      context,
                      reminderTime,
                      (t) => reminderTime = t,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _bentoSmall(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tóm tắt', style: textBold),
                        const SizedBox(height: 10),
                        _rowToggle(
                          'Gửi digest',
                          digest,
                          (v) => setState(() => digest = v),
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _bentoSmall(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Yên lặng', style: textBold),
                        const SizedBox(height: 10),
                        _rowToggle(
                          'Chế độ im lặng',
                          quiet,
                          (v) => setState(() => quiet = v),
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _bentoLarge(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Khung giờ yên lặng', style: textBold),
                  const SizedBox(height: 12),
                  _timeRow(
                    context,
                    'Kết thúc lúc',
                    quietEnd,
                    () => _pickTime(context, quietEnd, (t) => quietEnd = t),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bentoLarge({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NotificationSettingsScreen._cream,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _bentoSmall({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NotificationSettingsScreen._cream,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _rowToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool compact = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: compact ? 14 : 16,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        Transform.scale(
          scale: compact ? 0.9 : 1,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: NotificationSettingsScreen._purpleToggle,
            activeTrackColor: NotificationSettingsScreen._purpleToggle
                .withValues(alpha: 0.45),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _timeRow(
    BuildContext context,
    String label,
    TimeOfDay time,
    VoidCallback onPick,
  ) {
    final formatted = time.format(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Text(
                formatted,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: NotificationSettingsScreen._purpleToggle.withValues(
                    alpha: 0.95,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.schedule, color: Colors.grey.shade700),
            ],
          ),
        ),
      ),
    );
  }
}
