import 'package:chatsample/ui/widgets/welcomePage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WelComeScreen());
}

class WelComeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    getPermission();
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'XmppChat',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            // textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
            //   body1: GoogleFonts.montserrat(textStyle: textTheme.body1),
            // ),
          ),
          debugShowCheckedModeBanner: false,
          home: WelcomePage(),
        );
      },
    );
  }

  void getPermission() async {
    if(!(await Permission.storage.isGranted)){
    var status = await Permission.storage.request();
    print("PERMISSION STATUS : $status");
    }
  }
}
