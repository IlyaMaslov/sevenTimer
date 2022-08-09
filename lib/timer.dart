import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seven/contstants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart' as SystemTray;
import 'dart:developer' as developer;


class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TimerWidget> createState() => TimerState();
}

class TimerState extends State<TimerWidget> with RouteAware {
  int _expected = 0;
  int _done = 0;
  int _minutes = 0;
  String _remainingTime = "00:00";
  Stopwatch _stopwatch = Stopwatch();
  late SharedPreferences _pref;

  @override
  void initState() {
    super.initState();
    initSystemTray();
    Timer.periodic(const Duration(seconds: 1), _updateTimerState);
    WidgetsBinding.instance.addPostFrameCallback((_){
      _getSharedPref();
    });
  }

  void _getSharedPref() async {
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _expected = _pref.getInt('expectedAmount') ?? 0;
      _minutes = _pref.getInt('minutes') ?? 0;
      //_done
    });
  }

  void _updateTimerState(Timer timer) {
    final int remainingMinutes = _minutes - _stopwatch.elapsed.inMinutes;
    final int elapsedSeconds = _stopwatch.elapsed.inSeconds - (_stopwatch.elapsed.inMinutes * 60);
    int remainingSeconds = 0;
    if(elapsedSeconds != 0) {
      remainingSeconds = 60 - elapsedSeconds;
    }

    setState(() {
      _remainingTime = "";
      if(remainingMinutes < 10) {
        _remainingTime += '0';
      }
      _remainingTime += remainingMinutes.toString();
      _remainingTime += ':';
      if(remainingSeconds < 10) {
        _remainingTime += '0';
      }
      _remainingTime += remainingSeconds.toString();
    });

    if(remainingMinutes == 0 && remainingSeconds == 0) {
      setState(() {
        _done++;
        _stopwatch.stop();
        _stopwatch.reset();
      });//TODO: do i need to use setState for stopwatch?
      //TODO: add sound alert
    }
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
      SystemTray.MenuItemLable(label: 'Start', onClicked: (menuItem) => _stopwatch.start(), enabled: !_isStoppable()),//TODO: fix this
      SystemTray.MenuItemLable(label: 'Pause', onClicked: (menuItem) => _stopwatch.stop(), enabled: _isStoppable()),
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

  bool _isStoppable() {
    return _stopwatch.isRunning;
  }

  void _updateTimer() {
    setState(() {
      if(_isStoppable()) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle timerStyle =
        ElevatedButton.styleFrom(
          primary: darkBackgroundColor
        );

    const TextStyle timerTextStyle =
        TextStyle(
          fontSize: 60,
          color: darkFontColor
        );
    const TextStyle progressStyle =
        TextStyle(
          fontSize: 50,
          color: darkFontColor
        );
    

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        
      ),
      backgroundColor: darkBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings'); //TODO: make this button a global toggle
                }),
            ),
            ElevatedButton(
              style: timerStyle,
              onPressed: _updateTimer,
              child: Text(
                _remainingTime,
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

  /*@override
  void didPop() {
    stderr.writeln("Did pop");
  }

  @override
  void didPushNext() {
    stderr.writeln("Did push next");
  }

  @override
  void didPush() {
    stderr.writeln("Did push");
    stderr.writeln("Called did push: ${ModalRoute.of(context)?.settings.name.toString()}");
    if(ModalRoute.of(context)?.settings.name == "/") {
      //load settings from shared storage
      final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
        prefs.then((prefsCompl) {
          setState(() {
            _expected = prefsCompl.getInt('expectedAmount')!;//TODO: add null check
            _minutes = prefsCompl.getInt('minutes')!;
          });
        });
    }
  }*/
}