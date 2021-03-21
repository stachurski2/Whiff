import 'dart:async';
import 'package:Whiff/modules/onboarding/OnboardingPage.dart';
import 'package:Whiff/modules/historical/HistoricalPage.dart';
import 'package:Whiff/modules/accountSettings/AccountSettingsViewModel.dart';
import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:Whiff/helpers/app_localizations.dart';
import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/model/Sensor.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';


class AccountSettingsPage extends StatefulWidget {
  @override
  AccountSettingsPageState createState() => AccountSettingsPageState();
}

class AccountSettingsPageState  extends State<AccountSettingsPage> {
  final double _kStandardViewInset = 20;
  final double _kButtonCornerRadius = 10;
  final AutheticatingServicing authenticationService = AutheticationService.shared;

  AccountSettingsViewModelContract _viewModel = AccountSettingsViewModel();

  StreamSubscription onboardingState;

  StreamSubscription sensorListSubscription;

  StreamSubscription sensorListErrorSubscription;

  bool _didLoadSensors = false;
  var _sensors = List<Sensor>();

  @override
  void initState() {
    super.initState();
    onboardingState = _viewModel.currentAuthState().listen((state) {
      if (state.signedIn == false) {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
      }
    });

    sensorListSubscription = _viewModel.sensorsList().listen((sensorList) {
      this.setState(() {
        this._didLoadSensors = true;
        this._sensors = sensorList;
      });
    });

    sensorListErrorSubscription =
        _viewModel.sensorsListFetchError().listen((error) {

        });

    _viewModel.fetchSensors();

  }

  @override
  void deactivate() {
    this.onboardingState.cancel();
    super.deactivate();
  }


  Widget build(BuildContext context) {

    Widget sensorListView() {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        itemCount: _sensors.length,
        itemBuilder: (BuildContext context, int index) {
          return
            GestureDetector(child:
            Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(
                        color: ColorProvider.shared
                            .standardAppButtonBorderColor),
                        top: BorderSide(
                            color: index == 0 ? ColorProvider.shared
                                .standardAppButtonBorderColor : Colors
                                .transparent)),
                    color: ColorProvider.shared.sensorCellBackgroundColor),
                child:
                Column(
                  children: [
                    SizedBox(height: 10),

                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [ Text( _sensors[index].name,
                            style: TextStyle(fontSize: 22,
                                fontFamily: 'Poppins')),
                        ]),
                    SizedBox(height: 10)

                  ],)
            ),
              onTap: () =>
              {

              },
            );
        },);
    }

    return WillPopScope(child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
              color: ColorProvider.shared.standardAppLeftMenuBackgroundColor)),
      body:
      SingleChildScrollView(child: Column(
        children: [
          SizedBox(height: 40),
          Row(children: [ SizedBox(width: 60), Text(AppLocalizations.of(context).translate('account_settings_top_label_text'),

            style: TextStyle(color: Colors.black,
                fontSize: 22,
                fontFamily: 'Poppins')),],),
          Row(children: [ SizedBox(width: 60), Text(authenticationService.signedInEmail(),
              style: TextStyle(color: ColorProvider.shared.standardAppButtonColor,
                  fontSize: 16,
                  fontFamily: 'Poppins')),],),
          SizedBox(height: 10),

          Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [ Text(AppLocalizations.of(context).translate('account_settings_change_password_label_text'),
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Poppins')),
            ],),
          SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: _kStandardViewInset),
                Expanded(child: TextFormField(
                  obscureText: true,
                  onEditingComplete: (){

                  },

                  onChanged: (value){

                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('account_settings_new_password_textfield_label'),
                  ),
                )),
                SizedBox(width: _kStandardViewInset)
              ]
          ),
          SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: _kStandardViewInset),
                Expanded(child: TextFormField(
                //    focusNode:  _firstFocusNode,
                    onChanged: (value){
                      // _viewModel.setPassword(value);
                    },
                    onEditingComplete: ()  async {

                    },
                //    controller: _secondTextfieldController,
                    obscureText: true,
                    decoration: InputDecoration(
                //      errorText: _loginMessage,
                      hintText: AppLocalizations.of(context).translate('account_settings_new_password_confirm_textfield_label'),
                    )
                )
                ),
                SizedBox(width: _kStandardViewInset),
              ]
          ),
          SizedBox(height: 10),
        Row(
          children: <Widget>[
            SizedBox(width: 20),
            Expanded(child:
          RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kButtonCornerRadius),
                side: BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor),
              ),
              onPressed: () {
              //  _currentPageState == LoginViewState.loginUser ? this._viewModel.registerUser() : this._viewModel.requestRegisterUser();
              },
              color: ColorProvider.shared.standardAppButtonColor,
              textColor: ColorProvider.shared.standardAppButtonTextColor,
              child: Text(
                  AppLocalizations.of(context).translate('account_setting_change_password_button_text')
              )
          )
            ),
            SizedBox(width: 10),
          ]),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [ Text(AppLocalizations.of(context).translate('account_setting_your_sensors_label_text'),
                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'Poppins')),
            ],),
          SizedBox(height: 20),
          _didLoadSensors == true ? sensorListView(): LoadingIndicator(),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [ Text(AppLocalizations.of(context).translate('account_setting_missing_errors_label_text'),
                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'Poppins')),
            ],),
          SizedBox(height: 10),
          Row(
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(child:
                RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kButtonCornerRadius),
                      side: BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor),
                    ),
                    onPressed: () {
                      //  _currentPageState == LoginViewState.loginUser ? this._viewModel.registerUser() : this._viewModel.requestRegisterUser();
                    },
                    color: ColorProvider.shared.standardAppButtonColor,
                    textColor: ColorProvider.shared.standardAppButtonTextColor,
                    child: Text(
                        AppLocalizations.of(context).translate('account_setting_missing_contact_support_button_text')
                    )
                )
                ),
                SizedBox(width: 10),
              ]),
          SizedBox(height: 10),
        ],
      ),),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: ColorProvider.shared
              .standardAppLeftMenuBackgroundColor, //This will change the drawer background to blue.
          //other styles
        ),
        child:
        Drawer(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            color: ColorProvider.shared.standardAppLeftMenuBackgroundColor,
            child:

            Container(
              color: ColorProvider.shared.standardAppBackgroundColor,
              child:

              ListView(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 0),
                children: [
                  Container(
                    height: 50,
                    color: ColorProvider.shared.standardAppButtonColor,
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(authenticationService.signedInEmail(),
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Poppins')),
                  ),
                  Container(height: 80,
                      color: ColorProvider.shared.standardAppBackgroundColor),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => OnboardingPage()));
                        },
                            child: Text(
                                AppLocalizations.of(context).translate('menu_current_data_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))
                      ],)
                  ),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => HistoricalPage()));
                        },
                            child: Text(
                                AppLocalizations.of(context).translate('menu_historical_data_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))
                      ],)
                  ),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => AccountSettingsPage()));
                        },
                            child: Text(
                                AppLocalizations.of(context).translate('menu_account_settings_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))


                      ],)
                  ),
                  Container(height: 50,
                      color: ColorProvider.shared.standardAppBackgroundColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child:
                      Row(children: [
                        TextButton(onPressed: () {
                          _viewModel.signOut();
                         //  Navigator.pop(context);
                         //  Navigator.of(context).pop(true);
                        },
                            child: Text(AppLocalizations.of(context).translate('menu_sing_out_button'),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Poppins')))
                      ],
                      )
                  ),
                ],
              ),
            ),
          ),

        ),
      ),
    ),
      onWillPop: () async => false,
    );
  }
}