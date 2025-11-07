import 'package:flutter/material.dart';
import 'package:proxishare/local_share_app.dart';

import 'package:proxishare/themes.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Share',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(title: const Center(child: Text('ProxiShare'))),
        body: Center(child: LocalShareApp()),
      ),
    );
  }
}
