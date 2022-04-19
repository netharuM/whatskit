import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_trimmer/video_trimmer.dart';

/// shows the trimmed version of a video
/// also users can manually trim the video and share it individually
class TrimmedVideoPage extends StatefulWidget {
  /// the position which the trim starts
  final Duration start;

  /// the position which the trim ends
  final Duration end;

  /// video file we are trimming
  final File video;
  const TrimmedVideoPage({
    Key? key,
    required this.video,
    this.start = const Duration(seconds: 0),
    this.end = const Duration(seconds: 30),
  }) : super(key: key);

  @override
  State<TrimmedVideoPage> createState() => _TrimmedVideoPageState();
}

class _TrimmedVideoPageState extends State<TrimmedVideoPage> {
  /// trimmer controller
  Trimmer? _trimmer;

  /// whether the video is being played or not
  bool? _isPlaying;

  /// the starting position of the trim in milliseconds
  double? _trimStart;

  /// the ending position of the trim in milliseconds
  double? _trimEnd;

  @override
  void initState() {
    _init();
    super.initState();
  }

  /// async init function of the class
  Future<void> _init() async {
    _trimmer = Trimmer();
    await _trimmer!.loadVideo(videoFile: widget.video);
    await _trimmer!.videoPlayerController!.setLooping(true);
    setState(() {});
  }

  @override
  void dispose() {
    _trimmer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_trimmer != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: GestureDetector(
                child: VideoViewer(trimmer: _trimmer!),
                onTap: () {
                  if (_isPlaying ?? false) {
                    _trimmer!.videoPlayerController!.pause();
                  } else {
                    _trimmer!.videoPlayerController!.play();
                  }
                },
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TrimEditor(
                    moveStartPosBy: widget.start.inSeconds.toDouble(),
                    moveEndPosBy: widget.start.inSeconds.toDouble() >
                            widget.end.inSeconds.toDouble()
                        ? widget.end.inSeconds.toDouble() -
                            widget.start.inSeconds.toDouble()
                        : widget.start.inSeconds.toDouble(),
                    borderPaintColor: Theme.of(context).primaryColor,
                    circlePaintColor: Theme.of(context).primaryColor,
                    thumbnailQuality: 10,
                    trimmer: _trimmer!,
                    scrubberPaintColor: Colors.white,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 30),
                    onChangeEnd: (double end) {
                      setState(() {
                        _trimEnd = end;
                      });
                    },
                    onChangeStart: (double start) {
                      setState(() {
                        _trimStart = start;
                      });
                    },
                    onChangePlaybackState: (playing) {
                      setState(() {
                        _isPlaying = playing;
                      });
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_isPlaying ?? false) {
                              _trimmer!.videoPlayerController!.pause();
                            } else {
                              _trimmer!.videoPlayerController!.play();
                            }
                          },
                          child: _isPlaying ?? false
                              ? const Icon(Icons.pause_circle_filled_rounded)
                              : const Icon(Icons.play_circle_fill_rounded),
                        ),
                        TrimmerPosIndicator(
                          trimmer: _trimmer!,
                          trimEnd: _trimEnd ??
                              const Duration(seconds: 30)
                                  .inMilliseconds
                                  .toDouble(),
                          trimStart: _trimStart ?? 0,
                        ),
                        TextButton(
                          onPressed: () async {
                            _trimmer!.saveTrimmedVideo(
                              startValue: _trimStart!,
                              endValue: _trimEnd!,
                              outputFormat: FileFormat.mp4,
                              storageDir: StorageDir.temporaryDirectory,
                              onSave: (String? outputPath) {
                                Share.shareFiles([outputPath!]);
                              },
                            );
                          },
                          child: const Icon(Icons.send),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

/// indicating the position of the video
class TrimmerPosIndicator extends StatefulWidget {
  /// the trimmer controller
  final Trimmer trimmer;

  /// the starting position of the trim in milliseconds
  final double trimStart;

  /// the ending position of the trim in milliseconds
  final double trimEnd;
  const TrimmerPosIndicator({
    Key? key,
    required this.trimmer,
    required this.trimStart,
    required this.trimEnd,
  }) : super(key: key);

  @override
  State<TrimmerPosIndicator> createState() => _TrimmerPosIndicatorState();
}

class _TrimmerPosIndicatorState extends State<TrimmerPosIndicator> {
  /// minimum value of the slider
  double min = 0;

  /// maximum value of the slider
  double max = 100;

  /// the current value of the slider
  /// position of the video
  double position = 0;

  void _update() {
    setState(() {
      double _position = widget
          .trimmer.videoPlayerController!.value.position.inMilliseconds
          .toDouble();
      if (_position >= widget.trimStart && _position <= widget.trimEnd) {
        position = _position;
        min = widget.trimStart;
        max = widget.trimEnd;
      } else {
        position = widget.trimStart;
        min = widget.trimStart;
        max = widget.trimEnd;
      }
    });
  }

  @override
  void initState() {
    position = widget
        .trimmer.videoPlayerController!.value.position.inMilliseconds
        .toDouble();
    widget.trimmer.videoPlayerController!.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    widget.trimmer.videoPlayerController!.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Slider(
        value: position,
        min: min,
        max: max,
        onChanged: (double value) {
          widget.trimmer.videoPlayerController!.seekTo(
            Duration(
              milliseconds: value.toInt(),
            ),
          );
        },
      ),
    );
  }
}
