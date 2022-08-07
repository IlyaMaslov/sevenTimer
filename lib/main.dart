import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart' as SystemTray;
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
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _expected = 8;
  int _done = 0;
  int _minCounter = 0;
  int _secCounter = 0;

  @override
  void initState() {
    super.initState();
    initSystemTray();
  }

  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? 'assets/timer.png' : 'assets/timer.png';

    final SystemTray.AppWindow appWindow = SystemTray.AppWindow();
    final SystemTray.SystemTray systemTray = SystemTray.SystemTray();

    await systemTray.initSystemTray(
      iconPath: "assets/timer.ico",
    );

    final SystemTray.Menu menu = SystemTray.Menu();
    await menu.buildFrom([
      SystemTray.MenuItemLable(label: 'Show', onClicked: (menuItem) => appWindow.show()),
      SystemTray.MenuItemLable(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
      SystemTray.MenuItemLable(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
    ]);

    await systemTray.setContextMenu(menu);

    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == SystemTray.kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == SystemTray.kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });
  }

  void _updateTimer() {
    setState(() {
      _done++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle timerStyle =
        ElevatedButton.styleFrom(
          primary: const Color.fromRGBO(40, 40, 40, 1.0)
        );

    const TextStyle timerTextStyle =
        TextStyle(
          fontSize: 60,
          color: Colors.grey
        );
    const TextStyle progressStyle =
        TextStyle(
          fontSize: 50,
          color: Colors.grey
        );
    

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        
      ),
      backgroundColor: const Color.fromRGBO(40, 40, 40, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: timerStyle,
              onPressed: _updateTimer,
              child: Text(
                '$_minCounter:$_secCounter',
                style: timerTextStyle
              ),
            ),
            Text(
              '$_done/$_expected',
              style: progressStyle,
            )
          ],
        ),
      )
    );
  }
}
