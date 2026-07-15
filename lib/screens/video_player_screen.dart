import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:test_app/l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/service_locator.dart';
import '../providers/language_provider.dart';

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
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final videoData = await getIt<ApiService>().getVideoPlayAbleLink(
      widget.movieId,
      language: languageProvider.tmdbLanguageCode,
    );
    
    if (videoData != null) {
      final results = videoData.results;
      if (results != null && results.isNotEmpty) {
        // Find the first YouTube trailer
        final trailer = results.firstWhere(
          (element) => element.site?.toLowerCase() == 'youtube' && element.type?.toLowerCase() == 'trailer',
          orElse: () => results.first,
        );
        
        _videoKey = trailer.key;
        if (_videoKey != null) {
          _controller = YoutubePlayerController.fromVideoId(
            videoId: _videoKey ?? '',
            autoPlay: true,
            params: const YoutubePlayerParams(
              showControls: true,
              showFullscreenButton: true,
              mute: false,
            ),
          );
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Scaffold(backgroundColor: Colors.black);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(l10n.trailer),
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
                : Text(
                    l10n.noTrailerAvailable,
                    style: const TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}
