import 'package:chatsample/blocs/LoginBloc.dart';
import 'package:chatsample/ui/shared/app_colors.dart';
import 'package:chatsample/ui/widgets/loginPage.dart';
import 'package:chatsample/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  String name;
  LoginBloc loginBloc;

  ProfilePage(this.name, this.loginBloc);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.commonAppBar(context),
      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 38.sp,
                        backgroundColor: blueGrayColor,
                        child: CircleAvatar(
                          radius: 36.sp,
                          backgroundColor: Colors.white,
                          child: Text(
                            (widget.name != '' ? widget.name[0].toUpperCase() : '?') ?? '',
                            style: TextStyle(
                              color: blueGrayColor,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.w),
                      child: Text(
                        '${widget.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          color: Color(0xff2E2E2E),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.w),
                      child: Text(
                        '${widget.name}@xrstudio.in',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 5.5.h,
              child: ElevatedButton(
                onPressed: () async {
                  widget.loginBloc.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                },
                child: Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: redColor,
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
