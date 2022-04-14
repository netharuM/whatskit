import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:whatskit/pages/preview_page.dart';

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

class PreviewFile extends StatelessWidget {
  final File file;
  const PreviewFile({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (file.path.endsWith('.jpg')) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(file.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      );
    } else if (file.path.endsWith('.mp4')) {
      return FutureBuilder(
        future: VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 50,
        ),
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
        file.path,
        style: const TextStyle(color: Colors.white),
      );
    }
  }
}
