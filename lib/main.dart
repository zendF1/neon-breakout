import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/views/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock device orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style to match game dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F0E17),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const NeonBreakoutApp());
}

class NeonBreakoutApp extends StatelessWidget {
  const NeonBreakoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Breakout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Outfit', // A modern geometric font (will fallback gracefully if not found)
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
