import 'package:flutter/material.dart';
import 'package:whatskit/pages/settings_page.dart';
import 'package:whatskit/pages/statuses_page.dart';
import 'package:whatskit/pages/video_timmer.dart';
import 'package:whatskit/provider/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const Application());
}

// main app
class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      builder: (context, _) {
        final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          title: 'Whatskit',
          themeMode: themeProvider.getThemeMode,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          home: const App(),
        );
      },
    );
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
          ),
          child: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.video_collection_rounded),
                      SizedBox(width: 8),
                      Text('statuses'),
                    ]),
              ),
              Tab(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cut),
                      SizedBox(width: 8),
                      Text('trimmer'),
                    ]),
              ),
              Tab(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('settings'),
                    ]),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [
          StatusesPage(),
          VideoTrimmerPage(),
          SettingsPage(),
        ]),
      ),
    );
  }
}
