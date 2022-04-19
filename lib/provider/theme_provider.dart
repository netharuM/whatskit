import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// providing the theme mode
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _init();
  }

  /// the theme mode
  ThemeMode _themeMode = ThemeMode.system; // theme by default
  late final SharedPreferences _prefs;

  void _init() async {
    _prefs = await SharedPreferences.getInstance();
    String? _themeMode = _prefs.getString('themeMode');
    if (_themeMode != null) {
      fromString(_themeMode);
    } else {
      _prefs.setString('themeMode', toString());
    }
  }

  /// sets the theme mode from a string
  void fromString(String themeModeStr) {
    assert(
      themeModeStr == 'system' ||
          themeModeStr == 'light' ||
          themeModeStr == 'dark',
      'themeModeStr must be system, light or dark',
    );
    switch (themeModeStr) {
      case 'system':
        _themeMode = ThemeMode.system;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
    }
    _prefs.setString('themeMode', themeModeStr);
    notifyListeners();
  }

  /// converts the theme mode to a string
  /// usefull when saving the theme
  @override
  String toString() {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  /// returns the current theme mode
  ThemeMode get getThemeMode => _themeMode;

  /// sets the theme mode
  void changeThemeMode(ThemeMode theme) {
    _themeMode = theme;
    _prefs.setString('themeMode', toString());
    notifyListeners();
  }
}

class AppThemes {
  static final lightTheme = ThemeData(
    primarySwatch: generateMaterialColorFromColor(const Color(0xff008069)),
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: const Color(0xff008069),
    cardColor: Colors.white,
    primaryColor: const Color(0xff008069),
    tabBarTheme: TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.5),
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    ),
    textTheme: TextTheme(
      titleMedium: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(color: Colors.black.withOpacity(0.8)),
      labelLarge: TextStyle(color: Colors.black.withOpacity(0.5)),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xff008069),
    ),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.black,
    ),
    dividerColor: Colors.grey,
  );

  static final darkTheme = ThemeData(
    primarySwatch: generateMaterialColorFromColor(const Color(0xff00a884)),
    scaffoldBackgroundColor: const Color(0xff111b21),
    backgroundColor: const Color(0xff202c33),
    cardColor: const Color(0xff202c33),
    primaryColor: const Color(0xff00a884),
    textTheme: TextTheme(
      titleMedium: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.8)),
      labelLarge: TextStyle(color: Colors.white.withOpacity(0.5)),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xff00a884),
    ),
    dividerColor: Colors.white,
  );
}

/// generates a [MaterialColor] from a [Color]
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
