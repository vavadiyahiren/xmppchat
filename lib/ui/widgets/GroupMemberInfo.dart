import 'package:chatsample/models/User.dart';
import 'package:chatsample/services/sharedPrefs.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:chatsample/ui/shared/app_colors.dart';
import 'package:chatsample/utils/Utils.dart';
import 'package:chatsample/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class GroupMemberInfo extends StatefulWidget {
  List groupMembersList;
  String groupName;

  GroupMemberInfo(this.groupMembersList, this.groupName);

  @override
  _GroupMemberInfoState createState() => _GroupMemberInfoState();
}

class _GroupMemberInfoState extends State<GroupMemberInfo> {
  List<dynamic> admins = [];
  List<dynamic> fullList = [];
  List<dynamic> owners = [];
  List<dynamic> memberList = [];
  User user;
  TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAdmin();
    getUser();
  }

  getUser() async {
    user = await SharedPrefs.getUser();
  }

  getAdmin() async {
    owners = [];
    admins = [];
    memberList = [];
    fullList.clear();
    admins = await XmppService.instance.getAdmins(groupName: widget.groupName);
    owners = await XmppService.instance.getOwners(groupName: widget.groupName);
    memberList = await XmppService.instance.getMember(groupName: widget.groupName);
    setState(() {});
    fullList.addAll(owners);
    fullList.addAll(admins);
    fullList.addAll(memberList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: blueGrayColor,
        title: Text(
          'Group Members',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 3.w, bottom: 9.w),
              child: Card(
                elevation: 2,
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
                              '${widget.groupName[0].toUpperCase()}',
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
                          '${widget.groupName}',
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
                          '${widget.groupName}@conference.xrstudio.in',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 5.5.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            _addMemberDialog();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/adduser.png',
                                height: 3.h,
                                width: 3.h,
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              Text(
                                "Add members",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: blueGrayColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              ' ${fullList.length} Members',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: ListView.builder(
                //physics: NeverScrollableScrollPhysics(),
                itemCount: fullList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      if (Utils.removeDomain(fullList[index]) != user.username &&
                          memberList.contains('${Utils.addDomain(user.username)}') == false) {
                        setState(() {});
                        AppWidgets.modalBottomSheet(
                          context,
                          groupName: widget.groupName,
                          MembersId: fullList[index],
                          CreateOnTap: () async {
                            XmppService.instance.createAdmin(
                                groupName: widget.groupName, allMembersId: fullList[index]);
                            getAdmin();
                            Navigator.pop(context);
                          },
                          RemoveAdminOnTap: () {
                            XmppService.instance.removeAdmin(
                                groupName: widget.groupName, allMembersId: fullList[index]);
                            getAdmin();
                            Navigator.of(context).pop();
                          },
                          RemoveMemberOnTap: () {
                            XmppService.instance.removeMember(
                                groupName: widget.groupName, allMembersId: fullList[index]);
                            getAdmin();
                            Navigator.of(context).pop();
                          },
                        );
                      }
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                      leading: CircleAvatar(
                        radius: 21,
                        backgroundColor: Colors.orange,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              'https://st3.depositphotos.com/15648834/17930/v/600/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg'),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                      subtitle: index == 0
                          ? Text('Owner')
                          : admins.length >= index
                              ? Text('Admin')
                              : SizedBox(),
                      title: Text(
                        '${Utils.removeDomain(fullList[index])}',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                      ),
                      trailing: (admins.length >= index || index == 0)
                          ? Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: greenColor,
                                  ),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                index == 0
                                    ? 'Owner'
                                    : admins.length >= index
                                        ? 'Admin'
                                        : '',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.sp,
                                    color: greenColor),
                              ),
                            )
                          : SizedBox(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addMemberDialog() => showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          titlePadding: EdgeInsets.only(left: 16, right: 16, top: 16),
          title: Text('Member jid'),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'At a time only 1 member can add',
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(hintText: 'Member jid'),
                autofocus: true,
                controller: _editingController,
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
                      height: 5.h,
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
                      height: 5.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: blueGrayColor,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                          XmppService.instance.addMemberMucGroups(
                              groupName: widget.groupName, member: _editingController.text);
                          await XmppService.instance.sendCustomMessage(
                              Utils.addDomain(_editingController.text),
                              '${widget.groupName}',
                              DateTime.now().millisecondsSinceEpoch.toString(),
                              Utils.addMember,
                              DateTime.now().millisecondsSinceEpoch);
                          getAdmin();
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
      );
}
