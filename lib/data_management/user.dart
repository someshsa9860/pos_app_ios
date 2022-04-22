import 'dart:convert';

class User {
  String? username ;
  String? id ;
  String? password ;
  String? token ;
  String? expiresIn ;

  //User(this.username, this.password, this.token, this.expiresIn);

  User();

  String get toJson {
    return jsonEncode({
      'username': username,
      'password': password,
      'token': token,
      'expiresIn': expiresIn,
    });
  }
}
