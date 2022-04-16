import 'package:flutter/material.dart';
import 'package:whatskit/pages/statuses_page.dart';
import 'package:whatskit/pages/video_timmer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: generateMaterialColorFromColor(const Color(0xff00a884)),
        scaffoldBackgroundColor: const Color(0xff111b21),
        backgroundColor: const Color(0xff111b21),
        cardColor: const Color(0xff202c33),
        primaryColor: const Color(0xff00a884),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: const Color(0xff00a884)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xff202c33),
          selectedItemColor: const Color(0xff00a884),
          unselectedItemColor: Colors.white.withOpacity(0.5),
        ),
      ),
      home: const App(),
    );
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const StatusesPage(),
    const VideoTrimmerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'statuses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cut_rounded),
            label: 'trimmer',
          ),
        ],
        currentIndex: _pageIndex,
        onTap: (int index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}

MaterialColor generateMaterialColorFromColor(Color color) {
  return MaterialColor(color.value, {
    50: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
    100: Color.fromRGBO(color.red, color.green, color.blue, 0.2),
    200: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
    300: Color.fromRGBO(color.red, color.green, color.blue, 0.4),
    400: Color.fromRGBO(color.red, color.green, color.blue, 0.5),
    500: Color.fromRGBO(color.red, color.green, color.blue, 0.6),
    600: Color.fromRGBO(color.red, color.green, color.blue, 0.7),
    700: Color.fromRGBO(color.red, color.green, color.blue, 0.8),
    800: Color.fromRGBO(color.red, color.green, color.blue, 0.9),
    900: Color.fromRGBO(color.red, color.green, color.blue, 1.0),
  });
}
