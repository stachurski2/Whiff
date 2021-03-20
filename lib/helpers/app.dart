import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Whiff/modules/login/LoginPage.dart';
import 'package:Whiff/helpers/app_localizations.dart';

class WhiffApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
