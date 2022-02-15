import 'package:chatsample/db/api/ConactApi.dart';
import 'package:chatsample/db/api/MessageApi.dart';
import 'package:chatsample/db/api/QueueApi.dart';
import 'package:chatsample/models/User.dart';
import 'package:chatsample/services/sharedPrefs.dart';
import 'package:chatsample/services/xmppService.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final _loginSink = PublishSubject<User>();

  Observable<User> get loginObserver => _loginSink.stream;

  static final LoginBloc _instance = LoginBloc._internal();

  factory LoginBloc() => _instance;

  LoginBloc._internal();

  static LoginBloc get instance => _instance;

  getUser() async {
    User user = await SharedPrefs.getUser();
    _loginSink.add(user);
  }

  logout() async {
    await SharedPrefs.clearUser();
    await MessageApi.deleteAllMessage();
    await QueueApi.deleteAllQueue();
    await ContactApi.deleteAllContact();
    _loginSink.add(null);
    XmppService.instance.disconnectXMPP();
  }

  dispose() {
    _loginSink.close();
  }
}
