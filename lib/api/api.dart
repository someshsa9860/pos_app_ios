import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String token = '';

class CallApi {
  final String url = 'http://pospoa.com/pos/';

  Future<http.Response> postData(data, apiUrl) async {
    token = await _getToken();
    var fulUrl = url + apiUrl;
    return http.post(Uri.parse(fulUrl),
        body: jsonEncode(data), headers: _setHeader());
  }

  Future<http.Response> putData(data, apiUrl) async {
    token = await _getToken();
    var fulUrl = url + apiUrl;
    return http.put(Uri.parse(fulUrl),
        body: jsonEncode(data), headers: _setHeader());
  }

  Future<http.Response> getData(apiUrl, {body}) async {
    var fulUrl = url + apiUrl;
    token = await _getToken();
    if (body != null) {
      final uri = Uri.http('pospoa.com', 'pos/' + apiUrl, body);
      return http.get(uri, headers: _setHeader());
    }
    return http.get(Uri.parse(fulUrl), headers: _setHeader());
  }

  _setHeader() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token}'
      };

  _getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    return '$token';
  }
}
