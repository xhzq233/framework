import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:framework/cupertino.dart';
import 'package:framework/route.dart';
import 'package:framework/src/route/root_navigator.dart';
import 'package:video_player/video_player.dart';

// todo
final CacheManager _videoCacheManager = CacheManager(Config(
  'video_cache',
  maxNrOfCacheObjects: 500,
  stalePeriod: const Duration(days: 999),
));

const _defaultPlaceHolder = SizedBox(width: 60, height: 60);
const double _defaultIconSize = 36;

class VideoThumbWidget extends StatefulWidget {
  const VideoThumbWidget({
    super.key,
    required this.videoUrl,
    this.placeholder = _defaultPlaceHolder,
    this.iconSize = _defaultIconSize,
  });

  static void clearCache() {
    _videoCacheManager.emptyCache();
  }

  final String videoUrl;
  final Widget placeholder;
  final double iconSize;

  @override
  State<VideoThumbWidget> createState() => _VideoThumbWidgetState();
}

class _VideoThumbWidgetState extends State<VideoThumbWidget> {
  double? downloadProgress;
  File? _fileInfo;
  StreamSubscription<FileResponse>? _fileStreamSubscription;
  late final Object heroTag = hashCode;
  final GlobalKey videoPageRouteKey = GlobalKey();

  void _reset() {
    setState(() {
      downloadProgress = null;
      _fileInfo = null;
      _fileStreamSubscription?.cancel();
      _fileStreamSubscription = null;
    });
  }

  void _tap() {
    if (_fileInfo != null) {
      if (_fileInfo!.existsSync() == false) {
        _reset();
        _init();
        return;
      }
      rootNavigator.push(PhotoPageRoute(
          draggableChild: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: _VideoWidget(videoFile: _fileInfo!, key: videoPageRouteKey),
          ),
          heroTag: heroTag));
    } else {
      _init();
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final FileInfo? file = await _videoCacheManager.getFileFromCache(widget.videoUrl);
    if (file != null) {
      setState(() {
        _fileInfo = file.file;
      });
    } else {
      _fileStreamSubscription = _videoCacheManager.getFileStream(widget.videoUrl, withProgress: true).listen(
        (FileResponse event) {
          if (event is DownloadProgress) {
            setState(() {
              downloadProgress = event.progress;
            });
          } else if (event is FileInfo) {
            setState(() {
              _fileInfo = event.file;
              _fileStreamSubscription = null;
            });
          }
        },
      );
    }
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
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = const SizedBox.shrink();
    if (_fileInfo != null) {
      icon = Icon(CupertinoIcons.play_circle, color: Colors.white, size: widget.iconSize);
    } else if (downloadProgress != null) {
      icon = Align(child: CircularProgressIndicator(value: downloadProgress, color: Colors.white));
    }

    return CustomCupertinoButton(
      onTap: _tap,
      child: Stack(
        children: [
          Hero(tag: heroTag, child: widget.placeholder),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: icon,
            ),
          ),
        ],
      ),
    );
  }
}

class LocalVideoThumbWidget extends StatelessWidget {
  const LocalVideoThumbWidget({
    super.key,
    required this.fileUrl,
    this.placeholder = _defaultPlaceHolder,
    this.iconSize = _defaultIconSize,
  });

  final String fileUrl;
  final Widget placeholder;
  final double iconSize;

  void _tap(BuildContext context) {
    if (File(fileUrl).existsSync() == false) {
      return;
    }
    final GlobalKey videoPageRouteKey = GlobalKey();
    rootNavigator.push(
      PhotoPageRoute(
          draggableChild: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: _VideoWidget(videoFile: File(fileUrl), key: videoPageRouteKey),
          ),
          heroTag: hashCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(CupertinoIcons.play_circle, color: Colors.white, size: iconSize);

    return CustomCupertinoButton(
      onTap: () => _tap(context),
      child: Stack(
        children: [
          Hero(tag: hashCode, child: placeholder),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: icon,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoWidget extends StatefulWidget {
  const _VideoWidget({super.key, required this.videoFile});

  final File videoFile;

  @override
  State<_VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<_VideoWidget> {
  late final VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.videoFile);
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
    _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_videoPlayerController),
            if (_videoPlayerController.value.isInitialized)
              ClosedCaption(text: _videoPlayerController.value.caption.text),
            if (_videoPlayerController.value.isInitialized) _ControlsOverlay(controller: _videoPlayerController),
            if (_videoPlayerController.value.isInitialized)
              VideoProgressIndicator(
                _videoPlayerController,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white,
                ),
                // Expand draggable area to tap and scrub.
                padding: const EdgeInsets.only(top: 36),
              ),
          ],
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
          duration: const Duration(milliseconds: 100),
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
