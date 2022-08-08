import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SettingsWidget> createState() => SettingsState();

}

class SettingsState extends State<SettingsWidget> {
  late int expectedAmount;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        
      ),
      backgroundColor: const Color.fromRGBO(40, 40, 40, 1.0),
      body: SettingsList(
              sections: [
                SettingsSection(
                  title: Text('Common'),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: Icon(Icons.language),
                      title: Text('Language'),
                      value: Text('English'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) {},
                      initialValue: true,
                      leading: Icon(Icons.format_paint),
                      title: Text('Enable custom theme'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

}