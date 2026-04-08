import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/kasrrat_colors.dart';

class VideoGuideCard extends StatefulWidget {
  final String title;
  final String videoPath;

  const VideoGuideCard({super.key, required this.title, required this.videoPath});

  @override
  State<VideoGuideCard> createState() => _VideoGuideCardState();
}

class _VideoGuideCardState extends State<VideoGuideCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // controller initialization
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {}); // Show video once loaded
      })
      ..setLooping(true); // Loop the guide video
  }

  @override
  void dispose() {
    // Dispose to save phone memory
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity, // taking available width
            constraints: const BoxConstraints(maxHeight: 250), // Set a maximum height
            color: AppColors.surfaceGrey,
            child: _controller.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      // to pull the width/height ratio form the video
                      aspectRatio: _controller.value.aspectRatio,
                      child: GestureDetector(
                        onTap: () {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        },
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}