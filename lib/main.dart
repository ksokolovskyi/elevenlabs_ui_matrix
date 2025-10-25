import 'package:elevenlabs_ui_matrix/matrix_demo_screen.dart';
import 'package:elevenlabs_ui_matrix/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: DemoTheme.light,
      highContrastTheme: DemoTheme.light,
      darkTheme: DemoTheme.dark,
      highContrastDarkTheme: DemoTheme.dark,
      home: Stack(
        children: [
          const Positioned.fill(
            child: MatrixDemoScreen(),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              child: ThemeModePicker(
                themeMode: _themeMode,
                onChanged: (themeMode) {
                  setState(() {
                    _themeMode = themeMode;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
