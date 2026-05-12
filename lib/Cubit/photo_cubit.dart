import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../State/photo_state.dart';

class PhotoCubit extends Cubit<PhotoState> {
  PhotoCubit() : super(const PhotoState(isLoading: true));

  /// LOAD PHOTOS
  Future<void> loadPhotos() async {
    emit(state.copyWith(
      isLoading: true,
      loadFail: false,
      loadSuccess: false,
    ));

    try {
      /// REQUEST PERMISSION
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();

      if (!permission.isAuth) {
        emit(state.copyWith(
          isLoading: false,
          loadFail: true,
          loadSuccess: false,
        ));
        return;
      }

      /// GET ALBUMS
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          loadFail: true,
          loadSuccess: false,
        ));
        return;
      }

      /// GET ALL PHOTOS
      final List<AssetEntity> photos =
          await albums[0].getAssetListPaged(
        page: 0,
        size: 9999,
      );

      emit(state.copyWith(
        isLoading: false,
        loadFail: false,
        loadSuccess: true,
        photos: photos,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        loadFail: true,
        loadSuccess: false,
      ));
    }
  }

  /// KEEP PHOTO
  void keepPhoto() {
    emit(state.copyWith(
      keepCount: state.keepCount + 1,
      hasAction: true,
    ));

    nextPhoto();
  }

  /// DELETE PHOTO
  void deletePhoto() {
    emit(state.copyWith(
      deleteCount: state.deleteCount + 1,
      hasAction: true,
    ));

    nextPhoto();
  }

  /// NEXT PHOTO
  void nextPhoto() {
    if (state.currentIndex < state.photos.length - 1) {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
      ));
    }
  }

  /// UNDO
  void undoAction() {
    if (!state.hasAction) return;

    int newIndex = state.currentIndex;
    int newKeep = state.keepCount;
    int newDelete = state.deleteCount;

    if (newIndex > 0) {
      newIndex--;
    }

    if (newKeep > 0) {
      newKeep--;
    } else if (newDelete > 0) {
      newDelete--;
    }

    emit(state.copyWith(
      currentIndex: newIndex,
      keepCount: newKeep,
      deleteCount: newDelete,
      hasAction: newKeep > 0 || newDelete > 0,
    ));
  }
}