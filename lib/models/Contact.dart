import 'package:chatsample/models/Message.dart';

class Contact {
  int _contactId;

  String _name;

  String _jid;

  String _lastMsgId;

  int _lastMsgTime;

  String _avatar;

  Message _lastMessage;

  int _conversationType;

  Contact(this._contactId, this._jid, this._name, this._avatar,
      this._lastMsgTime, this._lastMsgId, this._conversationType);

  int get contactId => _contactId;

  String get jid => _jid;

  String get name => _name;

  String get lastmsgId => _lastMsgId;

  String get avatar => _avatar;

  int get lastMsgTime => _lastMsgTime;

  Message get lastMessage => _lastMessage;

  int get conversationtype => _conversationType;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["contactid"] = contactId;
    map["jid"] = jid;
    map["name"] = name;
    map["avatar"] = avatar;
    map["lastmsgtime"] = lastMsgTime;
    map['lastmsgid'] = lastmsgId;
    map["conversationtype"] = conversationtype;
    return map;
  }

  static Contact fromMap(Map contactMap) {
    return new Contact(
      contactMap["contactid"],
      contactMap["jid"],
      contactMap["name"],
      contactMap["avatar"],
      contactMap["lastmsgtime"],
      contactMap["lastmsgid"],
      contactMap["conversationtype"],
    );
  }

  void setJid(String jid) {
    _jid = jid;
  }

  void setContactId(int id) {
    _contactId = id;
  }

  void setName(String name) {
    _name = name;
  }

  void setAvatar(String avatar) {
    _avatar = avatar;
  }

  void setLastMsgTime(int time) {
    _lastMsgTime = time;
  }

  void setLastMsgId(String msgId) {
    _lastMsgId = msgId;
  }

  void setLastMessage(Message lastMsg) {
    _lastMessage = lastMsg;
  }

  void setConversationType(int conversationType) {
    _conversationType = conversationType;
  }

  @override
  String toString() {
    return "{ id : $contactId, name : $name, jid : $jid, avatar : $avatar, lastmsgid : $lastmsgId, lastMsgTime : $lastMsgTime, conversationtype : $conversationtype}";
  }
}
