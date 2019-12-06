class User {
  final String id;
  final String pw;

  User(this.id, this.pw);

  Map<String, dynamic> toJson() => {
        'id': id,
        'pw': pw,
      };
}
