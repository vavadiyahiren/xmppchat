import 'package:chatsample/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import '../../src/Widget/bezierContainer.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
          height: MediaQuery.of(context).size.height,
          child:Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    AppWidgets.title(),
                    SizedBox(
                      height: 50,
                    ),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    AppWidgets.submitButton(context),
                    Expanded(
                      flex: 2,
                      child: SizedBox(),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AppWidgets.loginAccountLabel(context),
              ),
              Positioned(top: 40, left: 0, child: AppWidgets.backButton(context)),
              Positioned(
                  top: -MediaQuery.of(context).size.height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer())
            ],
          ),
        )
      )
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        AppWidgets.entryField("Username"),
        AppWidgets.entryField("Email id"),
        AppWidgets.entryField("Password", isPassword: true),
      ],
    );
  }
}
