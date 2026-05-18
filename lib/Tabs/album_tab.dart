import 'package:flutter/material.dart';

import '../Cubit/photo_cubit.dart';
import 'photo_screen.dart';
import 'place_screen.dart';
import 'map_screen.dart';
class AlbumTab extends StatelessWidget {
  const AlbumTab({super.key});

  static final List<_AlbumItem> albums = [
    _AlbumItem(
      title: 'Anything',
      subtitle: 'Everything in your library',
      icon: Icons.auto_awesome_rounded,
      gradient: _G.anything,
      badge: 'ALL',
      sessionType: PhotoSessionType.anything,
    ),

    _AlbumItem(
      title: 'Videos',
      subtitle: 'Your saved moments',
      icon: Icons.videocam_rounded,
      gradient: _G.videos,
      sessionType: PhotoSessionType.videos,
    ),

    _AlbumItem(
      title: 'Photos',
      subtitle: 'Captured memories',
      icon: Icons.photo_rounded,
      gradient: _G.photos,
      sessionType: PhotoSessionType.photos,
    ),

    _AlbumItem(
      title: 'Live Photos',
      subtitle: 'Moving snapshots',
      icon: Icons.motion_photos_on_rounded,
      gradient: _G.livePhotos,
      sessionType: PhotoSessionType.livePhotos,
    ),

    _AlbumItem(
      title: 'Screenshots',
      subtitle: 'Saved screen captures',
      icon: Icons.screenshot_monitor_rounded,
      gradient: _G.screenshots,
      sessionType: PhotoSessionType.screenshots,
    ),

    _AlbumItem(
      title: 'Places',
      subtitle: 'Photos by location',
      icon: Icons.place_rounded,
      gradient: _G.places,
      customOnTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PlacesScreen(),
          ),
        );
      },
    ),

    _AlbumItem(
      title: 'World Map',
      subtitle: 'Explore your journeys',
      icon: Icons.public_rounded,
      gradient: _G.worldMap,

      customOnTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WorldMapScreen(),
          ),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        for (final item in albums)
          _SwipeStyleGradientRow(
            gradient: item.gradient,
            foreground: Colors.white,
            label: item.title,
            icon: item.icon,
            badge: item.badge,
            onTap: () {
              /// CUSTOM PAGE
              if (item.customOnTap != null) {
                item.customOnTap!(context);
                return;
              }

              /// NORMAL PHOTO SESSION
              _openSession(
                context,
                item.sessionType!,
                item.title,
              );
            },
          ),
      ],
    );
  }

  void _openSession(
    BuildContext context,
    PhotoSessionType type,
    String title,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoScreen(
          sessionTitle: title,
          onLoad: (cubit) async {
            await cubit.loadSession(type);
          },
        ),
      ),
    );
  }
}

class _AlbumItem {
  const _AlbumItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.sessionType,
    this.badge,
    this.customOnTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;

  final PhotoSessionType? sessionType;

  final void Function(BuildContext context)?
      customOnTap;

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
            BoxDecoration(gradient: gradient),
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
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing:
                              -0.35,
                          color: foreground,
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
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          100,
                        ),
                      ),
                      child: Text(
                        badge!,
                        style:
                            const TextStyle(
                          color: Colors.black87,
                          fontWeight:
                              FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),
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
      Color(0xFF00D2FF),
      Color(0xFF2563FF),
    ],
  );

  static const LinearGradient videos =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF5F6D),
      Color(0xFFFFC371),
    ],
  );

  static const LinearGradient photos =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF4FACFE),
      Color(0xFF00F2FE),
    ],
  );

  static const LinearGradient livePhotos =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF43E97B),
      Color(0xFF38F9D7),
    ],
  );

  static const LinearGradient screenshots =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF9966),
      Color(0xFFFF5E62),
    ],
  );

  static const LinearGradient places =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
  );

  static const LinearGradient worldMap =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF11998E),
      Color(0xFF38EF7D),
    ],
  );
}