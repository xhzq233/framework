/// EcsMerchantApp - video_page
/// Created by xhz on 9/12/24

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '../../cupertino.dart';

// todo
final CacheManager _videoCacheManager = CacheManager(Config(
  'video_cache',
  maxNrOfCacheObjects: 500,
  stalePeriod: const Duration(days: 999),
));

class VideoThumbWidget extends StatefulWidget {
  const VideoThumbWidget({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoThumbWidget> createState() => _VideoThumbWidgetState();
}

class _VideoThumbWidgetState extends State<VideoThumbWidget> {
  double? downloadProgress;
  FileInfo? _fileInfo;
  StreamSubscription<FileResponse>? _fileStreamSubscription;

  void _startDownload() {
    if (_fileInfo != null || _fileStreamSubscription != null) {
      return;
    }
    _fileStreamSubscription = _videoCacheManager.getFileStream(widget.videoUrl, withProgress: true).listen(
      (FileResponse event) {
        print('event: $event');
        if (event is DownloadProgress) {
          setState(() {
            downloadProgress = event.progress;
          });
        } else if (event is FileInfo) {
          setState(() {
            _fileInfo = event;
          });
        }
      },
    );
  }

  void _reset() {
    setState(() {
      downloadProgress = null;
      _fileInfo = null;
      _fileStreamSubscription?.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    _videoCacheManager.getFileFromCache(widget.videoUrl).then((FileInfo? file) {
      if (file != null) {
        setState(() {
          _fileInfo = file;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _fileStreamSubscription?.cancel();
  }

  @override
  void didUpdateWidget(covariant VideoThumbWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (_fileInfo != null) {
      icon = const Icon(CupertinoIcons.play_arrow, color: Colors.white, size: 36);
    } else if (downloadProgress != null) {
      icon = CircularProgressIndicator(value: downloadProgress, color: Colors.white);
    } else {
      icon = const Icon(CupertinoIcons.down_arrow, color: Colors.white, size: 36);
    }
    return CustomCupertinoButton(
      onTap: () async {
        if (_fileInfo != null) {
          await Navigator.push(context, VideoPage.route(_fileInfo!.file.path));
        } else {
          _startDownload();
        }
      },
      child: ColoredBox(
        color: Colors.black,
        child: Align(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  // todo: hero
  const VideoPage({super.key, required this.videoFileUrl, String? heroTag}) : heroTag = heroTag ?? videoFileUrl;

  static Route<void> route(String videoUrl, {String? heroTag}) {
    // Fade in the video page.
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: animation,
        child: VideoPage(videoFileUrl: videoUrl, heroTag: heroTag),
      ),
    );
  }

  final String videoFileUrl;
  final String heroTag;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late final VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoFileUrl));
    _videoPlayerController.addListener(() => setState(() {}));
    _started();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _started() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.black,
        child: Align(
          child: AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_videoPlayerController),
                ClosedCaption(text: _videoPlayerController.value.caption.text),
                _ControlsOverlay(controller: _videoPlayerController),
                VideoProgressIndicator(_videoPlayerController, allowScrubbing: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
