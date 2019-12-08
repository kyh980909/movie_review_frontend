import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_review_frontend/page/UserInfoPage.dart';
import 'LoginPage.dart';
import 'package:movie_review_frontend/page/AddMovieReviewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/storage.dart';
import 'ReviewListPage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final Map userData;
  HomePage({
    Key key,
    @required this.userData,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Storage storage = new Storage();
  int _selectedIndex = 0;
  final List<Widget> _children = [
    ReviewListPage(),
    AddMovieReviewPage(),
    UserInfoPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(widget.userData),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.home),
              title: Text('')),
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.add_box),
              title: Text('')),
          BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(Icons.person),
              title: Text('')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[300],
        onTap: _onItemTapped,
      ),
    );
  }

  Container drawer(userData) {
    return Container(
      width: 180.0,
      child: Drawer(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 3,
              child: DrawerHeader(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Container(
                  color: Colors.green[300],
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '환영합니다',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                          Text(
                            '${userData['id']} 님',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 17,
              child: ListTile(
                title: Text(
                  '로그아웃',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()));
                },
              ),
            ),
            Flexible(
              flex: 2,
              child: ListTile(
                title: Text(
                  '회원탈퇴',
                  style: TextStyle(fontSize: 16.0, color: Colors.red),
                ),
                onTap: () async {
                  final url = 'http://${Storage.ip}:4000/api/user/remove';
                  try {
                    final res = await http
                        .post(url, body: {'id': widget.userData['id']}); // 응답
                    // id, pw 입력했을 때
                    if (res.statusCode == 200) {
                      final jsonBody = json.decode(res.body);
                      final loginResult = jsonBody['success'];
                      if (loginResult) {
                        Fluttertoast.showToast(
                            msg: '회원탈퇴가 되었습니다.',
                            toastLength: Toast.LENGTH_SHORT);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.clear();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage()));
                      } else {
                        print(jsonBody['error']);
                        Fluttertoast.showToast(
                            msg: '회원탈퇴에 실패했습니다.',
                            toastLength: Toast.LENGTH_SHORT);
                      }
                      print(loginResult);
                    }
                  } catch (err) {
                    print(err);
                    Fluttertoast.showToast(
                        msg: '회원탈퇴에 실패했습니다.', toastLength: Toast.LENGTH_SHORT);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
