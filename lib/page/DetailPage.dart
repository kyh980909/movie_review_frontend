import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:movie_review_frontend/util/storage.dart';

class DetailPage extends StatefulWidget {
  final Map contentData;
  DetailPage({
    Key key,
    @required this.contentData,
  }) : super(key: key);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _commentController = TextEditingController();
  double opacity = 1.0;
  List<dynamic> comments = new List();
  bool lock = true;
  Storage storage = new Storage();

  Future getComment(String index) async {
    var response = await http
        .get('http://${Storage.ip}:4000/api/comment/get_comment_list/$index');
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        if (mounted) {
          setState(() {
            comments.clear();
            comments.addAll(result['result'][0]['comments']);
            lock = true;
          });
        }
      } else {
        print(result['error']);
      }
    } else {
      throw Exception('Failed to laod data');
    }
  }

  @override
  void initState() {
    super.initState();
    getComment(widget.contentData['_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: Text(
          '댓글',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey))),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 16.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        widget.contentData['writer'],
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      widget.contentData['review'],
                      style: TextStyle(fontSize: 16.0),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            comments[index]['writer'],
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Text(comments[index]['comment']),
                      ],
                    ),
                  ),
                );
              },
            )),
            Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 18,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      child: TextField(
                        controller: _commentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        autofocus: true,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20.0),
                            hintText: '댓글 달기...',
                            border: InputBorder.none),
                        onChanged: (text) {
                          if (mounted) {
                            setState(() {
                              text.length == 0 ? opacity = 0.5 : opacity = 1.0;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        if (lock) {
                          lock = false;
                          if (_commentController.text.length != 0) {
                            final url =
                                'http://${Storage.ip}:4000/api/comment/write_comment';
                            final res = await http.post(url, body: {
                              'index': widget.contentData['_id'], // 글 번호
                              'writer':
                                  await storage.getUserId(), // 현재 로그인한 유저 아이디
                              'comment': _commentController.text // 댓글
                            });

                            if (res.statusCode == 200) {
                              final jsonBody = json.decode(res.body);
                              final result = jsonBody['success'];
                              if (result) {
                                if (mounted) {
                                  setState(() {
                                    getComment(widget.contentData['_id']);
                                  });
                                }
                                _commentController.text = '';
                              } else {
                                print(jsonBody['error']);
                                Fluttertoast.showToast(
                                    msg: jsonBody['error'].toString(),
                                    toastLength: Toast.LENGTH_SHORT);
                              }
                            }
                          }
                        }
                      },
                      child: Text('게시',
                          style: TextStyle(
                              color: Colors.blue.withOpacity(opacity))),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
