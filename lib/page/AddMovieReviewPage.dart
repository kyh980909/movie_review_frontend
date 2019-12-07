import 'dart:convert';
import 'dart:io';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:movie_review_frontend/model/movie.dart';
import 'package:http/http.dart' as http;

class AddMovieReviewPage extends StatefulWidget {
  final Map userData;
  AddMovieReviewPage({
    Key key,
    @required this.userData,
  }) : super(key: key);

  @override
  _AddMovieReviewPageState createState() => _AddMovieReviewPageState();
}

class _AddMovieReviewPageState extends State<AddMovieReviewPage> {
  TextEditingController title = TextEditingController();
  TextEditingController review = TextEditingController();

  File _image;
  final df = DateFormat('yyyy년 MM월 dd일');
  String date = '';
  double score = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('영화 추가 페이지'),
        ),
        body: ListView(
          children: <Widget>[
            inputMovieName(),
            setDate(context),
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: () => getImageFromGallery(),
            ),
            Center(
                child: _image == null
                    ? Text('No image selected')
                    : Image.file(_image, width: 300)),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                child: TextField(
                  controller: review,
                  decoration: InputDecoration(
                      hintText: '나만의 감상평을 적으세요 (최대 100자)',
                      contentPadding: EdgeInsets.all(16.0),
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 100,
                )),
            starScore(), // 별점 위젯
            saveButton(context),
          ],
        ));
  }

  Padding setDate(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          Text(
            '영화 관람 날짜 :',
            style: TextStyle(fontSize: 20.0),
          ),
          Text(
            '$date',
            style: TextStyle(fontSize: 20.0),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(1970),
                  maxTime: DateTime.now(), onConfirm: (date) {
                setState(() {
                  this.date = df.format(date);
                });
              }, currentTime: DateTime.now(), locale: LocaleType.ko);
            },
          )
        ],
      ),
    );
  }

  TextField inputMovieName() {
    return TextField(
      controller: title,
      decoration: InputDecoration(
          hintText: '영화 제목을 입력하세요', contentPadding: EdgeInsets.all(16.0)),
    );
  }

  Padding starScore() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Center(
        child: RatingBar(
          initialRating: 3,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            score = rating;
          },
        ),
      ),
    );
  }

  Padding saveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 160, right: 160, bottom: 30.0),
      child: RaisedButton(
        onPressed: () {
          if (title.text == '') {
            Fluttertoast.showToast(
                msg: '영화명을 입력해주세요', toastLength: Toast.LENGTH_SHORT);
          } else if (date == '') {
            Fluttertoast.showToast(
                msg: '날짜를 입력해주세요.', toastLength: Toast.LENGTH_SHORT);
          } else if (_image == null) {
            Fluttertoast.showToast(
                msg: '사진을 업로드해주세요.', toastLength: Toast.LENGTH_SHORT);
          } else {
            submitMovie(title.text, review.text, Image.file(_image));
          }
        },
        child: Text(
          '저장',
          style: TextStyle(color: Colors.white),
        ),
        color: Color(0xff3fc4fe), //Color.fromRGBO(63, 196, 254, 100),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  Future submitMovie(String title, String review, Image ticket) async {
    if (review == null) review = '';

    List<int> imageBytes = await _image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Movie movie = Movie(
        writer: widget.userData['id'],
        title: title,
        date: date,
        ticket: base64Image,
        score: score.toString(),
        review: review);
    final url = 'http://localhost:4000/api/movie/write_review';
    final res = await http.post(url, body: movie.toJson());

    if (res.statusCode == 200) {
      final jsonBody = json.decode(res.body);
      final result = jsonBody['success'];
      if (result) {
        Fluttertoast.showToast(
            msg: '글이 작성되었습니다!', toastLength: Toast.LENGTH_SHORT);

        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: jsonBody['error'].toString(), toastLength: Toast.LENGTH_SHORT);
      }
    }
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }
}
