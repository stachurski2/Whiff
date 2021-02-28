import 'package:Whiff/Services/Authetication/AutheticationState.dart';
import 'package:Whiff/customView/LoadingIndicator.dart';
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

  var _firstFocusNode = FocusNode();
  var _secondFocusNode = FocusNode();

  var _didShowOnboarding = false;
  var _loginMessage = "";
  var _currentPageState = LoginViewState.loginUser;
  var _firstTextfieldController = TextEditingController();
  var _secondTextfieldController = TextEditingController();
  var _thirdTextfieldController = TextEditingController();


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
  StreamSubscription alertSubscription;

  @override
  void initState() {
    super.initState();
    _currentPageState = LoginViewState.loginUser;
    this.onboardingState = _viewModel.currentAuthState().listen((state) {
      this.setState(() {
        this._handleAuthState(state);
      });
    });

    this.loginState = _viewModel.curentViewState().listen((state) {
      this._handleViewState(state);
      this.setState((){});
    });

    this.alertSubscription = _viewModel.alertStream().listen((message) {
        print("test");
       // AlertDialog(title: Text(AppLocalizations.of(context).translate(message)));
      this.showAlert(context,AppLocalizations.of(context).translate(message));
    });
  }

  @override
  void deactivate() {
    this.onboardingState.cancel();
    super.deactivate();
  }

  void _handleAuthState(AutheticationState state) {
    if(state.signedIn == true) {
      _loginMessage = "";
      if(_didShowOnboarding == false) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OnboardingPage()),
        );
        _viewModel.setSecondPassword("");
        _viewModel.setPassword("");
        _viewModel.setLogin("");
        _firstTextfieldController.clear();
        _secondTextfieldController.clear();
        _thirdTextfieldController.clear();

        setState(() {
        });
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

  void _handleViewState(LoginViewState state) {
    _currentPageState = state;
    _firstTextfieldController.clear();
    _secondTextfieldController.clear();
    _thirdTextfieldController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorProvider.shared.standardAppBackgroundColor,
        body: Container(
          child:
            Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/whiffLogo.png', width: _kImageWidth,
                        height: _kImageHeight),
                  ]
              ),
               _currentPageState == LoginViewState.registerUser ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context).translate('login_login_registration_title'),
                        style: TextStyle(fontSize: _kTopLabelFontSize, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                    ),
                  ]
              ): _currentPageState == LoginViewState.remindPassword ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context).translate('login_login_remind_password_title'),
                        style: TextStyle(fontSize: _kTopLabelFontSize, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                    ),
                  ]
              ): Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: <Widget>[
                     Text(
                         AppLocalizations.of(context).translate('login_top_label_text'),
                         style: TextStyle(fontSize: _kTopLabelFontSize, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                         textAlign: TextAlign.center
                     ),
                   ]
               ) ,
              Spacer(),
              _currentPageState != LoginViewState.loading ? Column(children: [

              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: _kStandardViewInset),
                    Expanded(child: TextFormField(
                      onEditingComplete: (){
                        if(_currentPageState == LoginViewState.remindPassword) {
                          _viewModel.requestRemindPassword();
                        } else if(_currentPageState == LoginViewState.loginUser){
                         _firstFocusNode.requestFocus();
                        }  else if (_currentPageState == LoginViewState.registerUser) {
                          _firstFocusNode.requestFocus();
                        } else {
                          _firstFocusNode.unfocus();
                        }
                    },
                       controller: _firstTextfieldController,
                        onChanged: (value){
                          _viewModel.setLogin(value);
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('login_login_textfield_placeholder'),
                        ),
                    )),
                    SizedBox(width: _kStandardViewInset)
                  ]
              ),
                SizedBox(
                  height: _kStandardViewInset,
                )
                ,
                _currentPageState == LoginViewState.loginUser || _currentPageState == LoginViewState.registerUser?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: _kStandardViewInset),
                    Expanded(child: TextFormField(
                      focusNode:  _firstFocusNode,
                      onChanged: (value){
                        _viewModel.setPassword(value);
                      },
                      onEditingComplete: ()  async {
                        if(_currentPageState == LoginViewState.loginUser) {
                          _firstFocusNode.unfocus();
                          _viewModel.login();
                        } else if(_currentPageState == LoginViewState.registerUser){
                               _secondFocusNode.requestFocus();
                        }
                      },
                       controller: _secondTextfieldController,
                        obscureText: true,
                        decoration: InputDecoration(
                            errorText: _loginMessage,
                            hintText: AppLocalizations.of(context).translate('login_password_textfield_placeholder'),
                        )
                    )
                    ),
                    SizedBox(width: _kStandardViewInset),
                  ]
              ) : SizedBox(),
              _currentPageState == LoginViewState.registerUser ?
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: _kStandardViewInset),
                    Expanded(child: TextFormField(
                        focusNode: _secondFocusNode,
                        onChanged: (value){
                          _viewModel.setSecondPassword(value);
                        },
                        onEditingComplete: ()  async {
                          _secondFocusNode.unfocus();

                          _viewModel.requestRegisterUser();
                        },
                      controller: _thirdTextfieldController,
                        obscureText: true,
                        decoration: InputDecoration(
                          errorText: _loginMessage,
                          hintText: AppLocalizations.of(context).translate('login_password_textfield_placeholder'),
                        )
                    )
                    ),
                    SizedBox(width: _kStandardViewInset),
                  ]
              ) : SizedBox(),
              SizedBox(
                height: _kInsetBetweenTextFieldAndButton,
              ),
              _currentPageState == LoginViewState.loginUser || _currentPageState == LoginViewState.remindPassword  ?
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
                          if(_currentPageState == LoginViewState.loginUser) {
                            this._viewModel.remindPassword();
                          } else {
                            this._viewModel.requestRemindPassword();
                          }
                        },
                        color: ColorProvider.shared.standardAppButtonColor,
                        textColor: ColorProvider.shared.standardAppButtonTextColor,
                        child: Text(
                          _currentPageState == LoginViewState.loginUser ? AppLocalizations.of(context).translate('login_login_password_button_title') :  AppLocalizations.of(context).translate('login_login_password_password_button_title'),
                        )

                      )
                    )
                  ]
              ) : SizedBox(),
              SizedBox(
                height: _kStandardViewInset,
              ),
              _currentPageState == LoginViewState.loginUser || _currentPageState == LoginViewState.registerUser  ?
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
                          _currentPageState == LoginViewState.loginUser ? this._viewModel.registerUser() : this._viewModel.requestRegisterUser();
                        },
                        color: ColorProvider.shared.standardAppButtonColor,
                        textColor: ColorProvider.shared.standardAppButtonTextColor,
                        child: Text(
                        _currentPageState == LoginViewState.loginUser ? AppLocalizations.of(context).translate('login_login_register_button_title') :  AppLocalizations.of(context).translate('login_login_register_register_button_title'),
                        )
                    ),
                    )
                  ]
              ) : SizedBox(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                      SizedBox(height: _kBottomButtonBottomInset)
                  ]
              )]) : LoadingIndicator(),
              _currentPageState == LoginViewState.loading ? Spacer() : SizedBox(height: 1,),
          ])
        ),
    );
  }

  void showAlert(BuildContext context, String text) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(text),
            actions: [
              okButton,
            ],
        ),
      );
  }

}
