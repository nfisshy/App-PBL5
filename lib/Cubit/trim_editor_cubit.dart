import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../Items/media_item.dart';
import '../State/trim_editor_state.dart';

class TrimEditorCubit extends Cubit<TrimEditorState> {
  TrimEditorCubit(this.mediaItem)
      : super(const TrimEditorState(isLoading: true));

  final MediaItem mediaItem;

  VideoPlayerController? videoController;

  double startTrim = 0;
  double endTrim = 1;

  // ─── LOAD VIDEO ───────────────────────────────────────────────
  Future<void> loadVideo() async {
    emit(const TrimEditorState(isLoading: true));

    try {
      final file = await mediaItem.asset.file;

      if (file == null) {
        emit(const TrimEditorState(isLoading: false, loadFail: true));
        return;
      }

      final ctrl = VideoPlayerController.file(File(file.path));
      await ctrl.initialize();

      // Không autoplay — user chủ động bấm play
      ctrl.addListener(_onControllerUpdate);

      videoController = ctrl;

      emit(
        TrimEditorState(
          isLoading: false,
          loadSuccess: true,
          duration: ctrl.value.duration,
        ),
      );
    } catch (e) {
      debugPrint("LOAD VIDEO ERROR: $e");
      emit(const TrimEditorState(isLoading: false, loadFail: true));
    }
  }

  void _onControllerUpdate() {
    if (isClosed) return;
    emit(state.copyWith(isPlaying: videoController?.value.isPlaying ?? false));
  }

  // ─── PLAY / PAUSE ─────────────────────────────────────────────
  void togglePlay() {
    final ctrl = videoController;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      // Nếu position vượt qua endTrim thì seek về startTrim
      final total = ctrl.value.duration.inMilliseconds;
      final startMs = (total * startTrim).toInt();
      final endMs = (total * endTrim).toInt();
      final currentMs = ctrl.value.position.inMilliseconds;

      if (currentMs >= endMs || currentMs < startMs) {
        ctrl.seekTo(Duration(milliseconds: startMs));
      }

      ctrl.play();
    }

    emit(state.copyWith(isPlaying: ctrl.value.isPlaying));
  }

  // ─── UPDATE TRIM ──────────────────────────────────────────────
  void updateTrim({required double start, required double end}) {
    startTrim = start;
    endTrim = end;

    // Seek video đến vị trí startTrim để preview
    final ctrl = videoController;
    if (ctrl != null && ctrl.value.isInitialized) {
      final ms = (ctrl.value.duration.inMilliseconds * start).toInt();
      ctrl.seekTo(Duration(milliseconds: ms));
      if (ctrl.value.isPlaying) ctrl.pause();
    }

    emit(state.copyWith());
  }

  // ─── TRIM VIDEO ───────────────────────────────────────────────
  Future<void> trimVideo() async {
    final ctrl = videoController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state.isTrimming) return;

    emit(state.copyWith(isTrimming: true, trimSuccess: false, trimFail: false));

    try {
      final file = await mediaItem.asset.file;
      if (file == null) {
        emit(state.copyWith(isTrimming: false, trimFail: true));
        return;
      }

      final total = ctrl.value.duration.inMilliseconds;
      final startMs = (total * startTrim).toInt();
      final endMs = (total * endTrim).toInt();
      final trimDurationMs = endMs - startMs;

      if (trimDurationMs <= 0) {
        emit(state.copyWith(isTrimming: false, trimFail: true));
        return;
      }

      final outputDir = await getTemporaryDirectory();
      final outputPath =
          "${outputDir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4";

      final startSec = (startMs / 1000).toStringAsFixed(3);
      final durationSec = (trimDurationMs / 1000).toStringAsFixed(3);

      // -ss trước -i → seek nhanh hơn (input seeking thay vì output seeking)
      // -c copy → không re-encode, nhanh nhất có thể
      final command =
          '-y -ss $startSec -i "${file.path}" -t $durationSec -c copy "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // Lưu vào Photos
        await PhotoManager.editor.saveVideo(
          File(outputPath),
          title: "trimmed_${DateTime.now().millisecondsSinceEpoch}",
        );

        emit(state.copyWith(isTrimming: false, trimSuccess: true));
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint("TRIM FAILED: $logs");
        emit(state.copyWith(isTrimming: false, trimFail: true));
      }
    } catch (e) {
      debugPrint("TRIM VIDEO ERROR: $e");
      emit(state.copyWith(isTrimming: false, trimFail: true));
    }
  }

  @override
  Future<void> close() async {
    videoController?.removeListener(_onControllerUpdate);
    await videoController?.dispose();
    videoController = null;
    return super.close();
  }
}
