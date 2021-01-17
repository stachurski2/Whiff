import 'package:Whiff/Services/Authetication/Authetication.dart';
import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/modules/onboarding/OnboardingPage.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/helpers/app_localizations.dart';
import 'dart:async';


class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}


class LoginPageState extends State<LoginPage> {

  var focusNode = FocusNode();

  var _login = "";
  var _password = "";
  var _loginMessage = "";

  final double _kImageWidth = 300;
  final double _kImageHeight = 150;
  final double _kTopLabelFontSize = 18;
  final double _kBottomButtonBottomInset = 15;
  final double _kStandardViewInset = 20;
  final double _kButtonHeight = 35;
  final double _kButtonCornerRadius = 10;
  final double _kInsetBetweenTextFieldAndButton = 30.0;

  StreamSubscription onboardingState;

  final AutheticatingServicing authenticationService = AutheticationService.shared;

  @override
  void deactivate() {
    this.onboardingState.cancel();
    super.deactivate();
  }

  void handle(AutheticationState state) {
    if(state.signedIn == true) {
      _loginMessage = "";
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    } else if(state.errorMessage != null) {
      _loginMessage = state.errorMessage;
    } else {
      _loginMessage = AppLocalizations.of(context).translate('login_login_textfield_placeholder');
    }
  }

  @override
  Widget build(BuildContext context) {

    this.onboardingState = authenticationService.currentAuthState().listen((state) {
        this.setState(() {
          this.handle(state);
        });
    });

    return Scaffold(
        backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
        body: Container(
          child: Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/whiffLogo.png', width: _kImageWidth,
                        height: _kImageHeight),
                  ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context).translate('login_top_label_text'),
                        style: TextStyle(fontSize: _kTopLabelFontSize, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                    ),
                  ]
              ),
             Spacer(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: _kStandardViewInset),
                    Expanded(child: TextFormField(
                      onEditingComplete: (){
                        focusNode.requestFocus();
                    },
                        onChanged: (value){
                          this._login = value;
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('login_login_textfield_placeholder'),
                        )
                    )),
                    SizedBox(width: _kStandardViewInset)
                  ]
              ),
                SizedBox(
                  height: _kStandardViewInset,
                )
                ,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: _kStandardViewInset),
                    Expanded(child: TextFormField(
                      focusNode: focusNode,
                      onChanged: (value){
                        this._password = value;
                      },
                      onEditingComplete: ()  async {
                        focusNode.unfocus();
                        var loginResult = await AutheticationService.shared.login(_login, _password);
                        // setState(() {
                        //    handle(loginResult);
                        // });
                      },
                        obscureText: true,
                        decoration: InputDecoration(
                            errorText: _loginMessage,
                            hintText: AppLocalizations.of(context).translate('login_password_textfield_placeholder'),
                        )
                    )
                    ),
                    SizedBox(width: _kStandardViewInset),
                  ]
              ),
              SizedBox(
                height: _kInsetBetweenTextFieldAndButton,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 2*_kStandardViewInset,
                        height: _kButtonHeight,
                        child:

                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_kButtonCornerRadius),
                            side:BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor)
                        ),
                        onPressed: () {
                        },
                        color: ColorProvider.shared.standardAppButtonColor,
                        textColor: ColorProvider.shared.standardAppButtonTextColor,
                        child: Text(
                            AppLocalizations.of(context).translate('login_login_password_button_title'),
                        )

                    )
                    )
                  ]
              ),
              SizedBox(
                height: _kStandardViewInset,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width - 2*_kStandardViewInset,
                        height: _kButtonHeight,
                        child:
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_kButtonCornerRadius),
                            side: BorderSide(color: ColorProvider.shared.standardAppButtonBorderColor),
                        ),
                        onPressed: () {

                        },
                        color: ColorProvider.shared.standardAppButtonColor,
                        textColor: ColorProvider.shared.standardAppButtonTextColor,
                        child: Text(
                          AppLocalizations.of(context).translate('login_login_register_button_title'),
                        )
                    ),
                    )
                  ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                      SizedBox(height: _kBottomButtonBottomInset)
                  ]
              )
            ],
          ),
        )
    );
  }
}
