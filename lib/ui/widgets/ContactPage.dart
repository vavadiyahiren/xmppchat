import 'dart:developer';

import 'package:chatsample/blocs/ContactBloc.dart';
import 'package:chatsample/blocs/LoginBloc.dart';
import 'package:chatsample/enums/connectivity_status.dart';
import 'package:chatsample/models/Contact.dart';
import 'package:chatsample/models/User.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:chatsample/ui/widgets/ConversationPage.dart';
import 'package:chatsample/widgets/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'ProfilePage.dart';
import 'loginPage.dart';

class ContactPage extends StatefulWidget {
  User user;

  ContactPage(this.user, {Key key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  ConnectivityStatus _connectivityStatus = ConnectivityStatus.Offline;
  LoginBloc loginBloc;
  ContactBloc _contactBloc;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController searchBoxController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final _globalKey = GlobalKey<FormState>();
  bool isSearch = false;
  var authListner;

  @override
  void initState() {
    loginBloc = new LoginBloc();
    _contactBloc = ContactBloc.instance;
    authListner = loginBloc.loginObserver.listen((user) => _userListner(user));
    XmppService.instance.connect();
    super.initState();
  }

  @override
  void dispose() {
    authListner.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _contactBloc.getContacts();
    XmppService.instance.getConnectivityStatus();
    return new Scaffold(
      appBar: AppBar(backgroundColor: Color(0xff517DA2), title: isSearch ? searchBox() : appBar()),
      body: _buildContactList(),
      // drawer: _buildDrawer(),
    );
  }

  Widget searchBox() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchBoxController,
            decoration: InputDecoration(
              prefixIcon: new Icon(Icons.search, color: Colors.white),
              suffixIcon: IconButton(
                  onPressed: () {
                    isSearch = false;
                    searchBoxController.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.close, color: Colors.white)),
              hintText: "Search...",
              hintStyle: new TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
            onChanged: (searchText) {
              setState(() {});
              log('searchBoxController:${searchBoxController.text}');
            },
          ),
        ),
      ],
    );
  }

  Widget appBar() {
    return Row(
      children: [
        StreamBuilder<String>(
          stream: XmppService.instance.connectionObserver,
          builder: (context, snapshot) {
            String title = "XMPP Login";
            if (snapshot.hasData) {
              title = "${snapshot.data}";
            }
            return SizedBox(
              width: 40.w,
              child: Text(
                "Chats",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              isSearch = !isSearch;
            });
          },
          child: Image.asset(
            'assets/Search.png',
            color: Colors.white,
            height: 7.w,
            width: 7.w,
          ),
        ),
        SizedBox(
          width: 15,
        ),
        GestureDetector(
          onTap: () {
            showModelBottomSheet();
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 7.w,
          ),
        ),
        SizedBox(
          width: 15,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ProfilePage(widget.user.username ?? '', loginBloc ?? LoginBloc());
                },
              ),
            );
          },
          child: Container(
            height: 8.w,
            width: 8.w,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/User profile.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactList() {
    return StreamBuilder<List<Contact>>(
      stream: _contactBloc.contactListObserver,
      builder: (context, snapshot) {
        List<Contact> allContacts = new List<Contact>();
        if (snapshot.hasData) {
          allContacts = snapshot.data;
        }
        return allContacts.length == 0
            ? Center(
                child: Text(
                  "No Contacts Available",
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: allContacts.length,
                itemBuilder: (BuildContext context, int index) {
                  if (searchBoxController.text.isEmpty) {
                    return AppWidgets.itemContact(
                      context,
                      contact: allContacts[index],
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ConversationPage(
                                title: allContacts[index].name,
                                connectivityStatus: _connectivityStatus,
                                conversationType: allContacts[index].conversationtype,
                              ),
                            )).whenComplete(() {
                          setState(() {});
                        });
                      },
                      connectivityStatus: _connectivityStatus,
                    );
                  } else if (allContacts[index]
                          .name
                          .toLowerCase()
                          .contains(searchBoxController.text) ||
                      allContacts[index].name.toUpperCase().contains(searchBoxController.text)) {
                    return AppWidgets.itemContact(
                      allContacts[index],
                      connectivityStatus: _connectivityStatus,
                    );
                  } else {
                    return SizedBox();
                  }
                });
      },
    );
  }

  void showModelBottomSheet() {
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
                      child: new Text('Add chat'),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      addContact(context, false, false);
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
                      child: new Text('New group'),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      addContact(context, true, false);
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

  void addContact(BuildContext context, bool isCreateGroup, bool isJoinGroup) async {
    List jid = await AppWidgets.requestCount(
      context,
      globalKey: _globalKey,
      isCreateGroup: isCreateGroup,
      isJoinGroup: isJoinGroup,
    );
    if (jid != null && jid != "") {
      _contactBloc.addContact(jid[0], int.parse(jid[1].toString()), isCreateGroup, isJoinGroup);
    }
  }

  void logOut() {
    loginBloc.logout();
  }

  void _userListner(User user) {
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
