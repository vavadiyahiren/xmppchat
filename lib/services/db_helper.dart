import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE Message(msgid TEXT PRIMARY KEY, message TEXT, status INTEGER, dir INTEGER, tostr TEXT, time INTEGER, senderJid TEXT, contactconversationtype INTEGER, bubbleType INTEGER, mediaURL TEXT, isReadSent INTEGER,deliveryReceiptTime INTEGER,readReceiptTime INTEGER)");

    await db.execute(
        "CREATE TABLE Queue(id TEXT PRIMARY KEY, messageid TEXT, lastattempted INTEGER)");

    await db.execute(
        "CREATE TABLE Contact(contactid INTEGER PRIMARY KEY, jid TEXT, name TEXT, avatar TEXT, lastmsgtime INTEGER, lastmsgid TEXT, conversationtype INTEGER)");
  }

  delete() async{
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    await deleteDatabase(path);
  }
}
