import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seven/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart' as SystemTray;


class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TimerWidget> createState() => TimerState();
}

class TimerState extends State<TimerWidget> with RouteAware {
  int _expectedAmount = 0;
  int _done = 0;
  int _minutes = 0;
  String _remainingTime = "00:00";
  Stopwatch _stopwatch = Stopwatch();
  late SharedPreferences _pref;

  @override
  void initState() {
    super.initState();
    _initSystemTray();
    _initSharedPref();
    _initUpdateTimer();
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
      body: /*Center(
        child:*/ Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              '$_done/$_expectedAmount',
              style: progressStyle,
            )
          ],
        ),
      //)
    );
  }

  Future<void> _initSystemTray() async {
    final String path =
        Platform.isWindows ? 'assets/timer.ico' : 'assets/timer.png';

    final SystemTray.AppWindow appWindow = SystemTray.AppWindow();
    final SystemTray.SystemTray systemTray = SystemTray.SystemTray();

    await systemTray.initSystemTray(
      iconPath: path,
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
      if (eventName == SystemTray.kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == SystemTray.kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });
  }

  void _updateTimerState(Timer timer) {
    final int elapsedSeconds = _stopwatch.elapsed.inSeconds - (_stopwatch.elapsed.inMinutes * 60);
    int remainingMinutes = _minutes - _stopwatch.elapsed.inMinutes;
    int remainingSeconds = 0;
    if(elapsedSeconds != 0) {
      remainingSeconds = 60 - elapsedSeconds;
      remainingMinutes--;
    }

    String remainingTime = "";
    if(remainingMinutes < 10) {
      remainingTime += '0';
    }
    remainingTime += remainingMinutes.toString();
    remainingTime += ':';
    if(remainingSeconds < 10) {
      remainingTime += '0';
    }
    remainingTime += remainingSeconds.toString();

    setState(() {
      _remainingTime = remainingTime;
    });

    if(remainingMinutes == 0 && remainingSeconds == 0) {
      setState(() {
        _done++;
        _stopwatch.stop();
        _stopwatch.reset();
        _updateStatisticsInfo();
      });//TODO: do i need to use setState for stopwatch?
      //TODO: add sound alert
    }

    tryUpdateTimer();
  }

  Future<void> _initSharedPref() async {
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _expectedAmount = int.parse(_pref.getString('expectedAmount') ?? '0');
      _minutes = _pref.getInt('minutes') ?? 0;
      
      final String currentDate = _currentDate();
      final String productivity = _pref.getString('productivity-$currentDate') ?? "0/0";
      final String productivityFirstHalf = productivity.split('/')[0];
      _done = int.tryParse(productivityFirstHalf) ?? 0;
    });
  }

  void _initUpdateTimer() {
    Timer.periodic(const Duration(seconds: 1), _updateTimerState);
  }

  //TODO: should replace it with a proper notify systems
  Future<void> tryUpdateTimer() async {
    int expectedAmount = _pref.getInt('expectedAmount') ?? -1;
    int minutes = _pref.getInt('minutes') ?? -1;
    if(_expectedAmount != expectedAmount && expectedAmount > -1 ||
      _minutes != minutes && minutes > -1) {
        setState(() {
          _expectedAmount = expectedAmount;
          _minutes = minutes;
        });
      }
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

  //TODO: should add private options for storing statistics
  Future<void> _updateStatisticsInfo() async {
    final String currentDate = _currentDate();

    if(!_pref.containsKey("firstDate")) {
      _pref.setString("firstDate", currentDate);
    }

    _pref.setString("productivity-$currentDate", "$_done/$_expectedAmount");
  }

  String _currentDate() {
    var now = DateTime.now();
    String currentDate = '${now.year}-${now.month}-${now.day}';
    return currentDate;
  }
}