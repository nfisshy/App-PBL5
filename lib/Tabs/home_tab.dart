import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Cubit/photo_cubit.dart';
import '../State/photo_state.dart';

import 'duplicates.dart';
import 'photo_screen.dart';
import '../main.dart';
import 'recents_noti.dart';
import 'photo_delete_summary_screen.dart';
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with RouteAware {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    context.read<PhotoCubit>().loadRecentHomeStatus();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoCubit, PhotoState>(
      builder: (context, state) {
        return ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            /// =========================
            /// RECENTS
            /// =========================
            _SwipeStyleGradientRow(
              gradient: _G.recents,
              foreground: Colors.white,
              label: 'Recents',
              icon: Icons.access_time_rounded,

              count: state.recentUnreviewedCount > 0
                  ? state.recentUnreviewedCount
                  : null,

              isCompleted: state.recentCompleted,
              showTrash: state.hasPendingSummary,

onTap: () {
    if (state.recentUnreviewedCount > 0) {
    _openSession(context, PhotoSessionType.recent);
    return;
  }
if (state.hasPendingSummary) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<PhotoCubit>(),
        child: PhotoDeleteSummaryScreen(
          sessionTitle: 'Recents',
        ),
      ),
    ),
  );
  return;
}



  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const RecentsScreen(),
    ),
  );
},
            ),

            /// =========================
            /// RANDOM
            /// =========================
            _SwipeStyleGradientRow(
              gradient: _G.random,
              foreground: Colors.white,
              label: 'Random',
              icon: Icons.shuffle_rounded,
              onTap: () {
                _openSession(context, PhotoSessionType.random);
              },
            ),

            /// =========================
            /// DUPLICATES
            /// =========================
            _SwipeStyleGradientRow(
              gradient: _G.duplicates,
              foreground: Colors.white,
              label: 'Duplicates',
              icon: Icons.photo_library_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DuplicatesScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _openSession(BuildContext context, PhotoSessionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoScreen(
          sessionTitle: _getSessionTitle(type),
          onLoad: (cubit) async {
            await cubit.loadSession(type);
          },
        ),
      ),
    );
  }

  String _getSessionTitle(PhotoSessionType type) {
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

class _SwipeStyleGradientRow extends StatelessWidget {
  const _SwipeStyleGradientRow({
    required this.gradient,
    required this.foreground,
    required this.label,
    required this.icon,
    required this.onTap,
    this.count,
    this.isCompleted = false,
    this.showTrash = false,
  });

  final Gradient gradient;
  final Color foreground;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  final int? count;
  final bool isCompleted;
  final bool showTrash;

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
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Text(
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
                        if (isCompleted)
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (count != null) ...[
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
                        '$count',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  if (showTrash) ...[
                    const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 24,
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
  static const LinearGradient recents = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF00D2FF),
      Color(0xFF2563FF),
    ],
  );

  static const LinearGradient random = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF4F46E5),
      Color(0xFFC026FF),
    ],
  );

  static const LinearGradient duplicates = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF8A00),
      Color(0xFFFFD600),
    ],
  );
}