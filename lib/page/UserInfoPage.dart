import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_review_frontend/util/storage.dart';
import 'package:http/http.dart' as http;

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Storage storage = new Storage();
  Map myMovieListData = new Map();
  bool lock = true;

  @override
  void initState() {
    super.initState();
  }

  Future getMyMovieList() async {
    if (mounted) {
      var response = await http.get(
          'http://${Storage.ip}:4000/api/movie/my_movie_list/${await storage.getUserId()}');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          myMovieListData['writer'] = await storage.getUserId();
          myMovieListData['result'] = result['result'];
          return myMovieListData;
        } else {
          print(result['error']);
        }
      } else {
        throw Exception('Failed to laod data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getMyMovieList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.green[300],
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      '${myMovieListData['writer']} 님의 리뷰리스트',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                  )),
                ),
              ),
              Expanded(
                flex: 17,
                child: Container(
                    child: GridView.builder(
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: snapshot.data['result'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 2.0, right: 2.0, bottom: 4.0),
                      child: Container(
                        child: Image.memory(
                            base64Decode(
                                myMovieListData['result'][index]['ticket']),
                            fit: BoxFit.fill),
                      ),
                    );
                  },
                )),
              ),
            ],
          );
        }
        return Container(child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
