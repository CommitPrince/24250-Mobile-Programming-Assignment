import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../generated/l10n.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings_account),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text(S.of(context).dark_mode),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text(S.of(context).language),
            trailing: DropdownButton<String>(
              value: Localizations.localeOf(context).languageCode,
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('language', newValue);
                  MyApp.setLocale(context, Locale(newValue));
                }
              },
              items: <String>['en', 'fr'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_getLanguageName(value)),
                );
              }).toList(),
            ),
          ),
          // Add more settings options here
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return languageCode;
    }
  }
}