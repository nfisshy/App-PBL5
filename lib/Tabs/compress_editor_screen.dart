import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../Cubit/compress_editor_cubit.dart';
import '../Items/media_item.dart';
import '../State/compress_editor_state.dart';

class CompressEditorScreen extends StatelessWidget {
  const CompressEditorScreen({super.key, required this.mediaItem});

  final MediaItem mediaItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompressEditorCubit(mediaItem)..loadVideo(),
      child: const _CompressEditorBody(),
    );
  }
}

class _CompressEditorBody extends StatefulWidget {
  const _CompressEditorBody();

  @override
  State<_CompressEditorBody> createState() => _CompressEditorBodyState();
}

class _CompressEditorBodyState extends State<_CompressEditorBody> {
  // local UI state for sliders to avoid heavy rebuilds
  double _resolutionValue = 1080; // options: 360,480,720,1080,2160
  double _fpsValue = 30; // options: 20,24,25,30,60
  double _bitrateValue = 10000; // in kbps, options mapped visually

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return "${h.toString().padLeft(2, '0')}:$m:$s";
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompressEditorCubit, CompressEditorState>(
      listenWhen: (prev, curr) => (!prev.compressSuccess && curr.compressSuccess) || (!prev.compressFail && curr.compressFail),
      listener: (context, state) {
        if (state.compressSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compressed saved to Photos ✓'), backgroundColor: Color(0xFF7DFFA7)));
          Navigator.of(context).pop();
        } else if (state.compressFail) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compress failed. Please try again.'), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        final cubit = context.read<CompressEditorCubit>();

        if (state.isLoading) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.black, title: const Text('compress')),
            body: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (state.loadFail) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.black, title: const Text('compress')),
            body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Failed to load video', style: TextStyle(color: Colors.white)), const SizedBox(height: 12), TextButton(onPressed: cubit.loadVideo, child: const Text('Retry'))])),
          );
        }

        final ctrl = cubit.videoController!;
        final total = state.duration;

        // default local values synced to state
        _resolutionValue = state.resolution.toDouble();
        _fpsValue = state.fps.toDouble();
        _bitrateValue = state.bitrateKbps.toDouble();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.arrow_back_ios_new_rounded)),
            ),
            title: const Text('compress', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: Column(
            children: [
              // video preview
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 320,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: VideoPlayer(ctrl),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // mode pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: const Text('AUTOMATIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24, width: 4)),
                        alignment: Alignment.center,
                        child: const Text('MANUAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // sliders
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resolution', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Slider(
                        value: _resolutionValue,
                        min: 360,
                        max: 2160,
                        divisions: 4,
                        label: _resolutionValue.toInt().toString() + 'p',
                        onChanged: (v) => setState(() => _resolutionValue = v.roundToDouble()),
                        onChangeEnd: (v) => cubit.setResolution(v.toInt()),
                      ),

                      const SizedBox(height: 6),
                      const Text('FPS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Slider(
                        value: _fpsValue,
                        min: 20,
                        max: 60,
                        divisions: 4,
                        label: _fpsValue.toInt().toString() + 'fps',
                        onChanged: (v) => setState(() => _fpsValue = v.roundToDouble()),
                        onChangeEnd: (v) => cubit.setFps(v.toInt()),
                      ),

                      const SizedBox(height: 6),
                      const Text('Bitrate', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Slider(
                        value: _bitrateValue,
                        min: 6500,
                        max: 12000,
                        divisions: 4,
                        label: '${(_bitrateValue / 1000).toStringAsFixed(1)} Mb/s',
                        onChanged: (v) => setState(() => _bitrateValue = v.roundToDouble()),
                        onChangeEnd: (v) => cubit.setBitrateKbps(v.toInt()),
                      ),

                      const Spacer(),

                      // compress button and size estimate
                      GestureDetector(
                        onTap: state.isCompressing ? null : () => cubit.compressVideo(),
                        child: Container(
                          width: double.infinity,
                          height: 90,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: state.isCompressing
                              ? const CircularProgressIndicator()
                              : const Text('COMPRESS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _estimateText(state, _bitrateValue.toInt()),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _estimateText(CompressEditorState state, int kbps) {
    final dur = state.duration.inSeconds;
    if (dur <= 0) return '';
    final bits = kbps * 1000 * dur; // kbps -> bps * seconds
    final bytes = bits / 8.0;
    final mb = bytes / (1024 * 1024);

    // original size approximate
    final orig = (state.duration.inMilliseconds <= 0) ? 0.0 : 0.0;

    return '${mb.toStringAsFixed(1)} MB estimated';
  }
}
