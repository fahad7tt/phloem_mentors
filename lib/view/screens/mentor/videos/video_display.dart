import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/videomodule_controller.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDisplayPage extends StatelessWidget {
  final String moduleName;

  const VideoDisplayPage({super.key, required this.moduleName});

  @override
  Widget build(BuildContext context) {
    final videoController = context.watch<VideoController>();
    final videoModule = videoController.videoModules[moduleName];
    final videoUrl = videoModule?.videoUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Display'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId: videoUrl.isNotEmpty ? YoutubePlayer.convertUrlToId(videoUrl) ?? '' : '',
                  flags: const YoutubePlayerFlags(
                    autoPlay: true,
                    mute: false,
                  ),
                ),
                showVideoProgressIndicator: true,
                bottomActions: [
                  CurrentPosition(),
                  ProgressBar(
                    isExpanded: true,
                    colors: const ProgressBarColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey,
                    ),
                  ),
                  RemainingDuration(),
                  const PlaybackSpeedButton(),
                  FullScreenButton(),
                ],
                onReady: () {
                  // ignore: avoid_print
                  print('Player is ready.');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to the mentor home page
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}