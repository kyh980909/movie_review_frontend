class Login {
  final bool success;
  final String error;

  Login({this.success, this.error});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(success: json['success'], error: json['error']);
  }
}
