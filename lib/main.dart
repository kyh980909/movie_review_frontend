import 'package:flutter/material.dart';
import './page/LoginPage.dart';

void main() => runApp(MovieReview());

class MovieReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
