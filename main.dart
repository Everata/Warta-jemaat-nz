import 'package:flutter/material.dart';
import 'screens/editor_screen.dart';

void main() {
  runApp(const WartaApp());
}

class WartaApp extends StatelessWidget {
  const WartaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Warta Jemaat",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F2A44),
      ),
      home: const EditorScreen(),
    );
  }
}
