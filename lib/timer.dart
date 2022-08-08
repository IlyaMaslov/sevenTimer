import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart' as SystemTray;

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TimerWidget> createState() => TimerState();
}

class TimerState extends State<TimerWidget> {
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
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.black
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                }),
            ),
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