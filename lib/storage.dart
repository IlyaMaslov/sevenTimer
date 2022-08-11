import 'dart:collection';
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

/*abstract class AbstractStorage {
  
  Future<void> push(String key, String value);
  Future<String> queue(String key);
}

abstract class AbstractProductivityStorage extends AbstractStorage {
  @protected
  late HashMap<DateTime, Productivity> productivity;

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

abstract class AbstractSettingsStorage extends AbstractStorage {
  void pushInt(String key, int value);
  void pushBool(String key, bool value);
  void pushString(String key, String value);
  void pushDouble(String key, double value);

  int queueInt(String key);
  bool queueBool(String key);
  String queueString(String key);
  double queueDouble(String key);
}

class SharedPreferences

class SharedPreferencesStorage extends AbstractStorage {
  late SharedPreferences _pref;

  SharedPreferencesStorage() {
    _initSharedPref();
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
    final String firstLoggedDate = _pref.getString("firstDate") ?? "";
    final DateTime currentDate = super.currentDateTime();
    DateTime date = _parseDate(firstLoggedDate) ?? currentDate;
    
    while(date.isBefore(currentDate) || date.isAtSameMomentAs(currentDate)) {
      final String parsedDate = _formatDate(date);
      final String loggedProductivity = _pref.getString("productivity-$parsedDate") ?? "";
      if(loggedProductivity.isNotEmpty) {
        final List<String> productivityParts = loggedProductivity.split('/');
      
        final int done = int.tryParse(productivityParts[0]) ?? 0;
        final int expectedAmount = int.tryParse(productivityParts[1]) ?? 0;
        Productivity parsedProd = Productivity(done, expectedAmount);
        super.productivity[date] = parsedProd;
      }
      date.add(const Duration(days: 1));
    }
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

}*/

//----------------------------------------------------------------------------------

enum StorageOption {
  SHARED_PREFERENCES,
  CSV,
  HTTP_SERVER
}

abstract class AbstractStorageFactory {

}

class SettingsStorageFactory implements AbstractStorageFactory {

}

class ProductivityStorageFactory implements AbstractStorageFactory {

}

class Storage {
//push throw if called
//queue
}

//it means that for each storage type i will need three classes
//it will indeed help me move each layer of abstraction over storage in different classes
//but it will be hard to read with all of them in the same file
class SharedPreferencesStorage implements Storage {

}

class ProductivitySPStorage extends SharedPreferencesStorage {
//it means that all productivity fields must be operated with the same logic
}