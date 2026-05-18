import 'package:flutter/material.dart';

import '../Cubit/photo_cubit.dart';
import 'duplicates.dart';
import 'photo_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_HomeCard> cards = [
      /// RECENTS
      _HomeCard(
        title: 'Recents',
        subtitle: 'Recent unprocessed photos',
        icon: Icons.access_time_rounded,
        gradient: _G.recents,
        badge: 'NEW',
        onOpen: () {
          _openSession(
            context,
            PhotoSessionType.recent,
          );
        },
      ),

      /// RANDOM
      _HomeCard(
        title: 'Random',
        subtitle: 'Shuffle your memories',
        icon: Icons.shuffle_rounded,
        gradient: _G.random,
        onOpen: () {
          _openSession(
            context,
            PhotoSessionType.random,
          );
        },
      ),

      /// DUPLICATES
      _HomeCard(
        title: 'Duplicates',
        subtitle: 'Clean up similar photos',
        icon: Icons.photo_library_outlined,
        gradient: _G.duplicates,
        onOpen: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const DuplicatesScreen(),
            ),
          );
        },
      ),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      physics:
          const BouncingScrollPhysics(),
      children: [
        for (final card in cards)
          _SwipeStyleGradientRow(
            gradient: card.gradient,
            foreground: Colors.white,
            label: card.title,
            icon: card.icon,
            badge: card.badge,
            onTap: card.onOpen,
          ),
      ],
    );
  }

  void _openSession(
    BuildContext context,
    PhotoSessionType type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoScreen(
          sessionTitle:
              _getSessionTitle(type),
          onLoad: (cubit) async {
            await cubit.loadSession(
              type,
            );
          },
        ),
      ),
    );
  }

  String _getSessionTitle(
    PhotoSessionType type,
  ) {
    switch (type) {
      case PhotoSessionType.anything:
        return "Anything";

      case PhotoSessionType.photos:
        return "Photos";

      case PhotoSessionType.videos:
        return "Videos";

      case PhotoSessionType.recent:
        return "Recents";

      case PhotoSessionType.random:
        return "Random";
      
      case PhotoSessionType.screenshots:  
        return "Screenshots";
      
      case PhotoSessionType.livePhotos:
        return "Live Photos";
    }
  }
}

class _HomeCard {
  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onOpen,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onOpen;
  final String? badge;
}

class _SwipeStyleGradientRow
    extends StatelessWidget {
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
        decoration:
            BoxDecoration(
          gradient: gradient,
        ),
        child: InkWell(
          onTap: onTap,
          splashColor:
              foreground.withOpacity(
            0.14,
          ),
          highlightColor:
              foreground.withOpacity(
            0.06,
          ),
          child: SizedBox(
            height: _rowHeight,
            width: double.infinity,
            child: Padding(
              padding:
                  const EdgeInsets.only(
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
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight
                                  .w900,
                          letterSpacing:
                              -0.35,
                          color:
                              foreground,
                        ),
                      ),
                    ),
                  ),

                  if (badge != null) ...[
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          100,
                        ),
                      ),
                      child: Text(
                        badge!,
                        style:
                            const TextStyle(
                          color:
                              Colors.black87,
                          fontWeight:
                              FontWeight
                                  .w800,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),
                  ],

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
  static const LinearGradient anything =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF111827),
      Color(0xFF374151),
    ],
  );

  static const LinearGradient photos =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF06B6D4),
      Color(0xFF2563EB),
    ],
  );

  static const LinearGradient videos =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFF97316),
    ],
  );

  static const LinearGradient recents =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF00D2FF),
      Color(0xFF2563FF),
    ],
  );

  static const LinearGradient random =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF4F46E5),
      Color(0xFFC026FF),
    ],
  );

  static const LinearGradient duplicates =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF8A00),
      Color(0xFFFFD600),
    ],
  );
}