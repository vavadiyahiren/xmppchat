import 'package:chatsample/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<void> saveUser(User user) async {
    print("Save user pref ==> ${user.username}  ${user.password}");
    final SharedPreferences prefs = await _prefs;
    await prefs.setString("username", user.username);
    await prefs.setString("password", user.password);
  }

  static Future<User> getUser() async {
    final SharedPreferences prefs = await _prefs;
    String username = prefs.getString("username") != null ? prefs.getString("username") : "";
    String password = prefs.getString("password") != null ? prefs.getString("password") : "";
    String host = prefs.getString("host") != null ? prefs.getString("host") : "";
    String post = prefs.getString("post") != null ? prefs.getString("post") : "";

    if (username != "" && password != "") {
      return User(username, password,host,post);
    }
    return null;
  }

  static Future<void> clearUser() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("username", "");
    prefs.setString("password", "");
  }
}
