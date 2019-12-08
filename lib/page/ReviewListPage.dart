import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_review_frontend/util/storage.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'DetailPage.dart';

class ReviewListPage extends StatefulWidget {
  @override
  _ReviewListPageState createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  Storage storage = new Storage();
  Future getData() async {
    var response =
        await http.get('http://${Storage.ip}:4000/api/movie/get_review_list');
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
    return Container(
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
                        padding: const EdgeInsets.only(top: 8.0, left: 2.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: IconButton(
                              icon: Icon(OMIcons.modeComment),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        DetailPage(
                                            contentData:
                                                snapshot.data[index])));
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8.0, left: paddingLeft),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Text(
                              '별점: ${snapshot.data[index]['score']}점',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0,
                            left: paddingLeft,
                            bottom: 20.0,
                            right: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    snapshot.data[index]['writer'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      snapshot.data[index]['review'],
                                      style: TextStyle(fontSize: 16.0),
                                      maxLines: 3,
                                    ),
                                  ),
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
    ));
  }
}
