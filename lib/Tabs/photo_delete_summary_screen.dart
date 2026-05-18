import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Cubit/photo_cubit.dart';
import '../Items/media_item.dart';
import '../State/photo_state.dart';
import 'photo_result_screen.dart';
/// Review screen after swipe session — real delete happens here only.
class PhotoDeleteSummaryScreen extends StatelessWidget {
  const PhotoDeleteSummaryScreen({
    super.key,
    required this.sessionTitle,
  });

  final String sessionTitle;

  static const Color _purple = Color(0xFFB57BFF);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / 390;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<PhotoCubit, PhotoState>(
          builder: (context, state) {
            final total = state.photos.length;
            final deleteCount = state.pendingDeletes.length;
            final progress = total == 0
                ? 0
                : (state.reviewedCount / total * 100).round();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    12 * scale,
                    8 * scale,
                    18 * scale,
                    4 * scale,
                  ),
                  child: Row(
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        scale: scale,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              sessionTitle.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26 * scale,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              '$total / $total • $progress%',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 58 * scale),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    22 * scale,
                    16 * scale,
                    22 * scale,
                    8 * scale,
                  ),
                  child: Text(
                    'DELETE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                Expanded(
                  child: deleteCount == 0
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24 * scale),
                            child: Text(
                              'You kept all photos in this session.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 17 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            14 * scale,
                            0,
                            14 * scale,
                            12 * scale,
                          ),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6 * scale,
                            mainAxisSpacing: 6 * scale,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: deleteCount,
                          itemBuilder: (context, index) {
                            final item = state.pendingDeletes[index];
                            return _DeleteGridTile(
                              item: item,
                              scale: scale,
                              onToggle: () {
                                context
                                    .read<PhotoCubit>()
                                    .togglePendingDelete(item.asset.id);
                              },
                            );
                          },
                        ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    22 * scale,
                    8 * scale,
                    22 * scale,
                    20 * scale,
                  ),
                  child: FilledButton(
                    onPressed: state.isDeleting
                        ? null
                        : deleteCount == 0
                            ? () => _popSwipeAndSummary(context)
                            : () => _onConfirmDelete(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: _purple,
                      disabledBackgroundColor:
                          _purple.withOpacity(0.35),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 18 * scale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: state.isDeleting
                        ? SizedBox(
                            height: 22 * scale,
                            width: 22 * scale,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            deleteCount == 0
                                ? 'Done'
                                : 'Delete $deleteCount Image${deleteCount == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _popSwipeAndSummary(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    if (navigator.canPop()) navigator.pop();
  }

Future<void> _onConfirmDelete(
  BuildContext context,
) async {
  final cubit =
      context.read<PhotoCubit>();

  /// =========================
  /// SNAPSHOT BEFORE DELETE
  /// =========================
  final pending =
      List.of(
        cubit.state.pendingDeletes,
      );

  final deleteCount =
      pending.length;

  final keepCount =
      cubit.state.photos.length -
      deleteCount;

  int savedBytes = 0;

  for (final item in pending) {
    savedBytes += item.fileSize;
  }

  /// =========================
  /// DELETE
  /// =========================
  final ok =
      await cubit
          .confirmDeletePending();

  if (!context.mounted) {
    return;
  }

  /// =========================
  /// SUCCESS
  /// =========================
  if (ok) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => SwipeResultScreen(
              sessionTitle:
                  sessionTitle,

              keepCount:
                  keepCount,

              deleteCount:
                  deleteCount,

              savedBytes:
                  savedBytes,
            ),
      ),
    );

    return;
  }

  /// =========================
  /// FAIL
  /// =========================
  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        'Could not delete photos. Please try again.',
      ),
    ),
  );
}

  Widget _circleButton({
    required IconData icon,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58 * scale,
        height: 58 * scale,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26 * scale,
        ),
      ),
    );
  }
}

class _DeleteGridTile extends StatelessWidget {
  const _DeleteGridTile({
    required this.item,
    required this.scale,
    required this.onToggle,
  });

  final MediaItem item;
  final double scale;
  final VoidCallback onToggle;

  static const Color _purple = Color(0xFFB57BFF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4 * scale),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _thumbnail(item.thumbnail),
            Positioned(
              right: 6 * scale,
              bottom: 6 * scale,
              child: Container(
                width: 28 * scale,
                height: 28 * scale,
                decoration: const BoxDecoration(
                  color: _purple,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 16 * scale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(Uint8List? bytes) {
    if (bytes == null) {
      return ColoredBox(
        color: Colors.grey.shade800,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white38,
          ),
        ),
      );
    }

    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      filterQuality: FilterQuality.low,
    );
  }
}
