import 'package:flutter/material.dart';
import 'package:Whiff/helpers/color_provider.dart';
import 'package:Whiff/helpers/app_localizations.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}


class LoginPageState extends State<LoginPage> {

  var focusNode = FocusNode();

  final double kImageWidth = 300;
  final double kImageHeight = 150;
  final double kTopLabelFontSize = 18;
  final double kBottomButtonBottomInst = 15;
  final double kStandardViewInset = 20;
  final double kButtonHeight = 35;
  final double kButtonCornerRadius = 10;
  final double kButtonBorderWidth = 0.5;
  final double kInsetBetweenTextFieldAndButton = 30.0;

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
                    Image.asset('assets/whiffLogo.png', width: kImageWidth,
                        height: kImageHeight),
                  ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context).translate('login_top_label_text'),
                        style: TextStyle(fontSize: kTopLabelFontSize, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                    ),
                  ]
              ),
             Spacer(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20),
                    Expanded(child: TextFormField(
                      onEditingComplete: (){
                        focusNode.requestFocus();
                    },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('login_login_textfield_placeholder'),
                        )
                    )),
                    SizedBox(width: kStandardViewInset)
                  ]
              ),
                SizedBox(
                  height: kStandardViewInset,
                )
                ,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: kStandardViewInset),
                    Expanded(child: TextFormField(
                      focusNode: focusNode,
                      onEditingComplete: (){
                        focusNode.unfocus();
                        print("login");
                      },
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).translate('login_password_textfield_placeholder'),
                        )
                    )
                    ),
                    SizedBox(width: kStandardViewInset),
                  ]
              ),
              SizedBox(
                height: kInsetBetweenTextFieldAndButton,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 2*kStandardViewInset,
                        height: kButtonHeight,
                        child:

                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kButtonCornerRadius),
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
                height: kStandardViewInset,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width - 2*kStandardViewInset,
                        height: kButtonHeight,
                        child:
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kButtonCornerRadius),
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
                      SizedBox(height: kBottomButtonBottomInst)
                  ]
              )
            ],
          ),
        )
    );
  }
}
