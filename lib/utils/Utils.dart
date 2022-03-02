import 'dart:io';
import 'package:chatsample/db/api/ConactApi.dart';
import 'package:chatsample/models/Contact.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static final String domain = "xrstudio.in";
  static final String host = "xrstudio.in";
  static final String mucServerId = "conference.";
  static final int port = 5222;
  static final String emptyString = "";
  static final String connected = "Connected";
  static final String authenticated = "Authenticated";
  static final String disconnected = "Disconnected";
  static final String reconnection = "Reconnection";
  static final String chat = "chat";
  static final String groupChat = "groupchat";
  static final String ack = "Ack";
  static final String deliveryAck = "Delivery-Ack";
  static final String addMember = "AddMember";
  static final String readReceipt = "Read-Receipt";
  static final int conversationTypeNormal = 0;
  static final int conversationTypeGroup = 1;
  static final String dummyGroupName = '${getDomainBareJid('testGroup1')}';

  static bool hasDomain(String jid) {
    return jid.contains(domain);
  }

  static String addDomain(String jid) {
    if (!hasDomain(jid)) {
      jid += "@" + domain;
    }
    return jid;
  }

  static String removeDomain(String jid) {
    if (hasDomain(jid)) {
      jid = jid.substring(0, jid.indexOf("@"));
    }
    return jid;
  }

  static String removeDomainGroup(String jid) {
    jid = jid.toString().split('/')[1];
    return jid;
  }

  static write(String text) async {
    final file = await _localFile;
    await file.writeAsString("${new DateFormat.yMd().add_jm().format(new DateTime.now())} : $text \n", mode: FileMode.append);
  }

  static Future<String> get _localPath async {
    var directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getExternalStorageDirectory();
    }
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/chatsample-logs.txt');
  }

  static getDomainBareJid(String userName) {
    String domainBareName = "@" + mucServerId + domain;
    return userName.contains(domainBareName) ? userName : userName + domainBareName;
  }

  static getValidJid(String jid) {
    if (jid != null && jid.contains("@")) {
      jid = jid.split("@")[0];
    }
    return jid != null ? jid : "";
  }

  static Future<bool> joinSingleMucGroups(String jid, int timeStamp) async {
    String groupId = getDomainBareJid(jid);

    if (groupId.isNotEmpty) {
      bool isGroupJoinSuccess = await XmppService.instance.joinMucGroup("$groupId,$timeStamp");
      print('joinSingleMucGroups groupId $groupId && time: $timeStamp && isGroupJoinSuccess: $isGroupJoinSuccess');
      return isGroupJoinSuccess;
    }
    return false;
  }

  static createSingleMucGroups(String groupName) async {
    print('createSingleMucGroups: $groupName');

    if (groupName.isNotEmpty) {
      XmppService.instance.createMucGroups(groupName);
    }
  }

  static joinMucGroups() async {
    List<Contact> allGroupsIds = await ContactApi.getContactsFromConversationType(Utils.conversationTypeGroup);
    for (Contact contact in allGroupsIds) {
      await joinSingleMucGroups(contact.jid, contact.lastMsgTime);
    }
  }
  static String massageTime(val) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
    String selTime = date.hour.toString() + ':' + date.minute.toString() + ':00';
    var dateString = DateFormat.jm().format(DateFormat("hh:mm:ss").parse(selTime));
    return dateString;
  }
}
