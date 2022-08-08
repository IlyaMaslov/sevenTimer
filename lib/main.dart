import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seven/settings.dart';
import 'package:seven/timer.dart';
import 'package:window_manager/window_manager.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(300, 400),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAspectRatio(0.75);
    await windowManager.setPosition(const Offset(1200, 420));

    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seven',
      
      theme: ThemeData(
        
        primarySwatch: Colors.grey
      ),
      //home: const TimerWidget(title: ''),
      initialRoute: "/",
      routes: {
        '/': (context) => const TimerWidget(title: ''),
        '/settings': (context) => const SettingsWidget(title: ''),
        //'/statistics': (context) => const StatisticsWidget(title: '')
      }
    );
  }
}