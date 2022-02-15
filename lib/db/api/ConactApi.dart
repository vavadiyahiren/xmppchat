import 'package:chatsample/models/Contact.dart';
import 'package:chatsample/models/Message.dart';
import 'package:chatsample/services/db_helper.dart';

class ContactApi {
  static DatabaseHelper databaseHelper = new DatabaseHelper();

  static Future<int> saveContact(Contact contact) async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.insert("Contact", contact.toMap());

    Contact c = await getContact(contact.jid);
    print('contactTesting type: ${c.conversationtype} c: ${c.toMap()}');

    return res;
  }

  static Future<List<Contact>> getContacts() async {
    var dbClient = await databaseHelper.db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT c.*,m.* FROM Contact c left join Message m on c.lastmsgid = m.msgid order by lastmsgtime desc');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      Contact contact = Contact.fromMap(list[i]);
      Message message = Message.fromMap(list[i]);
      contact.setLastMessage(message);
      contacts.add(contact);
    }
    return contacts;
  }

  static Future<Contact> getContact(String jid) async {
    var dbClient = await databaseHelper.db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Contact WHERE jid = ?', [jid]);
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(Contact.fromMap(list[i]));
    }
    return contacts.length > 0 ? contacts.first : null;
  }

  static Future<int> deleteContact(String jid) async {
    var dbClient = await databaseHelper.db;

    int res =
        await dbClient.rawDelete('DELETE FROM Contact WHERE jid = ?', [jid]);
    return res;
  }

  static Future<bool> updateContact(Contact contact) async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.update("Contact", contact.toMap(),
        where: " jid = ?", whereArgs: <String>[contact.jid]);
    return res > 0 ? true : false;
  }

  static Future<int> deleteAllContact() async {
    var dbClient = await databaseHelper.db;
    int res = await dbClient.rawDelete('DELETE FROM Contact');
    return res;
  }

  static Future<List<Contact>> getContactsFromConversationType(
      int conversationType) async {
    var dbClient = await databaseHelper.db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Contact WHERE conversationType = ?', [conversationType]);
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      Contact contact = Contact.fromMap(list[i]);
      Message message = Message.fromMap(list[i]);
      contact.setLastMessage(message);
      contacts.add(contact);
    }
    return contacts;
  }
}
