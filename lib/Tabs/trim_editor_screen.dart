import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../Cubit/trim_editor_cubit.dart';
import '../Items/media_item.dart';
import '../State/trim_editor_state.dart';

class TrimEditorScreen extends StatelessWidget {
  const TrimEditorScreen({
    super.key,
    required this.mediaItem,
  });

  final MediaItem mediaItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Cubit tạo mới, nhận mediaItem, load video ngay
      create: (_) => TrimEditorCubit(mediaItem)..loadVideo(),
      child: const _TrimEditorBody(),
    );
  }
}

class _TrimEditorBody extends StatefulWidget {
  const _TrimEditorBody();

  @override
  State<_TrimEditorBody> createState() => _TrimEditorBodyState();
}

class _TrimEditorBodyState extends State<_TrimEditorBody> {
  RangeValues _localRange = const RangeValues(0, 1);
  DateTime _lastSeek = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _seekThrottle = Duration(milliseconds: 80);

  void _throttledSeek(TrimEditorCubit cubit, double normalized) {
    final now = DateTime.now();
    if (now.difference(_lastSeek) < _seekThrottle) return;
    _lastSeek = now;

    final ctrl = cubit.videoController;
    if (ctrl != null && ctrl.value.isInitialized) {
      try {
        final ms = (ctrl.value.duration.inMilliseconds * normalized).toInt();
        ctrl.seekTo(Duration(milliseconds: ms));
        if (ctrl.value.isPlaying) ctrl.pause();
      } catch (_) {}
    }
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return "${h.toString().padLeft(2, '0')}:$m:$s";
    return "$m:$s";
  }

  @override
  void initState() {
    super.initState();

    // Initialize local range from cubit after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<TrimEditorCubit>();
      setState(() {
        _localRange = RangeValues(cubit.startTrim, cubit.endTrim);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrimEditorCubit, TrimEditorState>(
      listenWhen: (prev, curr) =>
          (!prev.trimSuccess && curr.trimSuccess) ||
          (!prev.trimFail && curr.trimFail),
      listener: (context, state) {
        if (state.trimSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Trimmed video saved to Photos ✓"),
              backgroundColor: Color(0xFF7DFFA7),
            ),
          );
          Navigator.of(context).pop();
        } else if (state.trimFail) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Trim failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<TrimEditorCubit>();

        // ─── LOADING ────────────────────────────────────────────
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: const Text("Trim"),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // ─── FAIL ───────────────────────────────────────────────
        if (state.loadFail) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: const Text("Trim"),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Failed to load video",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: cubit.loadVideo,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        // ─── EDITOR ─────────────────────────────────────────────
        final ctrl = cubit.videoController!;
        final total = state.duration;

        // use local range for responsive UI during drag
        final startTrim = _localRange.start;
        final endTrim = _localRange.end;

        final startDuration = Duration(
          milliseconds: (total.inMilliseconds * startTrim).toInt(),
        );
        final endDuration = Duration(
          milliseconds: (total.inMilliseconds * endTrim).toInt(),
        );
        final trimDuration = endDuration - startDuration;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: const Text(
              "Trim",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              // Trim button ở AppBar
              if (state.isTrimming)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: cubit.trimVideo,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Color(0xFF7DFFA7),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // ─── VIDEO PLAYER ──────────────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: cubit.togglePlay,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: ctrl.value.aspectRatio,
                          child: VideoPlayer(ctrl),
                        ),
                      ),

                      // Play/pause overlay
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: state.isPlaying ? 0 : 1,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── TRIM CONTROLS (custom frame strip + handles) ─────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                color: Colors.black,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time labels row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "START",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmt(startDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            const Text(
                              "DURATION",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmt(trimDuration),
                              style: const TextStyle(
                                color: Color(0xFF7DFFA7),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "END",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmt(endDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Frame strip (visual only) — use media thumbnail repeated
                    Container(
                      height: 84,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final thumb = cubit.mediaItem.thumbnail;
                            // number of thumbs to show
                            final count = 28;
                            final thumbWidth = (constraints.maxWidth - (count - 1) * 4) / count;

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: List.generate(count, (i) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: thumb != null
                                            ? Image.memory(
                                                thumb,
                                                width: thumbWidth,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                gaplessPlayback: true,
                                              )
                                            : Container(color: Colors.white10, width: thumbWidth),
                                      );
                                    }),
                                  ),
                                ),

                                // Selection overlay with draggable handles
                                Positioned.fill(
                                  child: LayoutBuilder(
                                    builder: (ctx, box) {
                                      final totalW = box.maxWidth;
                                      final leftX = _localRange.start * totalW;
                                      final rightX = _localRange.end * totalW;
                                      const handleWidth = 36.0;

                                      return Stack(
                                        children: [
                                          // translucent selection area
                                          Positioned(
                                            left: leftX + handleWidth / 2,
                                            right: (totalW - rightX) + handleWidth / 2,
                                            top: 0,
                                            bottom: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: Colors.black.withOpacity(0.25),
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                            ),
                                          ),

                                          // left handle
                                          Positioned(
                                            left: (leftX).clamp(0.0, totalW - handleWidth),
                                            top: 0,
                                            bottom: 0,
                                            width: handleWidth,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onHorizontalDragUpdate: (details) {
                                                final dx = details.delta.dx;
                                                final deltaNorm = dx / totalW;
                                                double newStart = (_localRange.start + deltaNorm).clamp(0.0, _localRange.end - 0.01);
                                                setState(() => _localRange = RangeValues(newStart, _localRange.end));
                                                // seek preview directly but throttled
                                                _throttledSeek(cubit, newStart);
                                              },
                                              onHorizontalDragEnd: (_) {
                                                // persist to cubit (no await, updateTrim is sync)
                                                cubit.updateTrim(start: _localRange.start, end: _localRange.end);
                                              },
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  width: 22,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Icon(Icons.chevron_left_rounded, color: Colors.black, size: 20),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // right handle
                                          Positioned(
                                            left: (rightX - handleWidth).clamp(0.0, totalW - handleWidth),
                                            top: 0,
                                            bottom: 0,
                                            width: handleWidth,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onHorizontalDragUpdate: (details) {
                                                final dx = details.delta.dx;
                                                final deltaNorm = dx / totalW;
                                                double newEnd = (_localRange.end + deltaNorm).clamp(_localRange.start + 0.01, 1.0);
                                                setState(() => _localRange = RangeValues(_localRange.start, newEnd));
                                                _throttledSeek(cubit, newEnd);
                                              },
                                              onHorizontalDragEnd: (_) {
                                                cubit.updateTrim(start: _localRange.start, end: _localRange.end);
                                              },
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                child: Container(
                                                  width: 22,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Custom range control: use RangeSlider visuals but only update local state on drag,
                    // apply changes on drag end to avoid heavy seeks/emits.
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF7DFFA7),
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white12,
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 14,
                        ),
                        trackHeight: 4,
                      ),
                      child: RangeSlider(
                        values: _localRange,
                        min: 0,
                        max: 1,
                        onChanged: (values) {
                          // update local UI only
                          setState(() => _localRange = values);
                          // seek preview a bit while dragging slider as well
                          _throttledSeek(cubit, values.start);
                        },
                        onChangeEnd: (values) {
                          cubit.updateTrim(start: values.start, end: values.end);
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Total duration hint
                    Text(
                      "Total: ${_fmt(total)}",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom row buttons: RESET and TRIM
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _localRange = const RangeValues(0, 1);
                              });
                              // also reset cubit values
                              cubit.updateTrim(start: 0, end: 1);
                            },
                            child: Container(
                              height: 64,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B3EA6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'RESET',
                                style: TextStyle(
                                  color: Color(0xFFDCC9FF),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!state.isTrimming) cubit.trimVideo();
                            },
                            child: Container(
                              height: 64,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C7A52),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'TRIM',
                                style: TextStyle(
                                  color: Color(0xFFBFF0D8),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
