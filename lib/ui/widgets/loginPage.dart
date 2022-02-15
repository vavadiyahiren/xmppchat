import 'package:chatsample/models/User.dart';
import 'package:chatsample/services/sharedPrefs.dart';
import 'package:chatsample/ui/shared/app_colors.dart';
import 'package:chatsample/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'ContactPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController hostController = new TextEditingController();
  TextEditingController portController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: blueGrayColor,
          title: GestureDetector(
            onLongPress: () {
              usernameController.text = 'test';
              passwordController.text = 'test';
              hostController.text = 'xrstudio.in';
              portController.text = '5222';
            },
            child: Text("Login with XMPP Chat"),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                // _title(),
                _emailPasswordWidget(),
                SizedBox(
                  height: 8.h,
                ),
                submitButton(),
                Spacer(),
                Text(
                  'Maid with by XMPP Chat',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Color(0xff2E2E2E),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
  }

  Widget submitButton() {
    return InkWell(
      onTap: () async {
        User user = new User(usernameController.text, passwordController.text, hostController.text,
            portController.text);
        await SharedPrefs.saveUser(user);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ContactPage(user)));
      },
      child: AppWidgets.submit(context),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        AppWidgets.entryField1("XMPP Jid", textEditingController: usernameController),
        AppWidgets.entryField1("Password", isPassword: true, textEditingController: passwordController),
        AppWidgets.entryField1("Host", textEditingController: hostController),
        AppWidgets.entryField1("Port", textEditingController: portController),
      ],
    );
  }

}
