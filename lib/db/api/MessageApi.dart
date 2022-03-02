import 'dart:developer';

import 'package:chatsample/models/Message.dart';
import 'package:chatsample/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class MessageApi {
  static DatabaseHelper databaseHelper = new DatabaseHelper();

  static Future<int> saveMessage(Message message) async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.insert("Message", message.toMap());
    log('dbClient response $res');
    return res;
  }

  static Future<List<Message>> getMessages() async {
    var dbClient = await databaseHelper.db;
    List<Map> list =
    await dbClient.rawQuery('SELECT * FROM Message order by time desc');
    List<Message> messages = new List();
    for (int i = 0; i < list.length; i++) {
      messages.add(Message.fromMap(list[i]));
    }
    return messages;
  }

  static Future<int> getLastMessageTime() async {
    var dbClient = await databaseHelper.db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT max(time) FROM Message WHERE dir = ?', [1]));
  }

  static Future<int> getLastDeliveryReceiptTime() async {
    var dbClient = await databaseHelper.db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT max(deliveryReceiptTime) FROM Message WHERE dir = ?', [1]));
  }

  static Future<int> getLastReadReceiptTimeTime() async {
    var dbClient = await databaseHelper.db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT max(readReceiptTime) FROM Message WHERE dir = ?', [1]));
  }

  static Future<Message> getMessage(String messageId) async {
    var dbClient = await databaseHelper.db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Message  WHERE msgid = ?', [messageId]);
    List<Message> messages = new List();
    for (int i = 0; i < list.length; i++) {
      messages.add(Message.fromMap(list[i]));
    }
    return messages.length > 0 ? messages.first : null;
  }

  static Future<Message> getParticularMessage() async {
    var dbClient = await databaseHelper.db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Message ORDER BY time desc limit 1');
    List<Message> messages = new List();
    for (int i = 0; i < list.length; i++) {
      messages.add(Message.fromMap(list[i]));
    }
    return messages.length > 0 ? messages.first : null;
  }

  static Future<List<Message>> getMessagesWithJid(String jid) async {
    var dbClient = await databaseHelper.db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Message where tostr = ? order by time desc', [jid]);
    List<Message> messages = new List();
    for (int i = 0; i < list.length; i++) {
      messages.add(Message.fromMap(list[i]));
    }
    return messages;
  }

  static Future<List<Message>> getUnReadMessagesWithJid(String jid) async {
    var dbClient = await databaseHelper.db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Message where tostr = ? and isReadSent = ? and dir = ? order by time desc',
        [jid, 0, 1]);
    List<Message> messages = [];
    print("Pending read receipts message length: ${list.length}");
    for (int i = 0; i < list.length; i++) {
      messages.add(Message.fromMap(list[i]));
    }
    return messages;
  }

  static Future<int> deleteMessage(Message message) async {
    var dbClient = await databaseHelper.db;

    int res = await dbClient
        .rawDelete('DELETE FROM Message WHERE msgid = ?', [message.id]);
    return res;
  }

  static Future<bool> update(Message message) async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.update("Message", message.toMap(),
        where: " msgid = ?", whereArgs: <String>[message.id]);
    return res > 0 ? true : false;
  }

  static Future<int> deleteAllMessage() async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.rawDelete('DELETE FROM Message');
    return res;
  }
}
