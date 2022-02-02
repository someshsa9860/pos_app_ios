import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pos_app/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  authenticated,
  unAuthenticated,
  authenticating,
  unInitialized,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unInitialized;
  var _info;
  var username;
  var password;

  AuthStatus get status => _status;

  String get info => _info;
  String api = 'http://pospoa.com/pos/oauth/token';

  initAuthProvider() async {
    var tok = await getToken();

    if (tok != null) {
      token = tok;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unAuthenticated;
    }
    notifyListeners();
  }

  setHeader() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    var url = api;

    this.username = username;
    this.password = password;
    Map<String, dynamic> body = {
      'grant_type': 'password',
      'client_id': '4',
      'client_secret': 'kXXMnZ7eQ6ZXJ4hOpSQVMysphrlOINdTic0HQrO5',
      'username': username,
      'password': password,
      'scope': '',
    };

    _info = 'Server error';
    try {
      var response = await http.post(Uri.parse(url),
          headers: setHeader(), body: jsonEncode(body));

      Map<String, dynamic> result = json.decode(response.body);

      print(result.toString());
      if (response.statusCode == 200) {
        _info = 'Authenticated';
        _status = AuthStatus.authenticated;
        token = result['token'];
        storeData(result);

        notifyListeners();
        return true;
      }

      if (response.statusCode == 401) {
        _info = 'invalid username or password';
        _status = AuthStatus.unAuthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _info = e.toString();
    }

    _status = AuthStatus.unAuthenticated;
    notifyListeners();
    return false;
  }

  getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var v = preferences.getString('token');
    return await getExpiry(v);
  }

  getUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var username = preferences.getString('username');
    return username;
  }

  getExpiry(token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var expiresIn = preferences.getInt('expires_in');
    var time = preferences.getString('time');
    if (time == null) {
      return null;
    }
    var duration = DateTime.now().difference(DateTime.parse(time));
    print(duration.inSeconds);
    print(duration.inMilliseconds);
    print(expiresIn);
    if (duration.inSeconds > (expiresIn ?? 0)) {
      return null;
    }
    return token;
  }

  getPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var v = preferences.getString('password');
    return v;
  }

  void storeData(Map<String, dynamic> result) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', result['access_token']);
    await preferences.setString('username', username);
    await preferences.setString('password', password);
    await preferences.setString('time', DateTime.now().toString());
    await preferences.setInt('expires_in', result['expires_in']);
  }

  logout([bool tokenExpired = false]) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _status = AuthStatus.unAuthenticated;
    if (tokenExpired) {
      _info = 'Session Expired. Please Login Again';
      login(await getUsername(), await getPassword());
    }
    notifyListeners();
    await preferences.clear();
  }
}
