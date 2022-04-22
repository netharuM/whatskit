import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatskit/widgets/status_card.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// this is like a middleware
/// different android versions use different type of permissions for the same thing
/// in this case android 11 needs the manageExternalStorage permission to work
class _Permissions {
  late AndroidDeviceInfo _androidDeviceInfo;
  int? androidVersion;

  _Permissions() {
    _init();
  }

  /// returns ```true``` if the permission is granted
  Future<bool> get isGranted async {
    if (androidVersion == null) {
      _androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
      androidVersion = int.parse(_androidDeviceInfo.version.release ?? '0');
    }
    if (androidVersion! < 11) {
      return true;
    } else {
      return await Permission.manageExternalStorage.isGranted;
    }
  }

  /// requests permissions if they have not been granted
  Future<PermissionStatus> requestIfNotFound() async {
    if (await isGranted == false) {
      return await requestPermission();
    } else {
      return PermissionStatus.granted;
    }
  }

  /// requests permissions
  Future<PermissionStatus> requestPermission() async {
    return await Permission.manageExternalStorage.request();
  }

  /// async init function of the class
  Future<void> _init() async {
    _androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    androidVersion = int.parse(_androidDeviceInfo.version.release ?? '0');
    requestIfNotFound();
  }
}

/// page that shows the statuses
class StatusesPage extends StatefulWidget {
  const StatusesPage({Key? key}) : super(key: key);

  @override
  State<StatusesPage> createState() => _StatusesPageState();
}

class _StatusesPageState extends State<StatusesPage> {
  bool? isWhatsappInstalled;
  bool? isPermissionGranted;

  /// list of statuses
  List<FileSystemEntity>? _statusFiles;
  final _Permissions _permissions = _Permissions();

  // returns a list of Status files from the statuses dir
  Future<List<FileSystemEntity>> getFileList() async {
    /// dir that has all the statuses
    Directory dir = Directory(
        '/storage/emulated/0/Android/media/com.whatsapp/Whatsapp/Media/.Statuses/');
    List<FileSystemEntity> fileList = await dir.list(recursive: false).toList();
    // we only wants the media files
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
    isPermissionGranted = await _permissions.isGranted;

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
    if (isWhatsappInstalled == null ||
        isPermissionGranted == null ||
        _statusFiles == null) {
      // showing a loading circle while everything is verifying
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (!isPermissionGranted!) {
      // if we dont have the permission
      // we display a screen so the user can grant it
      return GestureDetector(
        onTap: () async {
          PermissionStatus permissionGranted =
              await _permissions.requestPermission();
          if (permissionGranted == PermissionStatus.granted) {
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
      // the screen that we show if the whatsapp isn't installed
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
      // if every thing is oky we show the page
      return Scaffold(
        body: RefreshIndicator(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onRefresh: _init,
          child: _statusFiles!.isEmpty
              ? Column(
                  // when there are no statuses
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
                    for (int i = 0; i < _statusFiles!.length; i++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WhatsappStatusCard(
                          elevation: 10,
                          file: _statusFiles![i],
                        ),
                      ),
                  ],
                ),
        ),
      );
    }
  }
}
