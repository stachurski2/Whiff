import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/modules/onboarding/OnboardingPage.dart';
import 'package:Whiff/modules/login/LoginViewModel.dart';

import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/helpers/app_localizations.dart';
import 'dart:async';


class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}


class LoginPageState extends State<LoginPage> {

  final LoginViewModelContract _viewModel = LoginViewModel();

  var focusNode = FocusNode();
  var _didShowOnboarding = false;
  var _loginMessage = "";

  final double _kImageWidth = 300;
  final double _kImageHeight = 150;
  final double _kTopLabelFontSize = 18;
  final double _kBottomButtonBottomInset = 15;
  final double _kStandardViewInset = 20;
  final double _kButtonHeight = 35;
  final double _kButtonCornerRadius = 10;
  final double _kInsetBetweenTextFieldAndButton = 30.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  StreamSubscription onboardingState;

  StreamSubscription loginState;

  @override
  void initState() {
    super.initState();
    this.onboardingState = _viewModel.currentAuthState().listen((state) {
      this.setState(() {
        this.handle(state);
      });
    });

    this.loginState = _viewModel.curentViewState().listen((state) {
        print(state);
    });

  }

  @override
  void deactivate() {
    this.onboardingState.cancel();
    super.deactivate();
  }

  void handle(AutheticationState state) {
    if(state.signedIn == true) {
      _loginMessage = "";
      if(_didShowOnboarding == false) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OnboardingPage()),
        );
        _didShowOnboarding = true;
      };
    } else if(state.errorMessage != null) {
        _didShowOnboarding = false;
      _loginMessage = state.errorMessage;
    } else {
        _didShowOnboarding = false;
      _loginMessage = AppLocalizations.of(context).translate('login_login_textfield_placeholder');
    }
  }

  @override
  Widget build(BuildContext context) {

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
                          _viewModel.setLogin(value);
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
                        _viewModel.setPassword(value);
                      },
                      onEditingComplete: ()  async {
                        focusNode.unfocus();
                        _viewModel.login();
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
                          this._viewModel.remindPassword();
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
                          this._viewModel.registerUser();
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
