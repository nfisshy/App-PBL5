import 'package:equatable/equatable.dart';
import 'dart:typed_data';

class MapPhotoGroup extends Equatable {
  const MapPhotoGroup({
    required this.latitude,
    required this.longitude,
    required this.count,
    required this.thumbnail,
  });

  final double latitude;
  final double longitude;
  final int count;
  final Uint8List? thumbnail;

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        count,
        thumbnail,
      ];
}

class MapState extends Equatable {
  const MapState({
    this.isLoading = false,
    this.loadFail = false,
    this.loadSuccess = false,
    this.groups = const [],
  });

  final bool isLoading;
  final bool loadFail;
  final bool loadSuccess;

  final List<MapPhotoGroup> groups;

  MapState copyWith({
    bool? isLoading,
    bool? loadFail,
    bool? loadSuccess,
    List<MapPhotoGroup>? groups,
  }) {
    return MapState(
      isLoading:
          isLoading ?? this.isLoading,
      loadFail:
          loadFail ?? this.loadFail,
      loadSuccess:
          loadSuccess ?? this.loadSuccess,
      groups: groups ?? this.groups,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        loadFail,
        loadSuccess,
        groups,
      ];
}