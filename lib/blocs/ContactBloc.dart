import 'package:chatsample/db/api/ConactApi.dart';
import 'package:chatsample/models/Contact.dart';
import 'package:chatsample/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class ContactBloc {
  static final ContactBloc _instance = ContactBloc._internal();

  static ContactBloc get instance => _instance;

  final _currentContactSink = PublishSubject<String>();

  Observable<String> get currentContactObserver => _currentContactSink.stream;

  final _contactListSink = PublishSubject<List<Contact>>();

  Observable<List<Contact>> get contactListObserver => _contactListSink.stream;

  final _contactSink = PublishSubject<Contact>();

  static String _currentConversation = Utils.emptyString;

  Observable<Contact> get contactObserver => _contactSink.stream;

  setCurrentContact(String jid) async {
    _currentConversation = jid;
    _currentContactSink.add(_currentConversation);
  }

  getCurrentContact() async {
    _currentContactSink.add(_currentConversation);
  }

  getContacts() async {
    List<Contact> contacts = await ContactApi.getContacts();
    if (contacts.length > 0) {
      _contactListSink.add(contacts);
    }
  }

  getContact(String jid) async {
    Contact contact = await ContactApi.getContact(jid);
    if (contact != null) {
      _contactSink.add(contact);
    }
  }

  addContact(String jid,int timeStamp, bool isCreateGroup,bool isJoinGroup,) async {
    if (jid != null && jid != "") {
      Contact contact = await ContactApi.getContact(jid);
      if (contact == null) {
        int currentTime = new DateTime.now().millisecondsSinceEpoch;
        contact = new Contact(
          currentTime,
          jid,
          jid,
          "",
          currentTime,
          "",
          (isCreateGroup || isJoinGroup)
              ? Utils.conversationTypeGroup
              : Utils.conversationTypeNormal,
        );

        await ContactApi.saveContact(contact);

        if (isCreateGroup) {
          Utils.createSingleMucGroups(jid);
        }
        if (isJoinGroup) {
          Utils.joinSingleMucGroups(jid,timeStamp);
        }

        List<Contact> contacts = await ContactApi.getContacts();
        if (contacts.length > 0) {
          _contactListSink.add(contacts);
        }
      }
    }
  }

  updateContact(Contact contact) async {
    await ContactApi.updateContact(contact);
    getContacts();
  }

  dispose() {
    _contactListSink.close();
    _contactSink.close();
    _currentContactSink.close();
  }

  ContactBloc._internal();
}
