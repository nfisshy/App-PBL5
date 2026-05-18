import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../Cubit/map_cubit.dart';
import '../State/map_state.dart';

class WorldMapScreen
    extends StatelessWidget {
  const WorldMapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => MapCubit()
            ..loadMap(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child:
              BlocBuilder<
                MapCubit,
                MapState
              >(
            builder: (
              context,
              state,
            ) {
              if (state.isLoading) {
                return const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        Colors.white,
                  ),
                );
              }

              if (state.loadFail) {
                return const Center(
                  child: Text(
                    "Failed to load map",
                    style: TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  /// MAP
                  FlutterMap(
                    options: MapOptions(
                      initialCenter:
                          const LatLng(
                        16.047079,
                        108.206230,
                      ),
                      initialZoom: 4.2,
                    ),

                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'photoapp',
                      ),

                      MarkerLayer(
                        markers:
                            state.groups.map((
                          group,
                        ) {
                          return Marker(
                            point: LatLng(
                              group
                                  .latitude,
                              group
                                  .longitude,
                            ),
                            width: 82,
                            height: 82,
                            child:
                                _MapPhotoMarker(
                              thumbnail:
                                  group
                                      .thumbnail,
                              count:
                                  group
                                      .count,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  /// TOP BAR
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 110,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal:
                            22,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                                  0.4,
                                ),
                            blurRadius:
                                20,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _circleButton(
                            icon:
                                Icons
                                    .arrow_back_ios_new_rounded,
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                            },
                          ),

                          const Expanded(
                            child: Center(
                              child: Text(
                                "WORLD MAP",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      28,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),
                          ),

                          _circleButton(
                            icon:
                                Icons
                                    .tune_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration:
            BoxDecoration(
          color: Colors.white
              .withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class _MapPhotoMarker
    extends StatelessWidget {
  const _MapPhotoMarker({
    required this.thumbnail,
    required this.count,
  });

  final Uint8List? thumbnail;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnail != null)
              Image.memory(
                thumbnail!,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: Colors.grey,
              ),

            Container(
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment
                          .topCenter,
                  end:
                      Alignment
                          .bottomCenter,
                  colors: [
                    Colors
                        .transparent,
                    Colors.black
                        .withOpacity(
                          0.8,
                        ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: Text(
                "$count",
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontWeight:
                      FontWeight.w900,
                  fontSize: 28,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}