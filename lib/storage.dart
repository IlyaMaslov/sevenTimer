import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Productivity {
    int done = 0;
    int expectedAmount = 0;
    Productivity(this.done, this.expectedAmount);
}

class BaseProductivityStorage {
  static const String _unsupportedError = "BaseProductivityStorage should be overriden";

  BaseProductivityStorage._ () {
    throw UnsupportedError("Storage should be created by a factory method");
  }

  void incrementProductivity(int expectedAmount) {
    throw UnsupportedError(_unsupportedError);
  }

  int productivityOn(DateTime date) {
    throw UnsupportedError(_unsupportedError);
  }

  int expectedAmountOn(DateTime date) {
    throw UnsupportedError(_unsupportedError);
  }

  List<DateTime> loggedDates() {
    throw UnsupportedError(_unsupportedError);
  }
}

class BaseSettingsStorage {
  static const String _unsupportedError = "BaseSettingsStorage should be overriden";
  
  void setInt(String key, int value) {
    throw UnsupportedError(_unsupportedError);
  }
  int getInt(String key) {
    throw UnsupportedError(_unsupportedError);
  }

  void setString(String key, String value) {
    throw UnsupportedError(_unsupportedError);
  }
  String getString(String key) {
    throw UnsupportedError(_unsupportedError);
  }

  bool exists(String key) {
    throw UnsupportedError(_unsupportedError);
  }
}

class SharedPrefProductivityStorage implements BaseProductivityStorage {
  HashMap<DateTime, Productivity> productivity = HashMap();
  late SharedPreferences _pref;

  static Future<BaseProductivityStorage> init() async {
    SharedPrefProductivityStorage storage = SharedPrefProductivityStorage();
    await storage._initSharedPref();
    await storage._queueProductStorage();
    return storage;
  }
  
  @override
  void incrementProductivity(int expectedAmount) {
    final DateTime currentDateTime = _currentDateTime();
    
    if(!productivity.containsKey(currentDateTime)) {
      productivity[currentDateTime] = Productivity(0, 0);
    }
    productivity[currentDateTime]?.done++;
    productivity[currentDateTime]?.expectedAmount = expectedAmount;
    
    final String currentDate = _currentDate();
    final int done = productivity[currentDateTime]?.done ?? 0;

    if(!_pref.containsKey("firstDate")) {
      _pref.setString("firstDate", currentDate);
    }

    _pref.setString("productivity-$currentDate", "$done/$expectedAmount");
  }

  @override
  List<DateTime> loggedDates() {
    // TODO: implement loggedDates
    throw UnimplementedError();
  }

  @override
  int productivityOn(DateTime date) {
    // TODO: implement productivityOn
    throw UnimplementedError();
  }
  
  @override
  int expectedAmountOn(DateTime date) {
    // TODO: implement expectedAmountOn
    throw UnimplementedError();
  }

  Future<void> _initSharedPref() async {
    _pref = await SharedPreferences.getInstance();
  }

  Future<void> _queueProductStorage() async {
    final String firstLoggedDate = _pref.getString("firstDate") ?? "";
    final DateTime currentDate = _currentDateTime();
    DateTime date = _parseDate(firstLoggedDate) ?? currentDate;
    
    while(date.isBefore(currentDate) || date.isAtSameMomentAs(currentDate)) {
      final String parsedDate = _formatDate(date);
      final String loggedProductivity = _pref.getString("productivity-$parsedDate") ?? "";
      if(loggedProductivity.isNotEmpty) {
        final List<String> productivityParts = loggedProductivity.split('/');
      
        final int done = int.tryParse(productivityParts[0]) ?? 0;
        final int expectedAmount = int.tryParse(productivityParts[1]) ?? 0;
        Productivity parsedProd = Productivity(done, expectedAmount);
        productivity[date] = parsedProd;
      }
      date.add(const Duration(days: 1));
    }
  }

  DateTime _currentDateTime() {
    DateTime nowFull = DateTime.now();
    DateTime nowDate = DateTime(nowFull.year, nowFull.month, nowFull.day);
    return nowDate;
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

class SharedPrefSettingsStorage implements BaseSettingsStorage {
  @override
  bool exists(String key) {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  int getInt(String key) {
    // TODO: implement getInt
    throw UnimplementedError();
  }

  @override
  String getString(String key) {
    // TODO: implement getString
    throw UnimplementedError();
  }

  @override
  void setInt(String key, int value) {
    // TODO: implement setInt
  }

  @override
  void setString(String key, String value) {
    // TODO: implement setString
  }

}