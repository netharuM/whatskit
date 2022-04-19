import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:whatskit/pages/trimmed_video_page.dart';
import 'package:video_trimmer/video_trimmer.dart';

/// the page where you can see the parts of trimmed videos
class VideoTrimmerPage extends StatefulWidget {
  const VideoTrimmerPage({Key? key}) : super(key: key);

  @override
  State<VideoTrimmerPage> createState() => _VideoTrimmerPageState();
}

class _VideoTrimmerPageState extends State<VideoTrimmerPage> {
  /// to pick the video file
  final ImagePicker _picker = ImagePicker();

  /// video file we are trimming
  XFile? _video;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_video == null) {
      return SafeArea(
        child: Scaffold(
          body: GestureDetector(
            onTap: () {
              _picker.pickVideo(source: ImageSource.gallery).then((video) {
                setState(() {
                  _video = video;
                });
              });
            },
            child: Stack(
              children: [
                Container(),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        size: 120,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                        'Tap to select a video',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: _TrimPreviews(
        video: File(_video!.path),
      ),
    );
  }
}

/// previews of the autoMatically trimmed trims
class _TrimPreviews extends StatefulWidget {
  final File video;
  const _TrimPreviews({Key? key, required this.video}) : super(key: key);

  @override
  State<_TrimPreviews> createState() => _TrimPreviewsState();
}

/// sharingState of trims
///  - none : nothing is going on
///  - rendering : rendering the clips
///  - sharing : sharing the clips
enum SharingState {
  /// nothing is happening
  none,

  /// sharing state is rendering
  rendering,

  /// sharing the rendered clips
  sharing,
}

class _TrimPreviewsState extends State<_TrimPreviews> {
  /// full duration of the video
  Duration? _fullVidDuration;

  /// trimmed videos clips of the full video
  List<Map<String, Duration>>? _trimmedVids;

  /// list of paths of exported clips
  List<String>? _exportedVids;

  /// sharing state of the clips
  SharingState _sharingState = SharingState.none;

  @override
  void initState() {
    _init().then((_) {
      setState(() {
        _trimmedVids = _getTrimmedVideos();
      });
    });
    super.initState();
  }

  Future<void> _init() async {
    // getting the data of the video
    VideoPlayerController _vidPlayController =
        VideoPlayerController.file(widget.video);
    await _vidPlayController.initialize();
    _fullVidDuration = _vidPlayController.value.duration;
    await _vidPlayController.dispose();
  }

  /// get the list of starting and ending positions of trimmed videos
  /// this will use 30 seconds as clips
  List<Map<String, Duration>> _getTrimmedVideos() {
    /// list of trimmed video clips to be returned
    List<Map<String, Duration>> _trimmedVideos = [];
    for (int i = 0; i < _fullVidDuration!.inSeconds; i += 30) {
      _trimmedVideos.add({
        'start': Duration(seconds: i),
        'end': Duration(
          // if the last clip ending point is longer than the video duration we use the videoDuration as the ending position
          // ex : last trim -- 30 seconds to 60 seconds but the video is only 58 seconds long
          seconds: i + 30 > _fullVidDuration!.inSeconds
              ? _fullVidDuration!.inSeconds
              : i + 30,
        ),
      });
    }
    return _trimmedVideos;
  }

  @override
  Widget build(BuildContext context) {
    if (_trimmedVids == null) {
      // if videos havent trimmed yet
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_sharingState == SharingState.none) {
      return Scaffold(
        appBar: (_exportedVids != null && _trimmedVids != null) &&
                (_exportedVids!.length == _trimmedVids!.length)
            ? AppBar(
                actions: [
                  TextButton.icon(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFf72785)),
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            const Color(0xFFf72785).withOpacity(0.04);
                          }
                          if (states.contains(MaterialState.focused) ||
                              states.contains(MaterialState.pressed)) {
                            return const Color(0xFFf72785).withOpacity(0.12);
                          }
                          return null; // Defer to the widget's default.
                        },
                      ),
                    ),
                    icon: const Icon(Icons.cleaning_services_rounded),
                    label: const Text('clear rendered cache'),
                    onPressed: () async {
                      for (var videoFile in _exportedVids!) {
                        await File(videoFile).delete();
                      }
                      setState(() {
                        _exportedVids = null;
                      });
                    },
                  ),
                ],
                backgroundColor: Theme.of(context).cardColor,
                toolbarHeight: 48,
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_exportedVids == null) {
              setState(() {
                _exportedVids = [];
                _sharingState = SharingState.rendering;
              });
              for (Map<String, Duration> trimmedVid in _trimmedVids!) {
                Trimmer trimmer = Trimmer();
                await trimmer.loadVideo(videoFile: widget.video);
                // this save trimmedVideoAsync is a function that i created in my fork of the trimmer
                String? outPutPath = await trimmer.saveTrimmedVideoAsync(
                    startValue: trimmedVid['start']!.inMilliseconds.toDouble(),
                    endValue: trimmedVid['end']!.inMilliseconds.toDouble(),
                    outputFormat: FileFormat.mp4,
                    storageDir: StorageDir.externalStorageDirectory,
                    addToEndOfOutPutPath:
                        '${_trimmedVids!.indexOf(trimmedVid)}',
                    ignoreRC: true);
                trimmer.dispose();
                if (outPutPath == null) {
                  setState(() {
                    _sharingState = SharingState.none;
                  });
                  debugPrint('error ------ happend while rendering');
                  return;
                }
                setState(() {
                  _exportedVids!.add(outPutPath);
                });
              }
              setState(() {
                _sharingState = SharingState.sharing;
              });
              await Share.shareFiles(_exportedVids!);
            } else {
              setState(() {
                _sharingState = SharingState.sharing;
              });
              await Share.shareFiles(_exportedVids!);
            }
            setState(() {
              _sharingState = SharingState.none;
            });
          },
          child: const Icon(Icons.send),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: ListView(
          children: [
            for (int i = 0; i < _trimmedVids!.length; i++)
              TrimmedVidCard(
                start: _trimmedVids![i]['start']!,
                end: _trimmedVids![i]['end']!,
                video: widget.video,
              ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
              Text(
                _sharingState == SharingState.rendering
                    ? 'rendering ${_exportedVids!.length + 1} of ${_trimmedVids!.length}'
                    : 'sharing...',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// video card that shows the starting and ending position of the video
class TrimmedVidCard extends StatelessWidget {
  /// starting position of the clip
  final Duration start;

  /// ending position of the clip
  final Duration end;

  /// video file
  final File video;
  const TrimmedVidCard({
    Key? key,
    required this.start,
    required this.end,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrimmedVideoPage(
                  start: start,
                  end: end,
                  video: video,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.video_collection_sharp),
                Text('${start.inSeconds}s - ${end.inSeconds}s'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
