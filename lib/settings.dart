import 'dart:io';

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:seven/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SettingsWidget> createState() => SettingsState();

}

class SettingsState extends State<SettingsWidget> {
  int _expectedAmount = 0;
  int _minutes = 0;
  late SharedPreferences _pref;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _initSharedPref();
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
                    _numInputTile(
                      hintText: 'Expected sessions',
                      initialValue: _expectedAmount,
                      key: "expectedAmount"
                    ),
                    _numInputTile(
                      hintText: 'Expected sessions time',
                      initialValue: _minutes,
                      key: "minutes"
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void _initSharedPref() async {
    _pref = await SharedPreferences.getInstance();
    setState(() {
      _expectedAmount = _pref.getInt('expectedAmount') ?? 0;
      _minutes = _pref.getInt('minutes') ?? 0;
    });
  }

  CustomSettingsTile _numInputTile({
    String hintText = '',
    required int initialValue,
    required String key
  }) {
    return CustomSettingsTile(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
          ),
          controller: TextEditingController()..text = initialValue.toString(),
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
            final int updatedValue = int.tryParse(value) ?? 0;
            _pref.setInt(key, updatedValue);
          }
        )
      );
  }
}