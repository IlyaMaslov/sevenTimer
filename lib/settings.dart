import 'dart:io';

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:seven/contstants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SettingsWidget> createState() => SettingsState();

}

class SettingsState extends State<SettingsWidget> {
  late SharedPreferences _pref;
  int _expectedAmount = 0;
  int _minutes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _getSharedPref();
    });
  }

  void _getSharedPref() async {
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _expectedAmount = _pref.getInt('expectedAmount') ?? 0;
      _minutes = _pref.getInt('minutes') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        
      ),
      backgroundColor: darkBackgroundColor,
      body: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Common'),
                  tiles: <AbstractSettingsTile>[
                    CustomSettingsTile(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Expected sessions',
                        ),
                        controller: TextEditingController()..text = _expectedAmount.toString(),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          if(int.parse(value, onError: (e) => -1) <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        
                        onChanged: (value) {
                          _expectedAmount = int.parse(value);
                          _pref.setInt('expectedAmount', _expectedAmount);
                        }
                      )
                    ),
                    CustomSettingsTile(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Expected session time',
                        ),
                        controller: TextEditingController()..text = _minutes.toString(),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          if(int.parse(value, onError: (e) => -1) <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _minutes = int.parse(value);
                          _pref.setInt('minutes', _minutes);
                        }
                      )
                    ),
                  ],
                ),
              ],
            ),
    );
  }

}