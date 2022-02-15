import 'dart:developer';
import 'dart:io';
import 'package:chatsample/blocs/ContactBloc.dart';
import 'package:chatsample/blocs/LoginBloc.dart';
import 'package:chatsample/blocs/MessageBloc.dart';
import 'package:chatsample/blocs/QueueBloc.dart';
import 'package:chatsample/enums/bubble_type.dart';
import 'package:chatsample/enums/connectivity_status.dart';
import 'package:chatsample/models/Message.dart';
import 'package:chatsample/models/User.dart';
import 'package:chatsample/services/sharedPrefs.dart';
import 'package:chatsample/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xmpp_plugin/message_event.dart';
import 'package:xmpp_plugin/xmpp_plugin.dart';
import 'connectivity_service.dart';

class XmppService {
  static XmppConnection flutterXmpp;
  static ConnectivityService connectivityService;
  static String connectionStatus = Utils.disconnected;
  User user;

  var _authListner;

  final _connectionStream = PublishSubject<String>();

  static ConnectivityStatus _connectivityStatus = ConnectivityStatus.Offline;

  Observable<String> get connectionObserver => _connectionStream.stream;

  final _xmppStatusSink = PublishSubject<String>();

  Observable<String> get xmppStattusObserver => _xmppStatusSink.stream;

  static XmppService get instance => _instance;

  static final XmppService _instance = XmppService._internal();

  XmppService._internal() {
    _authListner = LoginBloc().loginObserver.listen((user) {
      print("XmppService On user change ==> $user");
      this.user = user;
    });
    connectivityService = ConnectivityService.instance;
    connectivityService.connectionStatusController.stream
        .listen((networkStatus) => checkConnection(networkStatus));
    connectivityService.checkCurrentConnectivity();
  }

  getConnectivityStatus() async {
    _updateConnectionStatus();
  }

  getXmppStatus() async {
    _updateXmppStatus();
  }

  _updateXmppStatus() {
    _xmppStatusSink.add("$connectionStatus");
  }

  _updateConnectionStatus() {
    _updateXmppStatus();
    _connectionStream.add("${connectivityToString(_connectivityStatus)} : $connectionStatus");
  }

  dispose() {
    _connectionStream.close();
    _xmppStatusSink.close();
    _authListner.close();
  }

  connect() async {
    if (user == null) {
      user = await SharedPrefs.getUser();
      print("connect() ====> username: ${user?.username}  password: ${user?.password}");
      if (user == null) {
        print("connect() ====> user null");
        return;
      }
    }
    var auth = {
      "user_jid": "${user.username}@${Utils.domain}/${Platform.isAndroid ? "Android" : "iOS"}",
      "password": "${user.password}",
      "host": "${Utils.host}",
      "port": '${Utils.port}',
    };
    flutterXmpp = new XmppConnection(auth);
    await flutterXmpp.start(_onReceiveMessage, _onError);
    // login
    await flutterXmpp.login();
    Utils.write("Trying to connect with xmpp");
  }

  disconnectXMPP() async {
    await flutterXmpp.logout();
  }

  _onReceiveMessage(MessageEvent event) async {
    print("event own ==> ${event.toEventData().toString()}");
    String msgType = event.msgtype;
    String type = event.type;
    String id = event.id;
    String customText = event.customText;

    if (msgType == null) {
      print("event own msgType ==> $msgType");
      return;
    }

    if (customText == Utils.addMember) {
      ContactBloc.instance.addContact('${event.body}', 0, false, true);
    }

    if (Utils.connected.compareTo(msgType) == 0) {
      connectionStatus = Utils.connected;
      _updateConnectionStatus();
    } else if (Utils.authenticated.compareTo(msgType) == 0) {
      connectionStatus = Utils.authenticated;
      _updateConnectionStatus();
      SharedPrefs.saveUser(user);
      QueueBloc.instance.getQueue();
      Utils.joinMucGroups();
    } else if (Utils.disconnected.compareTo(msgType) == 0) {
      connectionStatus = Utils.disconnected;
      // disconnectXMPP();
      _updateConnectionStatus();
    } else if (Utils.reconnection.compareTo(msgType) == 0) {
      connectionStatus = event.body;
      _updateConnectionStatus();
    }

    if (customText == Utils.deliveryAck) {
      if (id != null) {
        log('updateMessageStatus =====>>>> 2');
        await MessageBloc.instance.updateMessageStatus(id, 2);
        await MessageBloc.instance.updateDeliveryTime(id, DateTime.now().millisecondsSinceEpoch);
        // QueueBloc.instance.deleteQueueWithMsgId(id);
      }
    }

    if (customText == Utils.readReceipt) {
      if (id != null) {
        log('updateMessageStatus =====>>>> 3');
        await MessageBloc.instance.updateMessageStatus(id, 3);
        await MessageBloc.instance.updateReadTime(id, DateTime.now().millisecondsSinceEpoch);
        // QueueBloc.instance.deleteQueueWithMsgId(id);
      }
    }

    if (Utils.ack == type && customText != Utils.deliveryAck && customText != Utils.readReceipt) {
      if (id != null) {
        log('updateMessageStatus =====>>>> 1');
        await MessageBloc.instance.updateMessageStatus(id, 1);
        QueueBloc.instance.deleteQueueWithMsgId(id);
      }
    } else if (Utils.chat == msgType &&
        Utils.addMember != customText &&
        Utils.deliveryAck != customText &&
        Utils.readReceipt != customText) {
      print("event own ==> chat: ${event.mediaURL}  ${event.bubbleType}");
      if (event.bubbleType == "1") {
        BubbleType bubbleType = BubbleType.values[int.parse(event.bubbleType)];

        int time = DateTime.now().millisecondsSinceEpoch;
        String from = event.from;
        String body = event.body;
        String id = event.id;
        String senderJid = event.senderJid ?? '';
        from = Utils.removeDomain(from);
        Message message = new Message(
            id: id,
            message: body,
            status: 1,
            dir: 1,
            to: from,
            time: time,
            senderJid: senderJid,
            contactconversationtype: Utils.conversationTypeNormal,
            bubbleType: bubbleType.index,
            isReadSent: 0,
            mediaURL: event
                .mediaURL); //TODO : get bubbleType from native and set it, if type media set url too
        await MessageBloc.instance.saveReceivedMessage(message);
        sendCustomMessage(
            Utils.addDomain(from), event.body, id.toString(), Utils.deliveryAck, int.parse(id));
      } else {
        int time = DateTime.now().millisecondsSinceEpoch;
        String from = event.from;
        String body = event.body;
        String id = event.id;
        String senderJid = event.senderJid ?? '';
        from = Utils.removeDomain(from);
        Message message = new Message(
            id: id,
            message: body,
            status: 1,
            dir: 1,
            to: from,
            time: time,
            senderJid: senderJid,
            contactconversationtype: Utils.conversationTypeNormal,
            bubbleType: BubbleType.TEXT.index,
            isReadSent:
                0); //TODO : get bubbleType from native and set it, if type media set url too
        await MessageBloc.instance.saveReceivedMessage(message);
        sendCustomMessage(
            Utils.addDomain(from), event.body, id.toString(), Utils.deliveryAck, int.parse(id));
      }
    } else if (Utils.groupChat.compareTo(msgType) == 0 && id.isNotEmpty) {
      print("event own ==> groupChat: ${event.mediaURL}  ${event.bubbleType}");
      if (event.bubbleType == "1") {
        BubbleType bubbleType = BubbleType.values[int.parse(event.bubbleType)];
        int time = DateTime.now().millisecondsSinceEpoch;
        String from = event.from;
        String body = event.body;
        String id = event.id;
        String senderJid = event.senderJid ?? '';
        from = Utils.removeDomain(from);
        Message message = new Message(
            id: id,
            message: body,
            status: 1,
            dir: 1,
            to: from,
            time: time,
            senderJid: senderJid,
            contactconversationtype: Utils.conversationTypeGroup,
            bubbleType: bubbleType.index,
            isReadSent: 0,
            mediaURL: event
                .mediaURL); //TODO : get bubbleType from native and set it, if type media set url too
        await MessageBloc.instance.saveReceivedMessage(message);
      } else {
        int time = DateTime.now().millisecondsSinceEpoch;
        String from = event.from;
        String body = event.body;
        String id = event.id;
        String senderJid = event.senderJid ?? '';
        from = Utils.removeDomain(from);
        Message message = new Message(
            id: id,
            message: body,
            status: 1,
            dir: 1,
            to: from,
            time: time,
            senderJid: senderJid,
            contactconversationtype: Utils.conversationTypeGroup,
            bubbleType: BubbleType.TEXT.index,
            isReadSent:
                0); //TODO : get bubbleType from native and set it, if type media set url too
        await MessageBloc.instance.saveReceivedMessage(message);
      }
    }
  }

  void _onError(Object error) {
    Utils.write("Error $error");
    print(error);
  }

  sendMessage(Message message) async {
    if (message.contactconversationtype == Utils.conversationTypeNormal) {
      String to = Utils.addDomain(message.to);
      await flutterXmpp.sendMessageWithType(to, message.message, message.id.toString(), 0);
    } else {
      String to = Utils.getDomainBareJid(message.to);
      await flutterXmpp.sendGroupMessageWithType(to, message.message, message.id.toString(), 0);
    }
  }

  sendCustomMessage(to, body, id, customMessage, time) async {
    User user = await SharedPrefs.getUser();
    var auth = {
      "user_jid": "${user.username}@${Utils.domain}/${Platform.isAndroid ? "Android" : "iOS"}",
      "password": "${user.password}",
      "host": "${Utils.host}",
      "port": '${Utils.port}',
    };
    flutterXmpp == null ? (flutterXmpp = new XmppConnection(auth)) : null;
    await flutterXmpp?.sendCustomMessage(to, body, id, customMessage, time);
  }

  checkConnection(ConnectivityStatus networkStatus) async {
    Utils.write("ConnectivityStatus ${connectivityToString(networkStatus)} ");
    _connectivityStatus = networkStatus;
    _updateConnectionStatus();
    if (networkStatus.index < ConnectivityStatus.Offline.index) {
      user = await SharedPrefs.getUser();
      if (user != null) {
        connect();
      }
    }
  }

  Future<bool> joinMucGroup(String groupId) async {
    return await flutterXmpp.joinMucGroup(groupId);
  }

  createMucGroups(groupName) async {
    log('groupName :$groupName');
    await flutterXmpp.createMUC(groupName, true);
  }

  addMemberMucGroups({String groupName, String member}) async {
    await flutterXmpp.addMembersInGroup(groupName, [member]);
  }

  Future<List> getMember({String groupName}) async {
    return await flutterXmpp.getMembers(groupName);
  }

  Future removeAdmin({String groupName, String allMembersId}) async {
    await flutterXmpp.removeAdmin(groupName, [allMembersId]);
  }

  Future removeMember({String groupName, String allMembersId}) async {
    await flutterXmpp.removeMember(groupName, [allMembersId]);
  }

  Future createAdmin({String groupName, String allMembersId}) async {
    await flutterXmpp.addAdminsInGroup(groupName, [allMembersId]);
  }

  Future<List<dynamic>> getAdmins({String groupName}) async {
    return await flutterXmpp.getAdmins(groupName);
  }

  Future<List<dynamic>> getOwners({String groupName}) async {
    return await flutterXmpp.getOwners(groupName);
  }

  Future<void> requestMamMessages(
      {String userJid, String requestSince, String requestBefore, String limit}) async {
    User user = await SharedPrefs.getUser();
    var auth = {
      "user_jid": "${user.username}@${Utils.domain}/${Platform.isAndroid ? "Android" : "iOS"}",
      "password": "${user.password}",
      "host": "${Utils.host}",
      "port": '${Utils.port}',
    };
    flutterXmpp = flutterXmpp == null ? new XmppConnection(auth) : flutterXmpp;
    return await flutterXmpp.requestMamMessages(userJid, requestSince, requestBefore, limit);
  }
}
