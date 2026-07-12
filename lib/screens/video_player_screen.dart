import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../services/api_service.dart';
import '../services/service_locator.dart';
import '../models/video_link.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int movieId;

  const VideoPlayerScreen({super.key, required this.movieId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  bool _isLoading = true;
  String? _videoKey;

  @override
  void initState() {
    super.initState();
    _fetchVideo();
  }

  void _fetchVideo() async {
    final videoData = await getIt<ApiService>().getVideoPlayAbleLink(widget.movieId);
    if (videoData != null && videoData.results != null && videoData.results!.isNotEmpty) {
      // Find the first YouTube trailer
      final trailer = videoData.results!.firstWhere(
        (element) => element.site?.toLowerCase() == 'youtube' && element.type?.toLowerCase() == 'trailer',
        orElse: () => videoData.results!.first,
      );
      
      _videoKey = trailer.key;
      if (_videoKey != null) {
        // Updated for youtube_player_flutter v10+ (youtube_player_iframe)
        _controller = YoutubePlayerController.fromVideoId(
          videoId: _videoKey!,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text("Trailer"),
      ),
      body: Center(
        child: _isLoading
            ? LoadingAnimationWidget.beat(
                color: Colors.red,
                size: 50,
              )
            : _controller != null
                ? YoutubePlayer(
                    controller: _controller!,
                    aspectRatio: 16 / 9,
                  )
                : const Text(
                    "No trailer available",
                    style: TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}
