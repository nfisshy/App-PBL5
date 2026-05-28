import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../State/compress_editor_state.dart';
import '../Items/media_item.dart';

class CompressEditorCubit extends Cubit<CompressEditorState> {
  CompressEditorCubit(this.mediaItem)
      : super(const CompressEditorState(isLoading: true));

  final MediaItem mediaItem;
  VideoPlayerController? videoController;

  Future<void> loadVideo() async {
    emit(const CompressEditorState(isLoading: true));

    try {
      final file = await mediaItem.asset.file;
      if (file == null) {
        emit(const CompressEditorState(isLoading: false, loadFail: true));
        return;
      }

      final ctrl = VideoPlayerController.file(File(file.path));
      await ctrl.initialize();
      ctrl.addListener(_onControllerUpdate);
      videoController = ctrl;

      emit(
        CompressEditorState(
          isLoading: false,
          loadSuccess: true,
          duration: ctrl.value.duration,
        ),
      );
    } catch (e) {
      emit(const CompressEditorState(isLoading: false, loadFail: true));
    }
  }

  void _onControllerUpdate() {
    if (isClosed) return;
    // only emit playing state if changed to reduce frequency
    final playing = videoController?.value.isPlaying ?? false;
    emit(state.copyWith(isLoading: false, duration: videoController?.value.duration ?? state.duration,));
  }

  void togglePlay() {
    final ctrl = videoController;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      ctrl.play();
    }

    emit(state.copyWith());
  }

  void setResolution(int heightPx) {
    emit(state.copyWith(resolution: heightPx));
  }

  void setFps(int fps) {
    emit(state.copyWith(fps: fps));
  }

  void setBitrateKbps(int kbps) {
    emit(state.copyWith(bitrateKbps: kbps));
  }

  Future<void> compressVideo() async {
    final ctrl = videoController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state.isCompressing) return;

    emit(state.copyWith(isCompressing: true, compressSuccess: false, compressFail: false));

    try {
      final file = await mediaItem.asset.file;
      if (file == null) {
        emit(state.copyWith(isCompressing: false, compressFail: true));
        return;
      }

      final outputDir = await getTemporaryDirectory();
      final outputPath = '${outputDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final targetHeight = state.resolution;
      final targetFps = state.fps;
      final kbps = state.bitrateKbps;

      // ffmpeg command: scale and set fps and bitrate
      // -y overwrite, -i input, -vf scale=-2:HEIGHT to preserve aspect ratio,
      // -r FPS set frame rate, -b:v BITRATEk set video bitrate
      final command = '-y -i "${file.path}" -vf "scale=-2:${targetHeight}" -r $targetFps -b:v ${kbps}k -preset veryfast -movflags +faststart "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // save to photo library
        await PhotoManager.editor.saveVideo(File(outputPath), title: 'compressed_${DateTime.now().millisecondsSinceEpoch}');
        emit(state.copyWith(isCompressing: false, compressSuccess: true));
      } else {
        emit(state.copyWith(isCompressing: false, compressFail: true));
      }
    } catch (e) {
      emit(state.copyWith(isCompressing: false, compressFail: true));
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
