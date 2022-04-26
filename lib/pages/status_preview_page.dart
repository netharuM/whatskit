import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

/// the page that shows the preview of the status
class StatusPreviewPage extends StatefulWidget {
  final File file;
  const StatusPreviewPage({Key? key, required this.file}) : super(key: key);

  @override
  State<StatusPreviewPage> createState() => _StatusPreviewPageState();
}

class _StatusPreviewPageState extends State<StatusPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (widget.file.path.endsWith('.mp4')) {
              // if the media file is a video
              return Column(
                children: [
                  StatusPlayer(
                    file: widget.file,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Share.shareFiles(
                            [widget.file.path],
                          );
                        },
                        child: const Icon(Icons.share),
                      ),
                      TextButton(
                        onPressed: () async {
                          showSaveAsDialog(
                            context: context,
                            statusFile: widget.file,
                            statusType: StatusType.video,
                          );
                        },
                        child: const Icon(Icons.save_alt_rounded),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel),
                      ),
                    ],
                  )
                ],
              );
            } else if (widget.file.path.endsWith('.jpg')) {
              // or if its a picture
              return Stack(
                children: [
                  Center(
                    child: Image.file(
                      File(widget.file.path),
                      width: double.infinity,
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                // sharing the status
                                Share.shareFiles(
                                  [widget.file.path],
                                );
                              },
                              child: const Icon(Icons.share),
                            ),
                            TextButton(
                              onPressed: () async {
                                showSaveAsDialog(
                                  context: context,
                                  statusFile: widget.file,
                                  statusType: StatusType.image,
                                );
                              },
                              child: const Icon(Icons.save_alt_rounded),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.cancel),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            } else {
              return const Center(child: Text('Unknown file type'));
            }
          },
        ),
      ),
    );
  }
}

/// this plays the status
class StatusPlayer extends StatefulWidget {
  final File file;
  const StatusPlayer({Key? key, required this.file}) : super(key: key);

  @override
  State<StatusPlayer> createState() => _StatusPlayerState();
}

class _StatusPlayerState extends State<StatusPlayer> {
  late VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path));
    _controller!.initialize().then((_) {
      _controller!.play();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Center(
            child: _controller != null
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : const CircularProgressIndicator(),
          ),
          Column(
            children: [
              Expanded(child: Container()),
              Container(
                height: 50,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Row(
                  children: [
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          _controller!.value.isPlaying
                              ? _controller!.pause()
                              : _controller!.play();
                        });
                      },
                      icon: _controller!.value.isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                    ),
                    PlayerPosIndicator(controller: _controller!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// this shows the position of the video
/// and also you can seek to a specific position
class PlayerPosIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  const PlayerPosIndicator({Key? key, required this.controller})
      : super(key: key);

  @override
  State<PlayerPosIndicator> createState() => _PlayerPosIndicatorState();
}

class _PlayerPosIndicatorState extends State<PlayerPosIndicator> {
  double position = 0;
  double max = 0;

  void _update() {
    int val = widget.controller.value.position.inMilliseconds.toInt();
    int maxVal = widget.controller.value.duration.inMilliseconds.toInt();
    if (val >= 0 && val <= maxVal) {
      setState(() {
        position = val.toDouble();
        max = maxVal.toDouble();
      });
    }
  }

  @override
  void initState() {
    position = widget.controller.value.position.inMilliseconds.toDouble();
    widget.controller.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Slider(
        value: position,
        min: 0,
        max: max,
        onChanged: (double value) {
          widget.controller.seekTo(Duration(milliseconds: value.toInt()));
        },
      ),
    );
  }
}

enum StatusType {
  image,
  video,
}

Future<T> showSaveAsDialog<T>({
  required BuildContext context,
  required File statusFile,
  required StatusType statusType,
}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) => SaveAsPopup(
      statusFile: statusFile,
      statusType: statusType,
    ),
  );
}

class SaveAsPopup extends StatelessWidget {
  final File statusFile;
  final StatusType statusType;
  const SaveAsPopup({
    Key? key,
    required this.statusFile,
    required this.statusType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    Text(
                      'Save to ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Icon(Icons.save_alt),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (statusType == StatusType.image) {
                          await GallerySaver.saveImage(statusFile.path);
                        } else {
                          await GallerySaver.saveVideo(statusFile.path);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saved the statuses'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.photo_sharp),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        String? path = await FilesystemPicker.open(
                          title: 'Save to folder',
                          context: context,
                          rootDirectory: Directory(
                            '/storage/emulated/0/',
                          ),
                          fsType: FilesystemType.folder,
                          pickText: 'Save file to this folder',
                          folderIconColor: Colors.teal,
                        );
                        if (path != null) {
                          Navigator.pop(context);
                          await statusFile.copy(
                            '$path/${statusFile.path.split('/').last}',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved the statuses'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.folder_sharp),
                      label: const Text('Folder'),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
