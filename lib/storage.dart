import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:seven/timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Productivity {
    int done = 0;
    int expectedAmount = 0;
    Productivity(this.done, this.expectedAmount);
}

abstract class AbstractStorage {
  
  @protected
  HashMap<DateTime, Productivity> productivity = HashMap();

  AbstractStorage() {
    //queueProductStorage();
  }
  
  void incrementProductivity({required int done, required int expectedAmount}) {
    DateTime now = currentDateTime();
    
    if(!productivity.containsKey(now)) {
      productivity[now] = Productivity(0, 0);
    }
    productivity[now]?.done++;
    productivity[now]?.expectedAmount = expectedAmount;
    
    incProductStorage(expectedAmount);
  }

  int currentProductivity();
  
  int productivityOn(DateTime date) {
    return 0;
  }

  int expectedAmountOn(DateTime date) {
    return 0;
  }

  Future<void> push(String key, String value);
  Future<String?> queue(String key);

  @protected
  Future<void> incProductStorage(int expectedAmount);
  @protected
  Future<void> queueProductStorage();

  @protected
  DateTime currentDateTime() {
    DateTime nowFull = DateTime.now();
    DateTime nowDate = DateTime(nowFull.year, nowFull.month, nowFull.day);
    return nowDate;
  }

}

class SharedPreferencesStorage extends AbstractStorage {
  late SharedPreferences _pref;

  SharedPreferencesStorage._init();
  
  static Future<SharedPreferencesStorage> init() async {
    SharedPreferencesStorage storage = SharedPreferencesStorage._init();
    await storage._initSharedPref();
    await storage.queueProductStorage();
    return storage;
  }

  @override
  int currentProductivity() {
    final String currentDate = _currentDate();
    final String productivity = _pref.getString('productivity-$currentDate') ?? "0/0";
    final String productivityFirstHalf = productivity.split('/')[0];
    return int.tryParse(productivityFirstHalf) ?? 0;
  }
  
  @override
  Future<void> incProductStorage(int expectedAmount) async {
    final String currentDate = _currentDate();
    final DateTime currentDateTime = super.currentDateTime();
    final int done = super.productivity[currentDateTime]?.done ?? 0;

    if(!_pref.containsKey("firstDate")) {
      _pref.setString("firstDate", currentDate);
    }

    _pref.setString("productivity-$currentDate", "$done/$expectedAmount");
  }
  
  @override
  Future<void> queueProductStorage() async {
    if(_pref.containsKey("firstDate")) {
      final String firstLoggedDate = _pref.getString("firstDate") ?? "";
      final DateTime currentDate = super.currentDateTime();
      DateTime date = _parseDate(firstLoggedDate) ?? currentDate;
    
      while(!date.isAfter(currentDate)) {
        
        stdout.writeln('looking for statistics for prev days: ' + date.toString());
        
        final String parsedDate = _formatDate(date);
        final String loggedProductivity = _pref.getString("productivity-$parsedDate") ?? "";
        if(loggedProductivity.isNotEmpty) {
          final List<String> productivityParts = loggedProductivity.split('/');
      
          final int done = int.tryParse(productivityParts[0]) ?? 0;
          final int expectedAmount = int.tryParse(productivityParts[1]) ?? 0;
          Productivity parsedProd = Productivity(done, expectedAmount);
          super.productivity[date] = parsedProd;
        }
        date = date.add(const Duration(days: 1));
      }
    }
    return;
  }
  
  @override
  Future<void> push(String key, String value) async {
    _pref.setString(key, value);
  }
  
  @override
  Future<String?> queue(String key) async {
    return _pref.getString(key);
  }

  Future<void> _initSharedPref() async {
    _pref = await SharedPreferences.getInstance();
  }

  String _formatDate(DateTime date) {
    String formattedDate = '${date.year}-${date.month}-${date.day}';
    return formattedDate;
  }

  String _currentDate() {
    var now = DateTime.now();
    String currentDate = '${now.year}-${now.month}-${now.day}';
    return currentDate;
  }

  DateTime? _parseDate(String date) {
    List<String> dateParts = date.split('-');
    int year = int.tryParse(dateParts[0]) ?? 0;
    int month = int.tryParse(dateParts[1]) ?? 0;
    int day = int.tryParse(dateParts[2]) ?? 0;
    
    if(year > 0 && month > 0 && day > 0) {
      DateTime parsedDate = DateTime(year, month, day);
      return parsedDate;
    }

    return null;
  }
}

class CSVStorage extends AbstractStorage {
  late File _file;

  CSVStorage._init(String filePath) {
    _file = File(filePath);
  }

  static Future<CSVStorage> init(String filePath) async {
    CSVStorage storage = CSVStorage._init(filePath);
    await storage._initFile();
    await storage.queueProductStorage();
    return storage;
  }
  
  @override
  int currentProductivity() {
    final String currentDate = _currentDate();
    final String productivity = _getValueByKey('productivity-$currentDate') ?? '0/0';
    final String productivityFirstHalf = productivity.split('/')[0];
    return int.tryParse(productivityFirstHalf) ?? 0;
  }

  @override
  Future<void> incProductStorage(int expectedAmount) async {
    final String currentDate = _currentDate();
    final DateTime currentDateTime = super.currentDateTime();
    final int done = super.productivity[currentDateTime]?.done ?? 0;

    if (!_containsKey('firstDate')) {
      _setValueByKey('firstDate', currentDate);
    }

    _setValueByKey('productivity-$currentDate', '$done/$expectedAmount');
  }
  
  @override
  Future<void> queueProductStorage() async {
    if (_containsKey('firstDate')) {
      final String firstLoggedDate = _getValueByKey('firstDate') ?? '';
      final DateTime currentDate = super.currentDateTime();
      DateTime date = _parseDate(firstLoggedDate) ?? currentDate;

      while (!date.isAfter(currentDate)) {
        stdout.writeln('looking for statistics for previous days: $date');

        final String parsedDate = _formatDate(date);
        final String loggedProductivity = _getValueByKey('productivity-$parsedDate') ?? '';
        if (loggedProductivity.isNotEmpty) {
          final List<String> productivityParts = loggedProductivity.split('/');

          final int done = int.tryParse(productivityParts[0]) ?? 0;
          final int expectedAmount = int.tryParse(productivityParts[1]) ?? 0;
          Productivity parsedProd = Productivity(done, expectedAmount);
          super.productivity[date] = parsedProd;
        }
        date = date.add(const Duration(days: 1));
      }
    }
  }
  
  @override
  Future<void> push(String key, String value) async {
    final String line = '$key,$value\n';
    await _file.writeAsString(line, mode: FileMode.append);
  }
  
  @override
  Future<String?> queue(String key) async {
    final List<String> lines = await _file.readAsLines();
    for (final line in lines) {
      final List<String> parts = line.split(',');
      if (parts.isNotEmpty && parts[0] == key) {
        return parts[1];
      }
    }
    return null;
  }

  Future<void> _initFile() async {
    if (!await _file.exists()) {
      await _file.create(recursive: true);
    }
  }

  bool _containsKey(String key) {
    final List<String> lines = _file.readAsLinesSync();
    for (final line in lines) {
      final List<String> parts = line.split(',');
      if (parts.isNotEmpty && parts[0] == key) {
        return true;
      }
    }
    return false;
  }

  String? _getValueByKey(String key) {
    final List<String> lines = _file.readAsLinesSync();
    for (final line in lines) {
      final List<String> parts = line.split(',');
      if (parts.isNotEmpty && parts[0] == key) {
        return parts[1];
      }
    }
    return null;
  }

  void _setValueByKey(String key, String value) {
    final List<String> lines = _file.readAsLinesSync();
    final StringBuffer newContent = StringBuffer();
    bool keyFound = false;

    for (final line in lines) {
      final List<String> parts = line.split(',');
      if (parts.isNotEmpty && parts[0] == key) {
        newContent.write('$key,$value\n');
        keyFound = true;
      } else {
        newContent.write('$line\n');
      }
    }

    if (!keyFound) {
      newContent.write('$key,$value\n');
    }

    _file.writeAsStringSync(newContent.toString());
  }

  String _formatDate(DateTime date) {
    String formattedDate = '${date.year}-${date.month}-${date.day}';
    return formattedDate;
  }

  String _currentDate() {
    var now = DateTime.now();
    String currentDate = '${now.year}-${now.month}-${now.day}';
    return currentDate;
  }

  DateTime? _parseDate(String date) {
    List<String> dateParts = date.split('-');
    int year = int.tryParse(dateParts[0]) ?? 0;
    int month = int.tryParse(dateParts[1]) ?? 0;
    int day = int.tryParse(dateParts[2]) ?? 0;

    if (year > 0 && month > 0 && day > 0) {
      DateTime parsedDate = DateTime(year, month, day);
      return parsedDate;
    }

    return null;
  }

}

class HttpStorage extends AbstractStorage {
  late String ip;
  
  @override
  int currentProductivity() {
    // TODO: implement currentProductivity
    throw UnimplementedError();
  }
  
  @override
  Future<void> incProductStorage(int expectedAmount) {
    // TODO: implement incProductStorage
    throw UnimplementedError();
  }
  
  @override
  Future<void> queueProductStorage() {
    // TODO: implement queueProductStorage
    throw UnimplementedError();
  }
  
  @override
  Future<void> push(String key, String value) {
    // TODO: implement push
    throw UnimplementedError();
  }
  
  @override
  Future<String> queue(String key) {
    // TODO: implement queue
    throw UnimplementedError();
  }

}

class StorageBuilder {
  
}