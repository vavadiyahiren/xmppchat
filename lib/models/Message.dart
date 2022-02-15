import 'package:chatsample/enums/bubble_type.dart';

class Message {
  String id;
  String message;
  int status;
  int dir;
  String to;
  int time;
  String senderJid;
  int contactconversationtype;
  int bubbleType;
  String mediaURL;
  int isReadSent;
  int readReceiptTime;
  int deliveryReceiptTime;

  Message({
    this.id,
    this.message,
    this.status,
    this.dir,
    this.to,
    this.time,
    this.senderJid,
    this.contactconversationtype,
    this.bubbleType,
    this.mediaURL,
    this.isReadSent,
    this.readReceiptTime,
    this.deliveryReceiptTime,
  });

  String get _id => id;

  String get _message => message;

  int get _status => status;

  int get _dir => dir;

  String get _to => to;

  int get _time => time;

  String get _senderJid => senderJid;

  int get _contactconversationtype => contactconversationtype;

  int get _bubbleType => bubbleType;

  String get _mediaURL => mediaURL;

  int get _isReadSent => isReadSent;

  int get _deliveryReceiptTime => deliveryReceiptTime;

  int get _readReceiptTime => readReceiptTime;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["msgid"] = id;
    map["message"] = message ?? 'a';
    map["status"] = status;
    map['dir'] = dir;
    map['tostr'] = to;
    map['time'] = time;
    map['senderJid'] = senderJid;
    map["contactconversationtype"] = contactconversationtype;
    map["bubbleType"] = bubbleType;
    map["mediaURL"] = mediaURL ?? 'a';
    map["isReadSent"] = isReadSent ?? 0;
    map["deliveryReceiptTime"] = deliveryReceiptTime ?? 0;
    map["readReceiptTime"] = readReceiptTime ?? 0;
    return map;
  }

  static Message fromMap(Map messageMap) {
    return new Message(
      id: messageMap["msgid"],
      message: messageMap["message"],
      status: messageMap["status"],
      dir: messageMap["dir"],
      to: messageMap["tostr"],
      time: messageMap["time"],
      senderJid: messageMap["senderJid"],
      contactconversationtype: messageMap["contactconversationtype"],
      bubbleType: messageMap["bubbleType"],
      mediaURL: messageMap["mediaURL"],
      isReadSent: messageMap['isReadSent'],
      readReceiptTime: messageMap['readReceiptTime'],
      deliveryReceiptTime: messageMap['deliveryReceiptTime'],
    );
  }

  void setMesssage(String _message) {
    this.message = _message;
  }

  void setId(String _id) {
    this.id = _id;
  }

  void setStatus(int _status) {
    this.status = _status;
  }

  void setTime(int _time) {
    this.time = _time;
  }

  void setSenderJid(String _senderJid) {
    this.senderJid = _senderJid;
  }

  void setConversationType(int _conversationType) {
    contactconversationtype = _conversationType;
  }

  void setBubbleType(BubbleType _bubbleType) {
    bubbleType = _bubbleType.index;
  }

  void setMediaURl(String _mediaURL) {
    mediaURL = _mediaURL;
  }

  void setisReadSent(int _isReadSent) {
    isReadSent = _isReadSent;
  }

  void setdeliveryReceiptTime(int _deliveryReceiptTime) {
    deliveryReceiptTime = _deliveryReceiptTime;
  }

  void setreadReceiptTime(int _readReceiptTime) {
    readReceiptTime = _readReceiptTime;
  }

  @override
  String toString() {
      return "{ msgid : $_id , message : $_message ,status : $_status ,dir : $_dir , tostr : $_to , time : $_time , senderJid : $_senderJid , contactconversationtype : $_contactconversationtype, bubbleType : $_bubbleType, mediaURL : $_mediaURL ,isReadSent : $_isReadSent,deliveryReceiptTime : $_deliveryReceiptTime,readReceiptTime : $_readReceiptTime}";
  }
}
