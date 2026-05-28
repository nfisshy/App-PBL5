import 'package:flutter/material.dart';

import 'photo_screen.dart';
import 'trim_home_screen.dart';
import 'compress_home.dart';
class ToolTab extends StatelessWidget {
  const ToolTab({super.key});

  final List<_ToolItem> tools = const [
    _ToolItem(
      title: 'Colorize',
      subtitle: 'Bring old memories to life',
      icon: Icons.palette_rounded,
      gradient: _G.colorize,
    ),
    _ToolItem(
      title: 'Compress',
      subtitle: 'Reduce file size instantly',
      icon: Icons.compress_rounded,
      gradient: _G.compress,
    ),
    _ToolItem(
      title: 'Enhance',
      subtitle: 'Boost quality with AI',
      icon: Icons.auto_fix_high_rounded,
      gradient: _G.enhance,
    ),
    _ToolItem(
      title: 'Remove BG',
      subtitle: 'Erase backgrounds cleanly',
      icon: Icons.layers_clear_rounded,
      gradient: _G.removeBg,
    ),
    _ToolItem(
      title: 'Split',
      subtitle: 'Cut videos into parts',
      icon: Icons.call_split_rounded,
      gradient: _G.split,
    ),
    _ToolItem(
      title: 'Trim',
      subtitle: 'Shorten clips quickly',
      icon: Icons.content_cut_rounded,
      gradient: _G.trim,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        for (final item in tools)
          _SwipeStyleGradientRow(
            gradient: item.gradient,
            foreground: Colors.white,
            label: item.title,
            icon: item.icon,
            onTap: () {
              switch (item.title) {
                case 'Colorize':
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const ColorizeHomeScreen(),
                  //   ),
                  // );
                  break;

                case 'Compress':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompressHomeScreen(),
                    ),
                  );
                  break;

                case 'Enhance':
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const EnhanceHomeScreen(),
                  //   ),
                  // );
                  break;

                case 'Remove BG':
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const RemoveBgHomeScreen(),
                  //   ),
                  // );
                  break;

                case 'Split':
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const SplitHomeScreen(),
                  //   ),
                  // );
                  break;

                case 'Trim':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TrimHomeScreen(),
                    ),
                  );
                  break;
              }
            },
          ),
      ],
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
}

class _SwipeStyleGradientRow extends StatelessWidget {
  const _SwipeStyleGradientRow({
    required this.gradient,
    required this.foreground,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final Gradient gradient;
  final Color foreground;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  static const double _rowHeight = 82;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: InkWell(
          onTap: onTap,
          splashColor:
              foreground.withOpacity(0.14),
          highlightColor:
              foreground.withOpacity(0.06),
          child: SizedBox(
            height: _rowHeight,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 22,
                right: 18,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: -0.35,
                          color: foreground,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    icon,
                    color: foreground,
                    size: 34,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _G {
  static const LinearGradient colorize =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF9966),
      Color(0xFFFF5E62),
    ],
  );

  static const LinearGradient compress =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF00C9FF),
      Color(0xFF92FE9D),
    ],
  );

  static const LinearGradient enhance =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
  );

  static const LinearGradient removeBg =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF4FACFE),
      Color(0xFF00F2FE),
    ],
  );

  static const LinearGradient split =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF43E97B),
      Color(0xFF38F9D7),
    ],
  );

  static const LinearGradient trim =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF5F6D),
      Color(0xFFFFC371),
    ],
  );
}