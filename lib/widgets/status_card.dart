import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:whatskit/pages/status_preview_page.dart';

class WhatsappStatusCard extends StatelessWidget {
  final FileSystemEntity file;
  const WhatsappStatusCard({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).cardColor,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PreviewFile(
              file: File(file.path),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => PreviewPage(
                      file: File(file.path),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewFile extends StatefulWidget {
  final File file;
  const PreviewFile({Key? key, required this.file}) : super(key: key);

  @override
  State<PreviewFile> createState() => _PreviewFileState();
}

class _PreviewFileState extends State<PreviewFile> {
  Uint8List? _thumbnail;

  Future<Uint8List?> get getVidThumbNail async =>
      _thumbnail ??= await VideoThumbnail.thumbnailData(
        video: widget.file.path,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.file.path.endsWith('.jpg')) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(widget.file.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      );
    } else if (widget.file.path.endsWith('.mp4')) {
      return FutureBuilder(
        future: getVidThumbNail,
        builder: (context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return Text(
        widget.file.path,
        style: const TextStyle(color: Colors.white),
      );
    }
  }
}
