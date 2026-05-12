import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../Cubit/photo_cubit.dart';
import '../State/photo_state.dart';

class PhotoScreen extends StatelessWidget {
  const PhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhotoCubit()..loadPhotos(),
      child: const _PhotoScreenBody(),
    );
  }
}

class _PhotoScreenBody extends StatefulWidget {
  const _PhotoScreenBody();

  @override
  State<_PhotoScreenBody> createState() => _PhotoScreenBodyState();
}

class _PhotoScreenBodyState extends State<_PhotoScreenBody> {
  double dragX = 0;

  final double swipeThreshold = 120;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final scale = size.width / 390;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<PhotoCubit, PhotoState>(
          builder: (context, state) {
            /// LOADING
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            /// FAIL
            if (state.loadFail) {
              return Center(
                child: Text(
                  "Failed to load photos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            /// EMPTY
            if (state.photos.isEmpty) {
              return Center(
                child: Text(
                  "No photos found",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            final currentPhoto = state.photos[state.currentIndex];

            final dragPercent =
                (dragX.abs() / swipeThreshold).clamp(0.0, 1.0);

            final totalAction =
                state.keepCount + state.deleteCount;

            final progress =
                totalAction / state.photos.length;

            final isDraggingLeft = dragX < -20;

            final isDraggingRight = dragX > 20;

            return Stack(
              children: [
                /// TOP BAR
                Positioned(
                  top: 10 * scale,
                  left: 18 * scale,
                  right: 18 * scale,
                  child: Row(
                    children: [
                      /// BACK
                      _circleButton(
                        icon:
                            Icons.arrow_back_ios_new_rounded,
                        scale: scale,
                        opacity: 1,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),

                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "SWIPEWIPE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24 * scale,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),

                            SizedBox(height: 2 * scale),

                            Text(
                              "${state.currentIndex + 1}/${state.photos.length} • ${(progress * 100).toInt()}%",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 15 * scale,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// UNDO
                      _circleButton(
                        icon: Icons.refresh_rounded,
                        scale: scale,
                        opacity:
                            state.hasAction ? 1 : 0.25,
                        onTap: () {
                          context
                              .read<PhotoCubit>()
                              .undoAction();

                          setState(() {
                            dragX = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                /// PHOTO CARD
                Center(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        dragX += details.delta.dx;
                      });
                    },
                    onPanEnd: (_) {
                      if (dragX < -swipeThreshold) {
                        context
                            .read<PhotoCubit>()
                            .deletePhoto();
                      } else if (dragX >
                          swipeThreshold) {
                        context
                            .read<PhotoCubit>()
                            .keepPhoto();
                      }

                      setState(() {
                        dragX = 0;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      curve: Curves.easeOut,
                      transform: Matrix4.identity()
                        ..translate(dragX)
                        ..rotateZ(dragX * 0.0007),
                      width: size.width * 0.97,
                      height: size.height * 0.7,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                                34 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.45),
                            blurRadius: 40,
                            offset:
                                const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                                34 * scale),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            /// IMAGE
                            FutureBuilder<Uint8List?>(
                              future:
                                  currentPhoto.thumbnailDataWithSize(
                                const ThumbnailSize(
                                  1200,
                                  1200,
                                ),
                              ),
                              builder:
                                  (context, snapshot) {
                                if (!snapshot
                                    .hasData) {
                                  return Container(
                                    color: Colors.black,
                                    child:
                                        const Center(
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  );
                                }

                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),

                            /// BLUR WHEN DRAGGING
                            if (dragPercent > 0)
                              BackdropFilter(
                                filter:
                                    ImageFilter.blur(
                                  sigmaX:
                                      dragPercent * 4,
                                  sigmaY:
                                      dragPercent * 4,
                                ),
                                child: Container(
                                  color: Colors.black
                                      .withOpacity(
                                    dragPercent * 0.2,
                                  ),
                                ),
                              ),

                            /// DARK OVERLAY
                            Container(
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  begin:
                                      Alignment
                                          .topCenter,
                                  end: Alignment
                                      .bottomCenter,
                                  colors: [
                                    Colors.black
                                        .withOpacity(
                                            0.3),
                                    Colors
                                        .transparent,
                                    Colors.black
                                        .withOpacity(
                                            0.22),
                                  ],
                                ),
                              ),
                            ),

                            /// DELETE OVERLAY
                            if (isDraggingLeft)
                              Positioned(
                                top: 50 * scale,
                                left: 28 * scale,
                                child:
                                    Transform.rotate(
                                  angle: -0.18,
                                  child:
                                      _actionOverlay(
                                    text: "DELETE",
                                    color:
                                        const Color(
                                      0xFFB57BFF,
                                    ),
                                    scale: scale,
                                  ),
                                ),
                              ),

                            /// KEEP OVERLAY
                            if (isDraggingRight)
                              Positioned(
                                top: 50 * scale,
                                right: 28 * scale,
                                child:
                                    Transform.rotate(
                                  angle: 0.18,
                                  child:
                                      _actionOverlay(
                                    text: "KEEP",
                                    color:
                                        const Color(
                                      0xFF7DFFA7,
                                    ),
                                    scale: scale,
                                  ),
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
                  bottom: 170 * scale,
                  child: AnimatedOpacity(
                    duration: const Duration(
                      milliseconds: 160,
                    ),
                    opacity:
                        dragPercent > 0 ? 0 : 1,
                    child: Column(
                      children: [
                        _sideIcon(
                          Icons.favorite_border_rounded,
                          scale,
                        ),

                        SizedBox(
                            height: 14 * scale),

                        _sideIcon(
                          Icons.bookmark_border_rounded,
                          scale,
                        ),

                        SizedBox(
                            height: 14 * scale),

                        _sideIcon(
                          Icons.ios_share_rounded,
                          scale,
                        ),

                        SizedBox(
                            height: 14 * scale),

                        _sideIcon(
                          Icons.auto_awesome_rounded,
                          scale,
                        ),
                      ],
                    ),
                  ),
                ),

                /// BOTTOM
                Positioned(
                  bottom: 30 * scale,
                  left: 26 * scale,
                  right: 26 * scale,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "DELETE",
                                style: TextStyle(
                                  color:
                                      const Color(
                                    0xFFB57BFF,
                                  ),
                                  fontSize:
                                      28 * scale,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),

                              SizedBox(
                                height: 6 * scale,
                              ),

                              Text(
                                state.deleteCount
                                    .toString(),
                                style: TextStyle(
                                  color:
                                      const Color(
                                    0xFFB57BFF,
                                  ),
                                  fontSize:
                                      18 * scale,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              Text(
                                "KEEP",
                                style: TextStyle(
                                  color:
                                      const Color(
                                    0xFF7DFFA7,
                                  ),
                                  fontSize:
                                      28 * scale,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),

                              SizedBox(
                                height: 6 * scale,
                              ),

                              Text(
                                state.keepCount
                                    .toString(),
                                style: TextStyle(
                                  color:
                                      const Color(
                                    0xFF7DFFA7,
                                  ),
                                  fontSize:
                                      18 * scale,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (state.hasAction)
                        SizedBox(
                            height: 18 * scale),

                      /// PROGRESS BAR
                      if (state.hasAction)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            100,
                          ),
                          child: SizedBox(
                            height: 14 * scale,
                            width:
                                double.infinity,
                            child: LayoutBuilder(
                              builder: (
                                context,
                                constraints,
                              ) {
                                final total =
                                    state.deleteCount +
                                        state
                                            .keepCount;

                                final deleteWidth =
                                    total == 0
                                        ? constraints
                                                .maxWidth /
                                            2
                                        : constraints
                                                .maxWidth *
                                            (state.deleteCount /
                                                total);

                                final keepWidth =
                                    total == 0
                                        ? constraints
                                                .maxWidth /
                                            2
                                        : constraints
                                                .maxWidth *
                                            (state.keepCount /
                                                total);

                                return Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(
                                        milliseconds:
                                            220,
                                      ),
                                      width:
                                          deleteWidth,
                                      color:
                                          const Color(
                                        0xFFB57BFF,
                                      ),
                                    ),

                                    AnimatedContainer(
                                      duration:
                                          const Duration(
                                        milliseconds:
                                            220,
                                      ),
                                      width:
                                          keepWidth,
                                      color:
                                          const Color(
                                        0xFF7DFFA7,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                    ],
                  ),
                )
              ],
            );
          },
        ),
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
      ),
    );
  }

  Widget _sideIcon(
    IconData icon,
    double scale,
  ) {
    return Container(
      width: 48 * scale,
      height: 48 * scale,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24 * scale,
      ),
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
        border: Border.all(
          color: color,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(
          16 * scale,
        ),
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