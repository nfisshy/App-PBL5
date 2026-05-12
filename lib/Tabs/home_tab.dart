import 'package:flutter/material.dart';
import 'photo_screen.dart';
import 'duplicates.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  final List<_HomeCard> cards = const [
    _HomeCard(
      title: 'Recents',
      subtitle: '9 new photos',
      icon: Icons.access_time_rounded,
      gradient: _G.recents,
      badge: '9',
      routeType: _HomeCardRoute.photo,
    ),
    _HomeCard(
      title: 'Random',
      subtitle: 'Shuffle your memories',
      icon: Icons.shuffle_rounded,
      gradient: _G.random,
      routeType: _HomeCardRoute.photo,
    ),
    _HomeCard(
      title: 'Duplicates',
      subtitle: 'Clean up similar photos',
      icon: Icons.photo_library_outlined,
      gradient: _G.duplicates,
      routeType: _HomeCardRoute.duplicates,
    ),
    _HomeCard(
      title: "APR '26",
      subtitle: '1,246',
      icon: Icons.calendar_month_rounded,
      gradient: _G.apr,
      badge: '1,246',
      routeType: _HomeCardRoute.photo,
    ),
    _HomeCard(
      title: "MAR '26",
      subtitle: '842',
      icon: Icons.calendar_month_rounded,
      gradient: _G.mar,
      badge: '842',
      routeType: _HomeCardRoute.photo,
    ),
    _HomeCard(
      title: "FEB '26",
      subtitle: '623',
      icon: Icons.calendar_month_rounded,
      gradient: _G.feb,
      badge: '623',
      routeType: _HomeCardRoute.photo,
    ),
    _HomeCard(
      title: "JAN '26",
      subtitle: '511',
      icon: Icons.calendar_month_rounded,
      gradient: _G.jan,
      badge: '511',
      routeType: _HomeCardRoute.photo,
    ),
    _HomeCard(
      title: "DEC '25",
      subtitle: '328',
      icon: Icons.calendar_month_rounded,
      gradient: _G.dec,
      badge: '328',
      routeType: _HomeCardRoute.photo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        for (final card in cards)
          _SwipeStyleGradientRow(
            gradient: card.gradient,
            foreground: Colors.white,
            label: card.title,
            icon: card.icon,
            onTap: () => _openCard(context, card.routeType),
            badge: card.badge,
          ),
      ],
    );
  }
}

void _openCard(BuildContext context, _HomeCardRoute routeType) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) {
        switch (routeType) {
          case _HomeCardRoute.duplicates:
            return const DuplicatesScreen();
          case _HomeCardRoute.photo:
            return const PhotoScreen();
        }
      },
    ),
  );
}

class _HomeCard {
  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.routeType,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final _HomeCardRoute routeType;
  final String? badge;
}

enum _HomeCardRoute { photo, duplicates }

class _SwipeStyleGradientRow extends StatelessWidget {
  const _SwipeStyleGradientRow({
    required this.gradient,
    required this.foreground,
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final Gradient gradient;
  final Color foreground;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  static const double _rowHeight = 82;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(gradient: gradient),
        child: InkWell(
          onTap: onTap,
          splashColor: foreground.withOpacity(0.14),
          highlightColor: foreground.withOpacity(0.06),
          child: SizedBox(
            height: _rowHeight,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 22, right: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.35,
                          color: foreground,
                        ),
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Icon(icon, color: foreground, size: 34),
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
  static const LinearGradient recents = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00D2FF), Color(0xFF2563FF)],
  );
  static const LinearGradient random = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4F46E5), Color(0xFFC026FF)],
  );
  static const LinearGradient duplicates = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF8A00), Color(0xFFFFD600)],
  );
  static const LinearGradient apr = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF4DA6), Color(0xFFE11D48)],
  );
  static const LinearGradient mar = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00B86B), Color(0xFF0F766E)],
  );
  static const LinearGradient feb = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF5B6E), Color(0xFFF97316)],
  );
  static const LinearGradient jan = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5C7CFA), Color(0xFF1C4ED8)],
  );
  static const LinearGradient dec = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1C4ED8), Color(0xFF0F172A)],
  );
}