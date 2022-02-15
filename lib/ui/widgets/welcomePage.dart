import 'package:chatsample/blocs/LoginBloc.dart';
import 'package:chatsample/models/User.dart';
import 'package:chatsample/ui/widgets/ContactPage.dart';
import 'package:chatsample/ui/widgets/signup.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'loginPage.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  LoginBloc loginBloc;
  var authListner;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      loginBloc = new LoginBloc();
      authListner = loginBloc.loginObserver.listen((user) => _loginUserListner(user));
      loginBloc.getUser();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    authListner.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/splash.png',
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                    child: Image.asset(
                  'assets/appicon.png',
                  height: 30.h,
                  width: 30.h,
                )),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Made with ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      'assets/Heart.png',
                      height: 1.5.h,
                      width: 1.5.h,
                    ),
                    Text(
                      ' by XMPP Chat',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          //Spacer(),
        ],
      ),
    );
  }

  void onDoneLoading() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _loginUserListner(User user) {
    if (user != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ContactPage(
                    user,
                  )));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        /*padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color(0xffdf8e33).withAlpha(100),
                  offset: Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 2)
            ],
            color: Colors.white),
        child:
        Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Color(0xfff7892b)),
        ),*/
      ),
    );
  }

  Widget _signUpButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          'Register now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _label() {
    return Container(
        margin: EdgeInsets.only(top: 40, bottom: 20),
        child: Column(
          children: <Widget>[
            Text(
              'Quick login with Touch ID',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            SizedBox(
              height: 20,
            ),
            Icon(Icons.fingerprint, size: 90, color: Colors.white),
            SizedBox(
              height: 20,
            ),
            Text(
              'Touch ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ));
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Xmpp',
          style: TextStyle(
            //textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: 'Login',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
//            TextSpan(
//              text: 'pp',
//              style: TextStyle(color: Colors.white, fontSize: 30),
//            ),
          ]),
    );
  }
}
