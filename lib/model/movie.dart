class Movie {
  final String writer; // 작성자
  final String title; // 영화명
  final String date; // 영화를 본 날짜
  final String ticket; // 티켓 사진 (base64)
  final String score; // 평점
  final String review; // 감상평

  Movie(
      {this.writer,
      this.title,
      this.date,
      this.ticket,
      this.score,
      this.review});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
        writer: json['writer'],
        title: json['title'],
        date: json['date'],
        ticket: json['ticket'],
        score: json['score'],
        review: json['review']);
  }

  Map<dynamic, dynamic> toJson() => {
        'writer': writer,
        'title': title,
        'date': date,
        'ticket': ticket,
        'score': score,
        'review': review,
      };
}
