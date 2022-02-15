class User {
  String _username;

  String _password;
  String _host;
  String _port;

  User(this._username, this._password, this._host, this._port);

  String get username => _username;

  String get password => _password;

  String get host => _host;

  String get port => _port;
}
