import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Cubit/trim_home_cubit.dart';
import '../Items/media_item.dart';
import '../State/trim_state.dart';
import 'trim_editor_screen.dart';

class TrimHomeScreen extends StatelessWidget {
  const TrimHomeScreen({super.key});

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _openEditor(BuildContext context, MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // TrimEditorCubit tạo mới hoàn toàn — độc lập với home
        builder: (_) => TrimEditorScreen(mediaItem: item),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<MediaItem> videos,
    required bool isStillLoading,
  }) {
    // Ẩn section nếu không có video VÀ đã load xong
    if (videos.isEmpty && !isStillLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (videos.isNotEmpty)
                Text(
                  "${videos.length} videos",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        if (videos.isEmpty && isStillLoading)
          // Skeleton placeholder khi đang load
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            padding: const EdgeInsets.only(bottom: 28),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(color: Colors.white10),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            padding: const EdgeInsets.only(bottom: 28),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final item = videos[index];
              return GestureDetector(
                onTap: () => _openEditor(context, item),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.thumbnail != null)
                        Image.memory(
                          item.thumbnail!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                      else
                        Container(color: Colors.white10),

                      // Duration badge
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _formatDuration(item.asset.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // Scissors icon
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.content_cut,
                            color: Colors.white,
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrimHomeCubit()..loadVideos(),
      child: BlocBuilder<TrimHomeCubit, TrimState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              title: const Text(
                "Trim Videos",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            body: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state.loadFail) {
                  return const Center(
                    child: Text(
                      "Failed to load videos",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                // loadSuccess nhưng tất cả đều rỗng → empty
                if (state.loadSuccess && state.isEmpty) {
                  return const Center(
                    child: Text(
                      "No videos found",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                // isStillLoading = true khi loadSuccess nhưng
                // các section vẫn đang được fill dần
                final isStillLoading = !state.loadSuccess;

                return ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    _buildSection(
                      context: context,
                      title: "Over 10 Minutes",
                      videos: state.over10Minutes,
                      isStillLoading: isStillLoading,
                    ),
                    _buildSection(
                      context: context,
                      title: "Over 5 Minutes",
                      videos: state.over5Minutes,
                      isStillLoading: isStillLoading,
                    ),
                    _buildSection(
                      context: context,
                      title: "Over 3 Minutes",
                      videos: state.over3Minutes,
                      isStillLoading: isStillLoading,
                    ),
                    _buildSection(
                      context: context,
                      title: "Others",
                      videos: state.others,
                      isStillLoading: isStillLoading,
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
