import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatskit/provider/theme_provider.dart';

/// settings page of the app
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return SafeArea(
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
              // clearing the rendered cache if the user forgot to clear the saved cache
              var renderedCacheDir = Directory(
                  '/storage/emulated/0/Android/data/com.netharuM.whatskit/files/Trimmer');
              if (await renderedCacheDir.exists()) {
                await renderedCacheDir.delete(recursive: true);
              }
            },
          ),
          SettingsOption(
            title: 'Theme',
            subtitle: themeProvider.toString(),
            icon: themeProvider.getThemeMode == ThemeMode.system
                ? Icons.android
                : (themeProvider.getThemeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode),
            onTap: () {
              switch (themeProvider.getThemeMode) {
                case ThemeMode.dark:
                  themeProvider.changeThemeMode(ThemeMode.light);
                  break;
                case ThemeMode.light:
                  themeProvider.changeThemeMode(ThemeMode.system);
                  break;
                case ThemeMode.system:
                  themeProvider.changeThemeMode(ThemeMode.dark);
                  break;
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
    );
  }
}

/// the widget that shows a settings option
class SettingsOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? iconColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const SettingsOption(
      {Key? key,
      required this.title,
      required this.subtitle,
      this.iconColor,
      this.onTap,
      this.icon,
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
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
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
      ),
    );
  }
}

/// about the app page
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
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
          AboutCard(
            title: 'Report a bug',
            subtitle:
                'report an issue you found on this app \nor suggest a new feature',
            icon: const Icon(Icons.bug_report_rounded),
            onTap: () async {
              const url = 'https://github.com/netharuM/whatskit/issues/new';
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

/// showing an option about the app
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
                    Text(title ?? '',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
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
