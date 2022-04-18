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
  bool? isWhatsappInstalled;
  bool? isPermissionGranted;
  List<FileSystemEntity> _statusFiles = [];

  Future<List<FileSystemEntity>> getFileList() async {
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
    isPermissionGranted = await Permission.manageExternalStorage.isGranted;
    if (!isPermissionGranted!) {
      await Permission.manageExternalStorage.request();
    }

    if (!await Directory(
            '/storage/emulated/0/Android/media/com.whatsapp/Whatsapp/Media/.Statuses/')
        .exists()) {
      setState(() {
        isWhatsappInstalled = false;
      });
      return;
    }
    setState(() {
      isWhatsappInstalled = true;
    });

    List<FileSystemEntity> statusFiles = await getFileList();
    setState(() {
      _statusFiles = statusFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isWhatsappInstalled == null || isPermissionGranted == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (!isPermissionGranted!) {
      return GestureDetector(
        onTap: () async {
          PermissionStatus permissionStatus =
              await Permission.manageExternalStorage.request();
          if (permissionStatus == PermissionStatus.granted) {
            await _init();
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const Text(
                  'Permission denied',
                  style: TextStyle(fontSize: 32),
                ),
                const Text(
                  'Please toggle that "Allow access to manage all files" to ON after clicking this',
                  textAlign: TextAlign.center,
                ),
                Text(
                  'tap anywhere to give permission',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (isWhatsappInstalled == false) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.error,
                size: 200,
              ),
              Text(
                'Looks like whatsapp is not installed',
                style: TextStyle(fontSize: 20),
              ),
              Text('if you have whatsapp pls report this issue'),
              Text('at Settings > About > Report a bug'),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: RefreshIndicator(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onRefresh: _init,
          child: _statusFiles.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.explore_rounded,
                      size: 200,
                    ),
                    Center(
                      child: Text('Looks like there is nothing'),
                    ),
                  ],
                )
              : GridView.count(
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
}
