import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:Whiff/modules/login/LoginPage.dart';
import 'package:Whiff/helpers/app_localizations.dart';

class WhiffApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whiff',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        supportedLocales: [
          Locale('en', 'US'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) {
           return  Locale('en', 'US');
        },
      home: LoginPage()
    );
  }
}
