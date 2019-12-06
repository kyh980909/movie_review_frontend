import 'package:flutter/material.dart';
import 'package:movie_review_frontend/page/AddMovieReviewPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영화 리뷰 리스트'),
      ),
      body: Container(
        child: Center(
          child: Text('영화 리스트 페이지'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => AddMovieReviewPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
