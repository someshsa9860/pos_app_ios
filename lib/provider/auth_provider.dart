import "dart:convert";

import "package:flutter/cupertino.dart";
import "package:http/http.dart" as http;
import 'package:pos_app/data_management/api.dart';
import "package:shared_preferences/shared_preferences.dart";

import "../data_management/user.dart";

enum AuthStatus {
  authenticated,
  unAuthenticated,
  unAuthenticating,
  authenticating,
  unInitialized,
}

class AuthProvider extends ChangeNotifier {
  var _info = "";

  AuthStatus status = AuthStatus.unInitialized;

  String get info => _info;
  String api = "https://pospoa.com/pos/oauth/token";

  final User _user = User();

  initAuthProvider() async {
    var tok = await getUser();

    if (tok != null) {
      status = AuthStatus.authenticated;
      notifyListeners();
    } else {
      status = AuthStatus.unAuthenticated;
    }
    notifyListeners();
  }

  setHeader() => {
        "Content-type": "application/json",
        "Accept": "application/json",
      };

  Future<bool> login(String username, String password) async {
    status = AuthStatus.authenticating;
    var url = api;
    notifyListeners();
    _user.username = username;
    _user.password = password;
    Map<String, dynamic> body = {
      "grant_type": "password",
      "client_id": "4",
      "client_secret": "kXXMnZ7eQ6ZXJ4hOpSQVMysphrlOINdTic0HQrO5",
      "username": username,
      "password": password,
      "scope": "",
    };

    _info = "Server error";
    try {
      var response = await http.post(Uri.parse(url),
          headers: setHeader(), body: jsonEncode(body));

      Map<String, dynamic> result = json.decode(response.body);

      if (response.statusCode == 200) {
        _info = "Authenticated";
        _user.token = result["access_token"];
        _user.id = result["id"];
        _user.token = result["access_token"];
        _user.expiresIn = DateTime.now()
            .add(Duration(seconds: int.parse(result["expires_in"].toString())))
            .toIso8601String();

        status = AuthStatus.authenticated;
        storeData(result);
        notifyListeners();
        return true;
      } else {
        _info = result["message"];
        notifyListeners();
      }

      if (response.statusCode == 401) {
        _info = "invalid username or password";
        status = AuthStatus.unAuthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _info = "Please connect to internet";
      notifyListeners();
    }

    status = AuthStatus.unAuthenticated;
    notifyListeners();
    return false;
  }

  getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var v = preferences.getString("user");
    if (v == null||v.isEmpty) {
      return null;
    }

    var userData = jsonDecode(v);
    _user.username = userData["username"];
    _user.password = userData["password"];
    _user.token = userData["token"];
    _user.id = userData["id"];
    _user.expiresIn = userData["expiresIn"];

    if (_user.expiresIn != null) {
      if (DateTime.parse(_user.expiresIn!).isBefore(DateTime.now())) {
        //_token = _user.token;
        return null;
      }
    }
    return _user;
  }

  getUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var username = preferences.getString("username");
    return username;
  }

  getPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var v = preferences.getString("password");
    return v;
  }

  storeData(Map<String, dynamic> result) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("user", _user.toJson);
  }

  logout() async {
    status = AuthStatus.unAuthenticating;
    _info = "";
    user.token=null;
    notifyListeners();

    status = AuthStatus.unAuthenticated;
    _info = "";
    notifyListeners();
  }

  expired() async {
    status = AuthStatus.unAuthenticated;
    _info = "Session Expired. Please Login Again";
    await getUser();
    await login(_user.username ?? "", _user.password ?? "");

    notifyListeners();
    //await preferences.clear();
  }
}
