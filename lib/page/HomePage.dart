import 'package:flutter/material.dart';
import 'package:movie_review_frontend/page/UserInfoPage.dart';
import 'LoginPage.dart';
import 'package:movie_review_frontend/page/AddMovieReviewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/storage.dart';
import 'ReviewListPage.dart';

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
              icon: Icon(Icons.person_outline),
              title: Text('')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
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
            Flexible(
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
          ],
        ),
      ),
    );
  }
}
