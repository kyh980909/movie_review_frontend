import 'dart:convert';
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'package:movie_review_frontend/page/AddMovieReviewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/storage.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  final Map userData;
  MainPage({
    Key key,
    @required this.userData,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Storage storage = new Storage();

  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    var response =
        await http.get('http://localhost:4000/api/movie/get_review_list');
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        return result['result'];
      } else {
        print(result['error']);
        return result['error'];
      }
    } else {
      throw Exception('Failed to laod data');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double paddingLeft = 16.0;

    return Scaffold(
      drawer: drawer(widget.userData),
      body: Container(
          child: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: paddingLeft, vertical: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  snapshot.data[index]['writer'],
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(snapshot.data[index]['title']),
                                Text(snapshot.data[index]['date'])
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Image.memory(
                              base64Decode(snapshot.data[index]['ticket'])),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: paddingLeft),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Text(
                                '별점: ${snapshot.data[index]['score']}점',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: paddingLeft, bottom: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      snapshot.data[index]['writer'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    snapshot.data[index]['review'],
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  AddMovieReviewPage(userData: widget.userData)));
        },
        child: Icon(Icons.add),
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
                  color: Colors.blue,
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
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${userData['id']} 님',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
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
