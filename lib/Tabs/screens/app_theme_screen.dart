import 'package:flutter/material.dart';

class AppThemeScreen extends StatefulWidget {
  const AppThemeScreen({super.key});

  @override
  State<AppThemeScreen> createState() => _AppThemeScreenState();
}

class _AppThemeScreenState extends State<AppThemeScreen> {
  int _selected = 0;

  static const _options = <({String name, Color seed})>[
    (name: 'Cam cổ điển', seed: Color(0xFFFF9800)),
    (name: 'Xanh dương', seed: Color(0xFF2196F3)),
    (name: 'Tím', seed: Color(0xFF7E57C2)),
    (name: 'Xanh lá', seed: Color(0xFF43A047)),
    (name: 'Đỏ', seed: Color(0xFFE53935)),
    (name: 'Đen & trắng', seed: Color(0xFF424242)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chủ đề app')),
      body: ListView.builder(
        itemCount: _options.length,
        itemBuilder: (context, i) {
          final o = _options[i];
          final selected = _selected == i;
          return ListTile(
            leading: CircleAvatar(backgroundColor: o.seed),
            title: Text(o.name),
            trailing: selected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              setState(() => _selected = i);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã chọn: ${o.name} (preview — áp theme root sau)',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
