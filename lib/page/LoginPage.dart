import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_review_frontend/page/RegisterPage.dart';
import '../model/user.dart';
import '../util/storage.dart';
import 'MainPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    Key key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _pwFocus = FocusNode();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool _isObscured = true;
  String autoLoginCheck = "false";
  Color _eyeButtonColor = Colors.grey;
  Storage storage = new Storage();

  @override
  void initState() {
    super.initState();
    storage.autoLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Text(
              '로그인',
              style: TextStyle(fontSize: 30.0),
            ),
          ),
          Image.asset(
            'images/ticket.png',
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
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
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: buildLoginButton(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '회원이 아니신가요?',
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
                                          RegisterPage()));
                            },
                            child: Text(
                              '회원가입',
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

  Builder buildLoginButton(BuildContext context) {
    return Builder(
      builder: (context) {
        return Container(
          height: 50.0,
          width: double.infinity,
          child: RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  final url = 'http://localhost:4000/api/user/login';
                  try {
                    final res = await http.post(url, body: {
                      'id': _idController.text.toString(),
                      'pw': _pwController.text.toString()
                    }); // 응답
                    final userData = User(_idController.text.toString(),
                        _pwController.text.toString());
                    // id, pw 입력했을 때
                    if (res.statusCode == 200) {
                      final jsonBody = json.decode(res.body);
                      final loginResult = jsonBody['success'];
                      if (loginResult) {
                        storage.setUserData(_idController.text.toString(),
                            _pwController.text.toString());
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => MainPage(
                                  userData: userData.toJson(),
                                )));
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(jsonBody['error']),
                        ));
                      }
                      print(loginResult);
                    }
                  } catch (err) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('서버가 닫혀있습니다.'),
                    ));
                  }
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.grey[900],
              child: Text('로그인',
                  style: Theme.of(context).primaryTextTheme.button)),
        );
      },
    );
  }
}
