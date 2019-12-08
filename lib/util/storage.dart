import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movie_review_frontend/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../page/HomePage.dart';

class Storage {
  static final String ip = 'localhost';
  void autoLogin(context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String id = prefs.getString('id');
      final String pw = prefs.getString('pw');

      final userData = User(id, pw);
      final url = 'http://$ip:4000/api/user/login';
      final res = await http.post(url, body: {'id': id, 'pw': pw}); // 요청
      // id, pw 입력했을 때
      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body);
        final loginResult = jsonBody['success'];
        if (loginResult) {
          print('자동로그인');
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  HomePage(userData: userData.toJson())));
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(jsonBody['error']),
          ));
        }
        print(loginResult);
      }
    } catch (err) {
      print(err);
    }
  }

  void setUserData(String id, String pw) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', id);
    prefs.setString('pw', pw);
  }

  getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }
}
