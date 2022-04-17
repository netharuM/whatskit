import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.settings,
                      size: 85,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
            const Divider(),
            SettingsOption(
              title: 'Clear rendered cache',
              subtitle:
                  'clears the rendered videos cache \npls dont clear it while sharing a video',
              iconColor: Colors.pink,
              icon: Icons.cleaning_services_rounded,
              onTap: () async {
                var renderedCacheDir = Directory(
                    '/storage/emulated/0/Android/data/com.netharuM.whatskit/files/Trimmer');
                if (await renderedCacheDir.exists()) {
                  await renderedCacheDir.delete(recursive: true);
                }
              },
            ),
            const Divider(),
            SettingsOption(
              title: 'About',
              subtitle: 'about the app',
              iconColor: Colors.blue,
              icon: Icons.info_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? iconColor;
  final IconData? icon;
  final VoidCallback? onTap;
  const SettingsOption(
      {Key? key,
      required this.title,
      required this.subtitle,
      this.iconColor,
      this.onTap,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: icon != null,
              child: Icon(
                icon,
                size: 30,
                color: iconColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        _packageInfo = packageInfo;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.info,
                    size: 85,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'About',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          const Divider(),
          AboutCard(
            title: _packageInfo?.appName ?? 'unknown',
            subtitle: 'App Name',
            icon: const Icon(Icons.title),
          ),
          AboutCard(
            title: 'Version',
            subtitle: _packageInfo?.version ?? 'unknown',
            icon: const Icon(Icons.source_rounded),
          ),
          AboutCard(
            title: 'Build Number',
            subtitle: _packageInfo?.buildNumber ?? 'unknown',
            icon: const Icon(Icons.build_rounded),
          ),
          AboutCard(
            title: 'Author',
            subtitle: '@netharuM',
            onTap: () async {
              const url = 'https://github.com/netharuM';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            icon: const Icon(Icons.person_rounded),
          ),
          AboutCard(
            title: 'Repository',
            subtitle: 'netharuM/whatskit',
            icon: const Icon(Icons.code),
            onTap: () async {
              const url = 'https://github.com/netharuM/whatskit';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
          AboutCard(
            title: 'License',
            subtitle: 'GPL-3.0 License',
            icon: const Icon(Icons.copyright),
            onTap: () async {
              const url =
                  'https://github.com/netharuM/whatskit/blob/master/LICENSE';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
          AboutCard(
            title: 'README',
            subtitle: 'Read more',
            icon: const Icon(Icons.read_more),
            onTap: () async {
              const url =
                  'https://github.com/netharuM/whatskit/blob/master/docs/README.md';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
        ],
      ),
    );
  }
}

class AboutCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Icon? icon;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  const AboutCard(
      {Key? key,
      this.title,
      this.subtitle,
      this.icon,
      this.onTap,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle ?? '',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Visibility(child: icon ?? Container(), visible: icon != null),
            ],
          ),
        ),
      ),
    );
  }
}
