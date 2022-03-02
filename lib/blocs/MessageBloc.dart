import 'dart:developer';

import 'package:chatsample/blocs/ContactBloc.dart';
import 'package:chatsample/blocs/QueueBloc.dart';
import 'package:chatsample/db/api/ConactApi.dart';
import 'package:chatsample/db/api/MessageApi.dart';
import 'package:chatsample/enums/bubble_type.dart';
import 'package:chatsample/models/Contact.dart';
import 'package:chatsample/models/Message.dart';
import 'package:chatsample/models/Queue.dart';
import 'package:chatsample/services/db_helper.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:chatsample/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class MessageBloc {
  DatabaseHelper databaseHelper = new DatabaseHelper();

  final _messageListSink = PublishSubject<List<Message>>();

  Observable<List<Message>> get messageListObserver => _messageListSink.stream;

  final _messageLink = PublishSubject<Message>();

  Observable<Message> get messageObserver => _messageLink.stream;

  static List<Message> _messages = new List<Message>();

  static final MessageBloc _instance = MessageBloc._internal();

  factory MessageBloc() => _instance;

  static String _currentuser = Utils.emptyString;

  MessageBloc._internal() {
    ContactBloc.instance.currentContactObserver.listen((currentJid) => _setCurrentUser(currentJid));
  }

  static MessageBloc get instance => _instance;

  getMessages() async {
    _messages = await MessageApi.getMessages();
    _messageListSink.add(_messages);
  }

  getMessagesWithJid(String jid) async {
    _messages = await MessageApi.getMessagesWithJid(jid);
    _messageListSink.add(_messages);
  }

  addMessage(String messageString, String toUser, int conversationType) async {
    if (messageString.toLowerCase().contains("send plain")) {
      var commands = messageString.split(" ");
      if (commands.length > 2) {
        var noOfMessage = commands[2];
        int totalMessage = int.parse(noOfMessage);

        addMessage("start", toUser, conversationType);

        for (int i = 0; i < totalMessage; i++) {
          addMessage("$i", toUser, conversationType);
          await Future.delayed(const Duration(seconds: 1));
        }

        addMessage("end", toUser, conversationType);
      }
    } else {
      int currentTime = new DateTime.now().millisecondsSinceEpoch;
      String id = "$currentTime";

      Message message = Message(id: id, message: messageString, status: 0, dir: 0, to: toUser, time: currentTime, senderJid: XmppService.instance.user.username, contactconversationtype: conversationType, bubbleType: BubbleType.TEXT.index, isReadSent: 0); //TODO : temporary set (BubbleType.TEXT.index)
      Queue queue = Queue(id, id, currentTime);
      MessageApi.saveMessage(message);

      Contact contact = await ContactApi.getContact(toUser);
      contact.setLastMsgId(id);
      contact.setLastMsgTime(currentTime);

      QueueBloc.instance.addQueue(queue);
      ContactBloc.instance.updateContact(contact);

      _messages.insert(0, message);
      _messageListSink.add(_messages);
    }
  }

  addMessageWithType(String messageString, String toUser, int conversationType, BubbleType bubbleType,
      [String mediaURL]) async {
    if (messageString.toLowerCase().contains("send plain")) {
      var commands = messageString.split(" ");
      if (commands.length > 2) {
        var noOfMessage = commands[2];
        int totalMessage = int.parse(noOfMessage);

        addMessage("start", toUser, conversationType);

        for (int i = 0; i < totalMessage; i++) {
          addMessage("$i", toUser, conversationType);
          await Future.delayed(const Duration(seconds: 1));
        }

        addMessage("end", toUser, conversationType);
      }
    } else {
      int currentTime = new DateTime.now().millisecondsSinceEpoch;
      String id = "$currentTime";

      Message message =
      Message(id: id, message: messageString, status: 0, dir: 0, to: toUser, time: currentTime, senderJid: XmppService.instance.user.username, contactconversationtype: conversationType, bubbleType: bubbleType.index, isReadSent: 0, mediaURL: mediaURL);
      Queue queue = Queue(id, id, currentTime);

      MessageApi.saveMessage(message);

      Contact contact = await ContactApi.getContact(toUser);
      contact.setLastMsgId(id);
      contact.setLastMsgTime(currentTime);

      QueueBloc.instance.addQueue(queue);
      ContactBloc.instance.updateContact(contact);

      _messages.insert(0, message);
      _messageListSink.add(_messages);
    }
  }

  deleteMessage(Message message) {
    MessageApi.deleteMessage(message);
  }

  updateMessageStatus(String messageId, int statusType) async {
    Message message = await MessageApi.getMessage(messageId);
    if (message != null && message.status < statusType) {
      message.setStatus(statusType);
      await MessageApi.update(message);
      // Updating message list
      _instance.getMessagesWithJid(message.to);
    }
  }
  updateDeliveryTime(String messageId, int deliveryReceiptTime) async {
    Message message = await MessageApi.getMessage(messageId);
    if (message != null) {
      message.setdeliveryReceiptTime(deliveryReceiptTime);
      await MessageApi.update(message);
      // Updating message list
      _instance.getMessagesWithJid(message.to);
    }
  }
  updateReadTime(String messageId, int readReceiptTime) async {
    Message message = await MessageApi.getMessage(messageId);
    if (message != null) {
      message.setreadReceiptTime(readReceiptTime);
      await MessageApi.update(message);
      _instance.getMessagesWithJid(message.to);
    }
  }

  updateReadFlag(String messageId, int isReadSent) async {
    Message message = await MessageApi.getMessage(messageId);
    if (message != null) {
      message.setisReadSent(isReadSent);
      await MessageApi.update(message);
      // Updating message list
      _instance.getMessagesWithJid(message.to);
    }
  }

  saveReceivedMessage(Message message) async {
    if(await MessageApi.getMessage(message.id) != null){
      return;
    }
    String to = Utils.removeDomain(message.to);
    await MessageApi.saveMessage(message);
    Contact contact = await ContactApi.getContact(message.to);
    if (contact == null) {
      contact = new Contact(message.time, to, to, "", message.time, message.id, Utils.conversationTypeNormal);
//      await ContactBloc.instance.addContact(to);
    }
    else {
      contact.setLastMsgId(message.id);
      contact.setLastMsgTime(message.time);
      await ContactBloc.instance.updateContact(contact);
    }

    if (to == _currentuser) {
      _instance.getMessagesWithJid(to);
    }
  }

  destroy() {
    _messageListSink.close();
    _messageLink.close();
  }

  _setCurrentUser(String currentJid) {
    _currentuser = currentJid;
  }
}
