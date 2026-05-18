import 'package:equatable/equatable.dart';

class PlacesState extends Equatable {
  final bool isLoading;
  final bool loadFail;
  final bool loadSuccess;

  final List<String> places;

  const PlacesState({
    required this.isLoading,
    this.loadFail = false,
    this.loadSuccess = false,
    this.places = const [],
  });

  PlacesState copyWith({
    bool? isLoading,
    bool? loadFail,
    bool? loadSuccess,
    List<String>? places,
  }) {
    return PlacesState(
      isLoading:
          isLoading ?? this.isLoading,
      loadFail:
          loadFail ?? this.loadFail,
      loadSuccess:
          loadSuccess ??
          this.loadSuccess,
      places: places ?? this.places,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    loadFail,
    loadSuccess,
    places,
  ];
}