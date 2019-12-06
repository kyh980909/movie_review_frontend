import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_review_frontend/LoginPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _pwFocus = FocusNode();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool _isObscured = true;
  String autoLoginCheck = "false";
  Color _eyeButtonColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Text(
              '회원가입',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Image.asset(
              'images/sign-up.png',
              width: 200,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, right: 40.0, bottom: 5.0),
                  child: buildIdTextField(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, right: 40.0, bottom: 30.0),
                  child: buildPasswordInput(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, right: 40.0, bottom: 30.0),
                  child: buildRegisterButton(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '이미 계정이 있으신가요?',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: InkWell(
                          onTap: () {
                            print('tap');
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LoginPage()));
                          },
                          child: Text(
                            '로그인',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextFormField buildIdTextField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _idController,
      decoration: InputDecoration(
          labelText: '아이디', icon: Icon(Icons.account_box), hintText: '아이디'),
      validator: (id) {
        if (id.isEmpty) {
          return '아이디를 입력하세요';
        } else {
          return null;
        }
      },
      onFieldSubmitted: (v) {
        // 키보드 다음 텍스트 필드로 옮기는 효과
        FocusScope.of(context).requestFocus(_pwFocus);
      },
    );
  }

  TextFormField buildPasswordInput(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.done,
      focusNode: _pwFocus,
      obscureText: _isObscured,
      controller: _pwController,
      validator: (pw) {
        if (pw.isEmpty) {
          return '비밀번호를 입력하세요';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
          labelText: '비밀번호',
          icon: Icon(Icons.vpn_key),
          suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeButtonColor,
              ),
              onPressed: () {
                if (_isObscured) {
                  setState(() {
                    _isObscured = false;
                    _eyeButtonColor = Theme.of(context).primaryColor;
                  });
                } else {
                  setState(() {
                    _isObscured = true;
                    _eyeButtonColor = Colors.grey;
                  });
                }
              })),
    );
  }

  Container buildRegisterButton(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      child: RaisedButton(
          onPressed: () async {
            print(_idController.text.toString());
            if (_formKey.currentState.validate()) {
              final url = 'http://localhost:4000/api/user/register';
              final res = await http.post(url, body: {
                'id': _idController.text.toString(),
                'pw': _pwController.text.toString()
              }); // 응답
              // id, pw 입력했을 때
              // Only gets here if the fields pass
              if (res.statusCode == 200) {
                final jsonBody = json.decode(res.body);
                print(jsonBody);
                final loginResult = jsonBody['success'];
                if (loginResult) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()));
                }
                print(loginResult);
              }
            }
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.grey[900],
          child:
              Text('회원가입', style: Theme.of(context).primaryTextTheme.button)),
    );
  }
}
