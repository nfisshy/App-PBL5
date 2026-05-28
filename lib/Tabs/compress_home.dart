import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Cubit/compress_cubit.dart';
import '../Items/media_item.dart';
import '../State/compress_state.dart';
import 'compress_editor_screen.dart';

class CompressHomeScreen
    extends StatelessWidget {
  const CompressHomeScreen({
    super.key,
  });

  String _formatBytes(
    int bytes,
  ) {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (bytes >= gb) {
      return "${(bytes / gb).toStringAsFixed(1)} GB";
    }

    if (bytes >= mb) {
      return "${(bytes / mb).toStringAsFixed(0)} MB";
    }

    return "${(bytes / kb).toStringAsFixed(0)} KB";
  }

  Widget _buildVideoGrid({
    required String title,
    required List<MediaItem> videos,
    required CompressCubit cubit,
  }) {
    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(
            bottom: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              Text(
                "${videos.length} videos",
                style:
                    const TextStyle(
                  color:
                      Colors.white54,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              videos.length,
          padding:
              const EdgeInsets.only(
            bottom: 28,
          ),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.68,
          ),
          itemBuilder:
              (context, index) {
            final item =
                videos[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompressEditorScreen(mediaItem: item),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.thumbnail !=
                        null)
                      Image.memory(
                        item.thumbnail!,
                        fit:
                            BoxFit.cover,
                      )
                    else
                      Container(
                        color: Colors
                            .grey
                            .shade900,
                      ),

                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: FutureBuilder<
                          int>(
                        future: cubit
                            .getFileSize(
                          item.asset,
                        ),
                        builder: (
                          context,
                          snapshot,
                        ) {
                          final size =
                              snapshot.data ??
                                  0;

                          return Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal:
                                  7,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.75,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Text(
                              _formatBytes(
                                size,
                              ),
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontSize:
                                    11,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding:
                            const EdgeInsets.all(
                          5,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .black
                              .withOpacity(
                            0.6,
                          ),
                          shape: BoxShape
                              .circle,
                        ),
                        child:
                            const Icon(
                          Icons.compress,
                          color: Colors
                              .white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocProvider(
      create:
          (_) => CompressCubit()
            ..loadVideos(),
      child:
          BlocBuilder<
            CompressCubit,
            CompressState
          >(
            builder:
                (context, state) {
              final cubit =
                  context.read<
                    CompressCubit
                  >();

              return Scaffold(
                backgroundColor:
                    Colors.black,
                appBar: AppBar(
                  backgroundColor:
                      Colors.black,
                  elevation: 0,
                  title:
                      const Text(
                    "Compress Videos",
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
                body: Builder(
                  builder: (
                    context,
                  ) {
                    if (state
                        .isLoading) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (state
                        .loadFail) {
                      return const Center(
                        child: Text(
                          "Failed to load videos",
                          style:
                              TextStyle(
                            color: Colors
                                .white,
                          ),
                        ),
                      );
                    }

                    if (state
                        .isEmpty) {
                      return const Center(
                        child: Text(
                          "No videos found",
                          style:
                              TextStyle(
                            color: Colors
                                .white,
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      );
                    }

                    return ListView(
                      padding:
                          const EdgeInsets.all(
                        14,
                      ),
                      children: [
                        _buildVideoGrid(
                          title:
                              "More Than 1 GB",
                          videos:
                              state.over1GB,
                          cubit: cubit,
                        ),

                        _buildVideoGrid(
                          title:
                              "More Than 500 MB",
                          videos:
                              state.over500MB,
                          cubit: cubit,
                        ),

                        _buildVideoGrid(
                          title:
                              "More Than 250 MB",
                          videos:
                              state.over250MB,
                          cubit: cubit,
                        ),

                        _buildVideoGrid(
                          title:
                              "Others",
                          videos:
                              state.others,
                          cubit: cubit,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
    );
  }
}