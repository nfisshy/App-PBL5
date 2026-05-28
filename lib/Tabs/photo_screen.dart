import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../Cubit/photo_cubit.dart';
import '../Items/media_item.dart';
import '../State/photo_state.dart';
import 'photo_delete_summary_screen.dart';

class PhotoScreen extends StatelessWidget {
  const PhotoScreen({
    super.key,
    required this.onLoad,
    this.sessionTitle,
  });

  final Future<void> Function(PhotoCubit cubit) onLoad;
  final String? sessionTitle;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PhotoCubit>();

    return BlocProvider.value(
      value: cubit,
      child: _PhotoScreenBody(
        sessionTitle: sessionTitle,
        onLoad: onLoad,
      ),
    );
  }
}

class _PhotoScreenBody extends StatefulWidget {
  const _PhotoScreenBody({
    this.sessionTitle,
    required this.onLoad,
  });

  final String? sessionTitle;
  final Future<void> Function(PhotoCubit cubit) onLoad;

  @override
  State<_PhotoScreenBody> createState() => _PhotoScreenBodyState();
}

class _PhotoScreenBodyState extends State<_PhotoScreenBody> {
  double dragX = 0;
  final double swipeThreshold = 120;

  int _activePointers = 0;
  bool _isDragging = false;

  final GlobalKey<_MediaViewerState> _mediaKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (!mounted) return;
        await widget.onLoad(context.read<PhotoCubit>());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.width / 390;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocConsumer<PhotoCubit, PhotoState>(
          listenWhen: (prev, curr) =>
              !prev.isSessionComplete && curr.isSessionComplete,
          listener: (context, state) {
            final cubit = context.read<PhotoCubit>();
            final title = widget.sessionTitle ?? cubit.sessionTitle;

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: PhotoDeleteSummaryScreen(sessionTitle: title),
                ),
              ),
            );
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state.loadFail) {
              return const Center(
                child: Text(
                  "Failed to load photos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            if (state.photos.isEmpty) {
              return const Center(
                child: Text(
                  "No photos found",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            final currentPhoto = state.photos[state.currentIndex];
            final dragPercent =
                (dragX.abs() / swipeThreshold).clamp(0.0, 1.0);
            final isDraggingLeft = dragX < -20;
            final isDraggingRight = dragX > 20;
            final isVideo =
                currentPhoto.isVideo || currentPhoto.isLivePhoto;
            final isMuted = _mediaKey.currentState?.isMuted ?? false;
            final isPlaying = _mediaKey.currentState?.isPlaying ?? true;

            return Stack(
              children: [
                /// TOP BAR
                Positioned(
                  top: 10 * scale,
                  left: 18 * scale,
                  right: 18 * scale,
                  child: Row(
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        scale: scale,
                        opacity: 1,
                        onTap: () => Navigator.of(context).pop(),
                      ),

                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _timeAgo(currentPhoto.createdAt),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24 * scale,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              "${state.currentIndex + 1}/${state.totalCount} • ${(state.progress * 100).toInt()}%",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (state.deleteCount > 0)
                        Padding(
                          padding: EdgeInsets.only(right: 10 * scale),
                          child: _deleteCountPill(
                            count: state.deleteCount,
                            scale: scale,
                          ),
                        ),

                      _circleButton(
                        icon: Icons.refresh_rounded,
                        scale: scale,
                        opacity: state.hasAction ? 1 : 0.25,
                        onTap: () {
                          context.read<PhotoCubit>().undoAction();
                          setState(() => dragX = 0);
                        },
                      ),
                    ],
                  ),
                ),

                /// PHOTO CARD
                Center(
                  child: Listener(
                    onPointerDown: (_) {
                      _activePointers++;
                      if (_activePointers > 1) {
                        setState(() {
                          dragX = 0;
                          _isDragging = false;
                        });
                      }
                    },
                    onPointerUp: (_) {
                      _activePointers =
                          (_activePointers - 1).clamp(0, 99);
                      if (_activePointers == 0) {
                        if (_isDragging) {
                          if (dragX < -swipeThreshold) {
                            context.read<PhotoCubit>().deletePhoto();
                          } else if (dragX > swipeThreshold) {
                            context.read<PhotoCubit>().keepPhoto();
                          }
                          setState(() {
                            dragX = 0;
                            _isDragging = false;
                          });
                        }
                      }
                    },
                    onPointerCancel: (_) {
                      _activePointers =
                          (_activePointers - 1).clamp(0, 99);
                      setState(() {
                        dragX = 0;
                        _isDragging = false;
                      });
                    },
                    onPointerMove: (event) {
                      final isZoomed =
                          _mediaKey.currentState?.isZoomed ?? false;
                      if (_activePointers == 1 && !isZoomed) {
                        if (event.delta.dx.abs() > 0.5) {
                          setState(() {
                            dragX += event.delta.dx;
                            _isDragging = true;
                          });
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      transform: Matrix4.identity()
                        ..translate(dragX)
                        ..rotateZ(dragX * 0.0007),
                      width: size.width * 0.97,
                      height: size.height * 0.7,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(34 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(34 * scale),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _MediaViewer(
                              key: _mediaKey,
                              item: currentPhoto,
                              onMuteChanged: () => setState(() {}),
                              onPlayStateChanged: () => setState(() {}),
                            ),

                            if (dragPercent > 0)
                              BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: dragPercent * 4,
                                  sigmaY: dragPercent * 4,
                                ),
                                child: Container(
                                  color: Colors.black
                                      .withOpacity(dragPercent * 0.2),
                                ),
                              ),

                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.22),
                                  ],
                                ),
                              ),
                            ),

                            if (isDraggingLeft)
                              Positioned(
                                top: 50 * scale,
                                left: 28 * scale,
                                child: Transform.rotate(
                                  angle: -0.18,
                                  child: _actionOverlay(
                                    text: "DELETE",
                                    color: const Color(0xFFB57BFF),
                                    scale: scale,
                                  ),
                                ),
                              ),

                            if (isDraggingRight)
                              Positioned(
                                top: 50 * scale,
                                right: 28 * scale,
                                child: Transform.rotate(
                                  angle: 0.18,
                                  child: _actionOverlay(
                                    text: "KEEP",
                                    color: const Color(0xFF7DFFA7),
                                    scale: scale,
                                  ),
                                ),
                              ),

                            if (isVideo)
                              Positioned(
                                left: 14 * scale,
                                right: 14 * scale,
                                bottom: 76 * scale,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _mediaKey
                                          .currentState
                                          ?.togglePlayPause(),
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withOpacity(0.45),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white
                                                .withOpacity(0.08),
                                          ),
                                        ),
                                        child: Icon(
                                          isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// RIGHT ICONS
                Positioned(
                  right: 16 * scale,
                  bottom: 210 * scale,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: dragPercent > 0 ? 0 : 1,
                    child: Column(
                      children: [
                        _sideIcon(Icons.favorite_border_rounded, scale),
                        SizedBox(height: 14 * scale),
                        _sideIcon(Icons.bookmark_border_rounded, scale),
                        SizedBox(height: 14 * scale),
                        _sideIcon(Icons.ios_share_rounded, scale),
                        SizedBox(height: 14 * scale),
                        _sideIcon(Icons.auto_awesome_rounded, scale),
                        if (isVideo) ...[
                          SizedBox(height: 14 * scale),
                          GestureDetector(
                            onTap: () =>
                                _mediaKey.currentState?.toggleMute(),
                            child: _sideIcon(
                              isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              scale,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                /// BOTTOM — DELETE/KEEP labels + counts + progress bar
                Positioned(
                  bottom: 30 * scale,
                  left: 26 * scale,
                  right: 26 * scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Labels + counts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "DELETE",
                                style: TextStyle(
                                  color: const Color(0xFFB57BFF),
                                  fontSize: 28 * scale,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Text(
                                state.deleteCount.toString(),
                                style: TextStyle(
                                  color: const Color(0xFFB57BFF),
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "KEEP",
                                style: TextStyle(
                                  color: const Color(0xFF7DFFA7),
                                  fontSize: 28 * scale,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Text(
                                state.keepCount.toString(),
                                style: TextStyle(
                                  color: const Color(0xFF7DFFA7),
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 16 * scale),

                      /// Progress bar
                      _ProgressBar(
                        progress: state.progress,
                        deleteRatio: state.totalCount > 0
                            ? state.deleteCount / state.totalCount
                            : 0.0,
                        keepRatio: state.totalCount > 0
                            ? state.keepCount / state.totalCount
                            : 0.0,
                        scale: scale,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  Widget _deleteCountPill({required int count, required double scale}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFB57BFF).withOpacity(0.22),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFFB57BFF).withOpacity(0.55),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: const Color(0xFFB57BFF),
            size: 20 * scale,
          ),
          SizedBox(width: 6 * scale),
          Text(
            '$count',
            style: TextStyle(
              color: const Color(0xFFB57BFF),
              fontSize: 16 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required double scale,
    required double opacity,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: opacity,
        child: Container(
          width: 58 * scale,
          height: 58 * scale,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Icon(icon, color: Colors.white, size: 26 * scale),
        ),
      ),
    );
  }

  Widget _sideIcon(IconData icon, double scale) {
    return Container(
      width: 48 * scale,
      height: 48 * scale,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 24 * scale),
    );
  }

  Widget _actionOverlay({
    required String text,
    required Color color,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 4),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 34 * scale,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// =========================
/// PROGRESS BAR WIDGET
/// Thanh nửa tím (delete) nửa xanh (keep)
/// =========================

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.deleteRatio,
    required this.keepRatio,
    required this.scale,
  });

  final double progress;    // tổng progress (0.0 → 1.0)
  final double deleteRatio; // phần delete / totalCount
  final double keepRatio;   // phần keep / totalCount
  final double scale;

  @override
  Widget build(BuildContext context) {
    final barHeight = 6.0 * scale;
    final borderRadius = BorderRadius.circular(100);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final filledWidth = totalWidth * progress;
        final deleteWidth = totalWidth * deleteRatio;
        final keepWidth = totalWidth * keepRatio;

        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: borderRadius,
          ),
          child: Stack(
            children: [
              // Delete portion (tím) — từ trái
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: deleteWidth,
                height: barHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFB57BFF),
                  borderRadius: borderRadius,
                ),
              ),

              // Keep portion (xanh) — từ phải
              Positioned(
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  width: keepWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DFFA7),
                    borderRadius: borderRadius,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── _MediaViewer (không đổi) ──────────────────────────────────────────────

class _MediaViewer extends StatefulWidget {
  const _MediaViewer({
    super.key,
    required this.item,
    this.onMuteChanged,
    this.onPlayStateChanged,
  });

  final MediaItem item;
  final VoidCallback? onMuteChanged;
  final VoidCallback? onPlayStateChanged;

  @override
  State<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<_MediaViewer> {
  VideoPlayerController? _controller;
  bool isMuted = false;

  bool get isPlaying => _controller?.value.isPlaying ?? false;

  final TransformationController _transformCtrl = TransformationController();
  TapDownDetails? _doubleTapDetails;

  bool get isZoomed =>
      _transformCtrl.value.getMaxScaleOnAxis() > 1.01;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _transformCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(_MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.asset.id != widget.item.asset.id) {
      _controller?.dispose();
      _controller = null;
      _transformCtrl.value = Matrix4.identity();
      isMuted = false;
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    if (!widget.item.isVideo && !widget.item.isLivePhoto) return;

    final File? file = await widget.item.asset.file;
    if (file == null) return;

    final ctrl = VideoPlayerController.file(file);
    await ctrl.initialize();
    ctrl
      ..setLooping(true)
      ..play();

    ctrl.addListener(() {
      if (mounted) setState(() {});
    });

    if (mounted) {
      setState(() => _controller = ctrl);
      widget.onPlayStateChanged?.call();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  void toggleMute() {
    if (_controller == null) return;
    setState(() => isMuted = !isMuted);
    _controller!.setVolume(isMuted ? 0 : 1);
    widget.onMuteChanged?.call();
  }

  void togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
    widget.onPlayStateChanged?.call();
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;
    final pos = _doubleTapDetails!.localPosition;
    const zoom = 2.5;
    if (_transformCtrl.value.getMaxScaleOnAxis() > 1) {
      _transformCtrl.value = Matrix4.identity();
    } else {
      _transformCtrl.value = Matrix4.identity()
        ..translate(-pos.dx * (zoom - 1), -pos.dy * (zoom - 1))
        ..scale(zoom);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.item.isVideo || widget.item.isLivePhoto;

    if (isVideo &&
        _controller != null &&
        _controller!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTapDown: (d) => _doubleTapDetails = d,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformCtrl,
              minScale: 1,
              maxScale: 4,
              panEnabled: isZoomed,
              scaleEnabled: true,
              clipBehavior: Clip.none,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          ),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _controller!.value.isPlaying ? 0 : 1,
            child: Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 54,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                  bottom: 18,
                  top: 30,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.72),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 54),
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white10,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _fmt(_controller!.value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          " / ",
                          style: TextStyle(color: Colors.white54),
                        ),
                        Text(
                          _fmt(_controller!.value.duration),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.item.thumbnail == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.white54,
            size: 70,
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTapDown: (d) => _doubleTapDetails = d,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        minScale: 1,
        maxScale: 4,
        panEnabled: isZoomed,
        scaleEnabled: true,
        clipBehavior: Clip.none,
        child: SizedBox.expand(
          child: Image.memory(
            widget.item.thumbnail!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}