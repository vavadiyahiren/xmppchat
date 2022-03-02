import 'dart:io';
import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:chatsample/db/api/ConactApi.dart';
import 'package:chatsample/db/api/MessageApi.dart';
import 'package:chatsample/enums/bubble_type.dart';
import 'package:chatsample/enums/connectivity_status.dart';
import 'package:chatsample/models/Contact.dart';
import 'package:chatsample/models/Message.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:chatsample/ui/shared/app_colors.dart';
import 'package:chatsample/ui/style/bubbles.dart';
import 'package:chatsample/ui/widgets/loginPage.dart';
import 'package:chatsample/ui/widgets/signup.dart';
import 'package:chatsample/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:time_formatter/time_formatter.dart';

class AppWidgets {
  static Widget customAppBar({
    BuildContext context,
    String username,
  }) {
    return AppBar(
      backgroundColor: Color(0xff517DA2),
      title: Row(
        children: [
          Text(
            'Chat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          Spacer(),
          Icon(
            Icons.search,
            color: Colors.white,
            size: 7.w,
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  height: 5.w,
                                  width: 5.w,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/message_text.png'),
                                    ),
                                  ),
                                ),
                                title: Transform(
                                    transform: Matrix4.translationValues(-20, 0.0, 0.0),
                                    child: new Text('Add chat')),
                                onTap: () {
                                  // addChat();
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Container(
                                  height: 5.w,
                                  width: 5.w,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/new_group.png'),
                                    ),
                                  ),
                                ),
                                title: Transform(
                                    transform: Matrix4.translationValues(-20, 0.0, 0.0),
                                    child: new Text('New group')),
                                onTap: () {
                                  // newGroup();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              // height 30,
                              alignment: Alignment.center,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(6)),
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 7.w,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) {
              //       return ProfilePage(username ?? '');
              //     },
              //   ),
              // );
            },
            child: Container(
              height: 15.w,
              width: 10.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/User profile.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget commonAppBar(context) {
    return AppBar(
      backgroundColor: Color(0xff517DA2),
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_sharp,
          color: Colors.white,
        ),
      ),
      title: Text(
        'Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  static void bottomSheet(BuildContext context, bool isGroup, String userName) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: Column(
                children: [
                  isGroup
                      ? ListTile(
                          leading: Container(
                            height: 5.w,
                            width: 5.w,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/close.png'),
                              ),
                            ),
                          ),
                          title: Transform(
                            transform: Matrix4.translationValues(-20, 0.0, 0.0),
                            child: new Text('Exit Group'),
                          ),
                          onTap: () async {
                            Utils.addDomain(userName);
                            await ContactApi.deleteContact(userName.toString());
                            print('delete contact successfully');
                            Navigator.pop(context);
                          },
                        )
                      : SizedBox(),
                  ListTile(
                    leading: Container(
                      height: 5.w,
                      width: 5.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/trash.jpg'),
                        ),
                      ),
                    ),
                    title: Transform(
                      transform: Matrix4.translationValues(-20, 0.0, 0.0),
                      child: new Text('Clear Chat'),
                    ),
                    onTap: () async {
                      Utils.addDomain(userName);
                      List<Message> messages = await MessageApi.getMessagesWithJid(userName);
                      messages.forEach((element) async {
                        await MessageApi.deleteMessage(element);
                      });
                      print('delete record successfully');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static buildBubble(context, Message message, conversationType) {
    Size size = MediaQuery.of(context).size;
    bool isMedia = (message.bubbleType != BubbleType.TEXT.index);
    // log('Conversation message ===>> ${message.toString()}');
    return Container(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              //Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(message)));
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Bubble(
                style: message.dir == 0 ? styleMe : styleSomebody,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.only(right: (message.dir == 0) ? (isMedia ? 0.0 : 15.0) : 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getSenderView(message, conversationType),
                          message.bubbleType == BubbleType.IMAGE.index
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(color: Colors.black26, blurRadius: 4),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      height: 230,
                                      width: 230,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(message.mediaURL),
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context, Object exception,
                                              StackTrace stackTrace) {
                                            return Image.asset("assets/noImage.jpg");
                                          },
                                        ),
                                      ),
                                    ),
                                    (message?.message?.isEmpty ?? true)
                                        ? SizedBox()
                                        : SizedBox(
                                            width: 230,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(message.message),
                                            ),
                                          ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${message.message}"),
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        Utils.massageTime(message.time),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(fontSize: 8.5.sp),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    message.dir == 0 ? buildStatus(message.status, size, isMedia) : new SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static buildStatus(int status, Size size, bool isMedia) {
    return Positioned(
      bottom: isMedia ? 10 : 0.0,
      right: isMedia ? 10 : 0.0,
      child: status == 0
          ? Icon(
              Icons.watch_later,
              size: size.height * 0.015,
            )
          : status == 2
              ? Container(
                  height: 4.w,
                  width: 4.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xff517DA2),
                      )),
                  child: Icon(
                    Icons.done,
                    size: size.height * 0.015,
                    color: Color(0xff517DA2),
                  ),
                )
              : status == 3
                  ? CircleAvatar(
                      radius: 2.w,
                      backgroundColor: Color(0xff517DA2),
                      child: Icon(
                        Icons.done,
                        size: size.height * 0.015,
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      height: 4.w,
                      width: 4.w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                          )),
                      child: Icon(
                        Icons.done,
                        size: size.height * 0.015,
                        color: Colors.grey,
                      ),
                    ),
    );
  }

  static Widget getSenderView(Message message, conversationType) {
    return conversationType == Utils.conversationTypeGroup && message.dir == 1
        ? Text(
            '${Utils.removeDomainGroup(message.senderJid)}',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          )
        : SizedBox();
  }

  static int findMaxTime(int a, int b, int c) {
    return [a, b, c].reduce(max);
  }

  ///SignUp Page
  static Widget backButton(context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  static Widget entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none, fillColor: Color(0xfff3f3f4), filled: true))
        ],
      ),
    );
  }

  static Widget title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'd',
          style: TextStyle(
            // textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: 'ev',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'rnz',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  static Widget loginAccountLabel(context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
              style: TextStyle(color: Color(0xfff79c4f), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  static Widget submitButton(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)])),
      child: Text(
        'Register Now',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  /// Login Page
  static Widget divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  static Widget facebookButton() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff1959a9),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('f',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff2872ba),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5), topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('Log in with Facebook',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget createAccountLabel(context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Don\'t have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
            },
            child: Text(
              'Register',
              style: TextStyle(color: Color(0xfff79c4f), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  static Widget title1() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Xmpp',
          style: TextStyle(
            //textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: 'Login',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
//            TextSpan(
//              text: 'rnz',
//              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
//            ),
          ]),
    );
  }

  static Widget backButton1(context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  static Widget entryField1(String title,
      {bool isPassword = false, TextEditingController textEditingController}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   title,
          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          // ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: textEditingController,
            obscureText: isPassword,
            decoration: InputDecoration(
                hintText: 'Enter $title',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
          ),
        ],
      ),
    );
  }

  static Widget submit(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)
        ],
        color: blueGrayColor,
        // color: blueGrayColor,
      ),
      child: Text(
        'Login',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  /// Group MemberInfo
  static Future modalBottomSheet(
    context, {
    String groupName,
    String MembersId,
    VoidCallback CreateOnTap,
    VoidCallback RemoveMemberOnTap,
    VoidCallback RemoveAdminOnTap,
  }) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      height: 5.w,
                      width: 5.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/close.png'),
                        ),
                      ),
                    ),
                    title: Transform(
                      transform: Matrix4.translationValues(-25, -3, 0.0),
                      child: new Text('Remove From Group'),
                    ),
                    onTap: RemoveMemberOnTap,
                  ),
                  ListTile(
                    leading: Container(
                      height: 5.w,
                      width: 5.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/crown.jpg'),
                        ),
                      ),
                    ),
                    title: Transform(
                      transform: Matrix4.translationValues(-25, -3, 0.0),
                      child: new Text('Create Admin'),
                    ),
                    onTap: CreateOnTap,
                  ),
                  ListTile(
                    leading: Container(
                      height: 5.w,
                      width: 5.w,
                      child: Image.asset(
                        'assets/crown.jpg',
                      ),
                    ),
                    title: Transform(
                      transform: Matrix4.translationValues(-25, -3, 0),
                      child: new Text('Remove Admin'),
                    ),
                    onTap: RemoveAdminOnTap,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  ///conversationPage
  static void sendCustomMessage(Message element, String userName) async {
    if (!userName.contains('xrstudio.in')) {
      userName = '${userName}@xrstudio.in';
    }
    await XmppService.instance.sendCustomMessage(
      userName,
      "",
      element.id.toString(),
      Utils.readReceipt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static void requestMamMessages({String userName, String requestSince}) async {
    await XmppService.instance.requestMamMessages(
      userJid: userName,
      requestBefore: '',
      requestSince: requestSince,
      limit: '10000',
    );
  }

  static void readReceipt(Message msgId) async {
    Message message = await MessageApi.getMessage(msgId.id);
    if (message != null) {
      message.setisReadSent(1);
      await MessageApi.update(message);
    }
  }

  static void getAdmins({String userName}) async {
    // setState(() {});
    // print(await XmppService.instance.getAdmins(groupName: widget.title).toString());
    print(await XmppService.instance.getAdmins(groupName: userName).toString());
  }

  ///ContactPage
  static buildStatus1(context, {int status, bool isMedia}) {
    Size size = MediaQuery.of(context).size;
    return status == 0
        ? Icon(
            Icons.watch_later,
            size: size.height * 0.015,
          )
        : status == 2
            ? Container(
                height: 4.w,
                width: 4.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xff517DA2),
                    )),
                child: Icon(
                  Icons.done,
                  size: size.height * 0.015,
                  color: Color(0xff517DA2),
                ),
              )
            : status == 3
                ? CircleAvatar(
                    radius: 2.w,
                    backgroundColor: Color(0xff517DA2),
                    child: Icon(
                      Icons.done,
                      size: size.height * 0.015,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    height: 4.w,
                    width: 4.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                        )),
                    child: Icon(
                      Icons.done,
                      size: size.height * 0.015,
                      color: Colors.grey,
                    ),
                  );
  }

  static Future<List> requestCount(BuildContext context,
      {GlobalKey<FormState> globalKey, bool isCreateGroup, bool isJoinGroup}) async {
    final _controller = TextEditingController();
    return await showDialog<List>(
      context: context,
      builder: (context) => Form(
        key: globalKey,
        child: SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          titlePadding: EdgeInsets.only(left: 16, right: 16, top: 16),
          title: Text('Enter ${(isCreateGroup || isJoinGroup) ? "Group" : "Contact"} Name'),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  } else if (value.contains(' ')) {
                    return 'Please remove Space between text';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: (isCreateGroup || isJoinGroup) ? 'Group name' : 'Contact name'),
                key: Key('Name'),
                autofocus: true,
                controller: _controller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey,
                      ),
                      height: 6.h,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  Expanded(
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: blueGrayColor,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (globalKey.currentState.validate()) {
                            Navigator.of(context).pop([_controller.text, '0']);
                          }
                        },
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget itemContact(context,
      {Contact contact, ConnectivityStatus connectivityStatus, VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      title: Text(
        "${contact.name}",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      subtitle: contact.lastMessage.message != null
          ? Text(
              "${contact.lastMessage.message}",
              maxLines: 1,
              style: TextStyle(
                color: Color(0xffA3A3A3),
              ),
            )
          : SizedBox(),
      leading: CircleAvatar(
        backgroundColor: Color(0xffDEDEDE),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(
            'assets/icon_user.png',
          ),
        ),
      ),
      trailing: contact.lastMessage.time != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${formatTime(contact.lastMessage.time)}",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: Color(0xffA3A3A3),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                contact.lastMessage.dir == 0
                    ? AppWidgets.buildStatus1(context,
                        status: contact.lastMessage.status, isMedia: false)
                    : SizedBox(),
              ],
            )
          : SizedBox(),
    );
  }
}
