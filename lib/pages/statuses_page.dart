import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatskit/widgets/status_card.dart';

class StatusesPage extends StatefulWidget {
  const StatusesPage({Key? key}) : super(key: key);

  @override
  State<StatusesPage> createState() => _StatusesPageState();
}

class _StatusesPageState extends State<StatusesPage> {
  List<FileSystemEntity> _statusFiles = [];

  Future<List<FileSystemEntity>> getFileList() async {
    final bool permissionStatus =
        await Permission.manageExternalStorage.isGranted;
    if (!permissionStatus) {
      await Permission.manageExternalStorage.request();
    }
    Directory dir = Directory(
        '/storage/emulated/0/Android/media/com.whatsapp/Whatsapp/Media/.Statuses/');
    List<FileSystemEntity> fileList = await dir.list(recursive: false).toList();
    return fileList.where((element) {
      return element.path.endsWith('.mp4') || element.path.endsWith('.jpg');
    }).toList();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    List<FileSystemEntity> statusFiles = await getFileList();
    setState(() {
      _statusFiles = statusFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onRefresh: _init,
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            for (int i = 0; i < _statusFiles.length; i++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WhatsappStatusCard(
                  elevation: 10,
                  file: _statusFiles[i],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
